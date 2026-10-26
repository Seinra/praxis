import 'dart:convert';

import 'package:praxis/src/httpx.dart';
import 'package:praxis/src/result.dart';
import 'package:test/test.dart';

/// A Catalyst-flavored course lesson used as the typed body in scenarios.
final class _Lesson {
  _Lesson(this.slug, this.title);

  final String slug;
  final String title;

  /// Manual codec: builds a lesson from decoded JSON fields (edge cast).
  static _Lesson fromJson(Map<String, Object?> decodedJson) {
    final Object? slugField = decodedJson['slug'];
    final Object? titleField = decodedJson['title'];
    if (slugField is! String || titleField is! String) {
      throw const FormatException('lesson needs string slug + title');
    }
    return _Lesson(slugField, titleField);
  }

  /// Manual codec: renders this lesson as JSON-encodable fields.
  Map<String, Object?> toJson() => <String, Object?>{
    'slug': slug,
    'title': title,
  };
}

/// Decodes a lesson the way callers supply [decodeBody]-style codecs.
_Lesson _lessonFromJson(Map<String, Object?> decodedJson) =>
    _Lesson.fromJson(decodedJson);

/// Builds a fake transport answering every call with one canned reply.
HttpxTransport _cannedTransport(String bodyText, {int statusCode = 200}) {
  return (HttpxRequest outgoingRequest) async =>
      HttpxResponse(statusCode: statusCode, bodyText: bodyText);
}

const String _lessonBodyText =
    '{"slug":"generics-intro","title":"Intro to Generics"}';

void main() {
  group('httpxGet', () {
    test('decodes a 200 JSON body into the typed body', () async {
      final Result<_Lesson> lessonOutcome = await httpxGet<_Lesson>(
        _cannedTransport(_lessonBodyText),
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
        _lessonFromJson,
      );
      expect(lessonOutcome.isOk, isTrue);
      expect(
        lessonOutcome.getOrElse(_Lesson('fallback', 'Fallback')).title,
        equals('Intro to Generics'),
      );
    });

    test('hands the GET method and uri to the transport', () async {
      final List<HttpxRequest> seenRequests = <HttpxRequest>[];
      Future<HttpxResponse> captureTransport(
        HttpxRequest outgoingRequest,
      ) async {
        seenRequests.add(outgoingRequest);
        return const HttpxResponse(statusCode: 200, bodyText: _lessonBodyText);
      }

      final Uri resourceUri = Uri.parse(
        'https://catalyst.example/lessons/generics-intro',
      );
      await httpxGet<_Lesson>(
        captureTransport,
        HttpxRequest.get(resourceUri),
        _lessonFromJson,
      );
      expect(seenRequests, hasLength(1));
      expect(seenRequests.single.method, equals('GET'));
      expect(seenRequests.single.resourceUri, equals(resourceUri));
    });

    test('non-2xx answers as status failure carrying code and body', () async {
      int decodeCalls = 0;
      final Result<_Lesson> lessonOutcome = await httpxGet<_Lesson>(
        _cannedTransport('missing lesson', statusCode: 404),
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/nope')),
        (Map<String, Object?> decodedJson) {
          decodeCalls += 1;
          return _lessonFromJson(decodedJson);
        },
      );
      expect(lessonOutcome.isFailure, isTrue);
      final HttpxStatusFailure statusFailure = lessonOutcome.when(
        ok: (_) => throw StateError('want failure'),
        failure: (Exception failureCause) => failureCause,
      ) as HttpxStatusFailure;
      expect(statusFailure.statusCode, equals(404));
      expect(statusFailure.bodyText, equals('missing lesson'));
      expect(decodeCalls, equals(0));
    });

    test('transport throw answers as transport failure', () async {
      final Exception transportCause = Exception('socket closed');
      Future<Never> brokenTransport(HttpxRequest outgoingRequest) async =>
          throw transportCause;
      final Result<_Lesson> lessonOutcome = await httpxGet<_Lesson>(
        brokenTransport,
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
        _lessonFromJson,
      );
      expect(lessonOutcome.isFailure, isTrue);
      final HttpxTransportFailure transportFailure = lessonOutcome.when(
        ok: (_) => throw StateError('want failure'),
        failure: (Exception failureCause) => failureCause,
      ) as HttpxTransportFailure;
      expect(identical(transportFailure.cause, transportCause), isTrue);
    });

    test('codec throw answers as codec failure', () async {
      final Result<_Lesson> lessonOutcome = await httpxGet<_Lesson>(
        _cannedTransport('{"slug":42,"title":null}'),
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
        _lessonFromJson,
      );
      expect(lessonOutcome.isFailure, isTrue);
      expect(
        lessonOutcome.when(
          ok: (_) => '',
          failure: (Exception failureCause) => failureCause,
        ),
        isA<HttpxCodecFailure>(),
      );
    });

    test('empty body answers as codec failure', () async {
      final Result<_Lesson> lessonOutcome = await httpxGet<_Lesson>(
        _cannedTransport(''),
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
        _lessonFromJson,
      );
      expect(lessonOutcome.isFailure, isTrue);
      expect(
        lessonOutcome.when(
          ok: (_) => '',
          failure: (Exception failureCause) => failureCause,
        ),
        isA<HttpxCodecFailure>(),
      );
    });

    test('non-object JSON answers as codec failure', () async {
      final Result<_Lesson> lessonOutcome = await httpxGet<_Lesson>(
        _cannedTransport('["generics-intro"]'),
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
        _lessonFromJson,
      );
      expect(lessonOutcome.isFailure, isTrue);
      expect(
        lessonOutcome.when(
          ok: (_) => '',
          failure: (Exception failureCause) => failureCause,
        ),
        isA<HttpxCodecFailure>(),
      );
    });

    test('rejects a POST request as a programmer error', () async {
      await expectLater(
        httpxGet<_Lesson>(
          _cannedTransport(_lessonBodyText),
          HttpxRequest.postJson(
            Uri.parse('https://catalyst.example/lessons/a'),
            <String, Object?>{'slug': 'generics-intro'},
          ),
          _lessonFromJson,
        ),
        throwsArgumentError,
      );
    });
  });

  group('httpxGet status boundaries', () {
    test('200 and 299 succeed while 199 and 300 fail', () async {
      for (final int statusCode in <int>[200, 299]) {
        final Result<_Lesson> lessonOutcome = await httpxGet<_Lesson>(
          _cannedTransport(_lessonBodyText, statusCode: statusCode),
          HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
          _lessonFromJson,
        );
        expect(
          lessonOutcome.isOk,
          isTrue,
          reason: 'status $statusCode reads as success',
        );
      }
      for (final int statusCode in <int>[199, 300]) {
        final Result<_Lesson> lessonOutcome = await httpxGet<_Lesson>(
          _cannedTransport('edge', statusCode: statusCode),
          HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
          _lessonFromJson,
        );
        expect(
          lessonOutcome.isFailure,
          isTrue,
          reason: 'status $statusCode reads as failure',
        );
        expect(
          (lessonOutcome.when(
            ok: (_) => throw StateError('want failure'),
            failure: (Exception failureCause) => failureCause,
          ) as HttpxStatusFailure).statusCode,
          equals(statusCode),
        );
      }
    });
  });

  group('httpxPost', () {
    test('sends JSON fields and decodes the typed reply', () async {
      final List<HttpxRequest> seenRequests = <HttpxRequest>[];
      Future<HttpxResponse> captureTransport(
        HttpxRequest outgoingRequest,
      ) async {
        seenRequests.add(outgoingRequest);
        return const HttpxResponse(statusCode: 201, bodyText: _lessonBodyText);
      }

      final Result<_Lesson> lessonOutcome = await httpxPost<_Lesson>(
        captureTransport,
        HttpxRequest.postJson(
          Uri.parse('https://catalyst.example/lessons'),
          _Lesson('generics-intro', 'Intro to Generics').toJson(),
        ),
        _lessonFromJson,
      );
      expect(lessonOutcome.isOk, isTrue);
      expect(
        lessonOutcome.getOrElse(_Lesson('fallback', 'Fallback')).slug,
        equals('generics-intro'),
      );
      expect(seenRequests, hasLength(1));
      expect(seenRequests.single.method, equals('POST'));
      final Object? sentFields = jsonDecode(seenRequests.single.bodyText);
      expect(sentFields, isA<Map<String, Object?>>());
      expect(
        (sentFields as Map<String, Object?>)['slug'],
        equals('generics-intro'),
      );
    });

    test('non-2xx answers as status failure without decoding', () async {
      int decodeCalls = 0;
      final Result<_Lesson> lessonOutcome = await httpxPost<_Lesson>(
        _cannedTransport('duplicate slug', statusCode: 409),
        HttpxRequest.postJson(
          Uri.parse('https://catalyst.example/lessons'),
          <String, Object?>{'slug': 'generics-intro'},
        ),
        (Map<String, Object?> decodedJson) {
          decodeCalls += 1;
          return _lessonFromJson(decodedJson);
        },
      );
      expect(lessonOutcome.isFailure, isTrue);
      final HttpxStatusFailure statusFailure = lessonOutcome.when(
        ok: (_) => throw StateError('want failure'),
        failure: (Exception failureCause) => failureCause,
      ) as HttpxStatusFailure;
      expect(statusFailure.statusCode, equals(409));
      expect(statusFailure.bodyText, equals('duplicate slug'));
      expect(decodeCalls, equals(0));
    });

    test('transport throw answers as transport failure', () async {
      final Exception transportCause = Exception('connection refused');
      Future<Never> brokenTransport(HttpxRequest outgoingRequest) async =>
          throw transportCause;
      final Result<_Lesson> lessonOutcome = await httpxPost<_Lesson>(
        brokenTransport,
        HttpxRequest.postJson(
          Uri.parse('https://catalyst.example/lessons'),
          <String, Object?>{'slug': 'generics-intro'},
        ),
        _lessonFromJson,
      );
      expect(lessonOutcome.isFailure, isTrue);
      expect(
        (lessonOutcome.when(
          ok: (_) => throw StateError('want failure'),
          failure: (Exception failureCause) => failureCause,
        ) as HttpxTransportFailure).cause,
        same(transportCause),
      );
    });

    test('codec throw answers as codec failure', () async {
      final Result<_Lesson> lessonOutcome = await httpxPost<_Lesson>(
        _cannedTransport('not json at all {{{'),
        HttpxRequest.postJson(
          Uri.parse('https://catalyst.example/lessons'),
          <String, Object?>{'slug': 'generics-intro'},
        ),
        _lessonFromJson,
      );
      expect(lessonOutcome.isFailure, isTrue);
      expect(
        lessonOutcome.when(
          ok: (_) => '',
          failure: (Exception failureCause) => failureCause,
        ),
        isA<HttpxCodecFailure>(),
      );
    });

    test('empty body answers as codec failure', () async {
      final Result<_Lesson> lessonOutcome = await httpxPost<_Lesson>(
        _cannedTransport(''),
        HttpxRequest.postJson(
          Uri.parse('https://catalyst.example/lessons'),
          <String, Object?>{'slug': 'generics-intro'},
        ),
        _lessonFromJson,
      );
      expect(lessonOutcome.isFailure, isTrue);
      expect(
        lessonOutcome.when(
          ok: (_) => '',
          failure: (Exception failureCause) => failureCause,
        ),
        isA<HttpxCodecFailure>(),
      );
    });

    test('rejects a GET request as a programmer error', () async {
      await expectLater(
        httpxPost<_Lesson>(
          _cannedTransport(_lessonBodyText),
          HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
          _lessonFromJson,
        ),
        throwsArgumentError,
      );
    });
  });

  group('HttpxRequest', () {
    test('get shapes a bodyless GET with empty headers', () {
      final Uri resourceUri = Uri.parse(
        'https://catalyst.example/lessons/generics-intro',
      );
      final HttpxRequest outgoingRequest = HttpxRequest.get(resourceUri);
      expect(outgoingRequest.method, equals('GET'));
      expect(outgoingRequest.resourceUri, equals(resourceUri));
      expect(outgoingRequest.bodyText, isEmpty);
      expect(outgoingRequest.headers, isEmpty);
    });

    test('postJson encodes fields and pins the JSON content type', () {
      final HttpxRequest outgoingRequest = HttpxRequest.postJson(
        Uri.parse('https://catalyst.example/lessons'),
        <String, Object?>{'slug': 'generics-intro'},
      );
      expect(outgoingRequest.method, equals('POST'));
      final Object? sentFields = jsonDecode(outgoingRequest.bodyText);
      expect(
        (sentFields as Map<String, Object?>)['slug'],
        equals('generics-intro'),
      );
      expect(
        outgoingRequest.headers['content-type'],
        equals('application/json'),
      );
    });

    test('postJson keeps a caller content type over the default', () {
      final HttpxRequest outgoingRequest = HttpxRequest.postJson(
        Uri.parse('https://catalyst.example/lessons'),
        <String, Object?>{'slug': 'generics-intro'},
        headers: <String, String>{
          'content-type': 'application/vnd.lesson+json',
        },
      );
      expect(
        outgoingRequest.headers['content-type'],
        equals('application/vnd.lesson+json'),
      );
    });

    test('factories never mutate the caller maps', () {
      final Map<String, Object?> requestFields = <String, Object?>{
        'slug': 'generics-intro',
      };
      final Map<String, String> callerHeaders = <String, String>{
        'x-lesson-tier': 'free',
      };
      HttpxRequest.postJson(
        Uri.parse('https://catalyst.example/lessons'),
        requestFields,
        headers: callerHeaders,
      );
      expect(
        requestFields,
        equals(<String, Object?>{'slug': 'generics-intro'}),
      );
      expect(callerHeaders, equals(<String, String>{'x-lesson-tier': 'free'}));
    });
  });

  group('failure rendering', () {
    test('status failure names the status code', () {
      const HttpxStatusFailure statusFailure = HttpxStatusFailure(
        503,
        'warming up',
      );
      expect(statusFailure, isA<Exception>());
      expect(statusFailure.toString(), contains('503'));
      expect(statusFailure.statusCode, equals(503));
      expect(statusFailure.bodyText, equals('warming up'));
    });

    test('transport failure carries the thrown cause', () {
      final Exception transportCause = Exception('socket closed');
      final HttpxTransportFailure transportFailure = HttpxTransportFailure(
        transportCause,
      );
      expect(transportFailure, isA<Exception>());
      expect(identical(transportFailure.cause, transportCause), isTrue);
      expect(transportFailure.toString(), contains('socket closed'));
    });

    test('codec failure carries the thrown cause', () {
      const FormatException codecCause = FormatException('cut short');
      const HttpxCodecFailure codecFailure = HttpxCodecFailure(codecCause);
      expect(codecFailure, isA<Exception>());
      expect(identical(codecFailure.cause, codecCause), isTrue);
      expect(codecFailure.toString(), contains('cut short'));
    });
  });

  group('purity', () {
    test('repeated calls return fresh outcome instances', () async {
      final HttpxTransport fakeTransport = _cannedTransport(_lessonBodyText);
      final HttpxRequest outgoingRequest = HttpxRequest.get(
        Uri.parse('https://catalyst.example/lessons/a'),
      );
      final Result<_Lesson> firstOutcome = await httpxGet<_Lesson>(
        fakeTransport,
        outgoingRequest,
        _lessonFromJson,
      );
      final Result<_Lesson> secondOutcome = await httpxGet<_Lesson>(
        fakeTransport,
        outgoingRequest,
        _lessonFromJson,
      );
      expect(identical(firstOutcome, secondOutcome), isFalse);
      expect(
        identical(
          firstOutcome.getOrElse(_Lesson('fallback', 'Fallback')),
          secondOutcome.getOrElse(_Lesson('fallback', 'Fallback')),
        ),
        isFalse,
      );
    });
  });

  group('documented examples stay runnable', () {
    test('HttpxTransport fake example', () async {
      Future<HttpxResponse> fakeTransport(HttpxRequest outgoingRequest) async =>
          const HttpxResponse(
            statusCode: 200,
            bodyText: '{"title":"Intro to Generics"}',
          );
      final HttpxResponse wireResponse = await fakeTransport(
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
      );
      // wireResponse.statusCode == 200
      expect(wireResponse.statusCode, equals(200));
    });

    test('httpxGet example', () async {
      final Result<String> lessonOutcome = await httpxGet<String>(
        _cannedTransport(_lessonBodyText),
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
        (Map<String, Object?> decodedJson) => decodedJson['title'] as String,
      );
      // lessonOutcome.getOrElse('missing') == 'Intro to Generics'
      expect(lessonOutcome.getOrElse('missing'), equals('Intro to Generics'));
    });

    test('httpxPost example', () async {
      final Result<String> lessonOutcome = await httpxPost<String>(
        _cannedTransport(_lessonBodyText, statusCode: 201),
        HttpxRequest.postJson(
          Uri.parse('https://catalyst.example/lessons'),
          <String, Object?>{'slug': 'generics-intro'},
        ),
        (Map<String, Object?> decodedJson) => decodedJson['slug'] as String,
      );
      // lessonOutcome.getOrElse('missing') == 'generics-intro'
      expect(lessonOutcome.getOrElse('missing'), equals('generics-intro'));
    });

    test('HttpxRequest.new example', () {
      final HttpxRequest outgoingRequest = HttpxRequest(
        method: 'GET',
        resourceUri: Uri.parse(
          'https://catalyst.example/lessons/generics-intro',
        ),
      );
      // outgoingRequest.method == 'GET'
      expect(outgoingRequest.method, equals('GET'));
    });

    test('HttpxRequest.get example', () {
      final HttpxRequest outgoingRequest = HttpxRequest.get(
        Uri.parse('https://catalyst.example/lessons/generics-intro'),
      );
      // outgoingRequest.method == 'GET'
      expect(outgoingRequest.method, equals('GET'));
    });

    test('HttpxRequest.postJson example', () {
      final HttpxRequest outgoingRequest = HttpxRequest.postJson(
        Uri.parse('https://catalyst.example/lessons'),
        <String, Object?>{'slug': 'generics-intro'},
      );
      // outgoingRequest.method == 'POST'
      expect(outgoingRequest.method, equals('POST'));
    });

    test('HttpxStatusFailure example', () {
      const HttpxStatusFailure statusFailure = HttpxStatusFailure(
        404,
        'missing lesson',
      );
      // statusFailure.statusCode == 404
      expect(statusFailure.statusCode, equals(404));
    });
  });
}

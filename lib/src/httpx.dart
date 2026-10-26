/// Typed JSON envelope over an injected HTTP transport (client side).
///
/// Reach for this when a caller needs typed JSON without owning the wire:
/// [HttpxTransport] names the injection point (fake in tests, `dart:io`
/// wiring at the composition root), [HttpxRequest] shapes the outgoing call
/// ([HttpxRequest.get] reads, [HttpxRequest.postJson] writes),
/// [httpxGet] fetches a typed body, [httpxPost] sends JSON fields and reads
/// a typed body back, [HttpxResponse] shapes the wire reply fakes answer
/// with, and [HttpxStatusFailure], [HttpxTransportFailure], plus
/// [HttpxCodecFailure] name the three failures traveling through
/// [Result.failure].
///
/// Which function?
///
/// | When you want to ...                                  | Reach for ...          |
/// | ----------------------------------------------------- | ---------------------- |
/// | Name the injectable caller-supplied transport         | [HttpxTransport]       |
/// | Shape an outgoing call (method, uri, headers, body)  | [HttpxRequest]         |
/// | Shape a GET call with no body                         | [HttpxRequest.get]     |
/// | Shape a POST call with JSON-encoded fields            | [HttpxRequest.postJson] |
/// | Shape the wire reply fakes answer with                | [HttpxResponse]        |
/// | Fetch a typed body over GET                           | [httpxGet]             |
/// | Send JSON fields and read a typed body over POST       | [httpxPost]            |
/// | Name a non-2xx reply (status code + body)             | [HttpxStatusFailure]   |
/// | Name a transport throw                                | [HttpxTransportFailure] |
/// | Name a codec throw (wire decode or caller decode)     | [HttpxCodecFailure]    |
///
/// Out of scope by design: server-side rendering (a Shelf adapter stays OUT
/// — server envelopes belong to the handler edge, never this client
/// envelope), and the `package:http` client stays OUT — one injected
/// [HttpxTransport] typedef already covers fakes, `dart:io` wiring, and any
/// third-party client adapter with zero dependencies, so depending on
/// `package:http` buys no behavior this slice needs (YAGNI-killed here with
/// a reason: zero-deps tension resolved toward zero deps). Retry and
/// backoff also stay OUT: the caller transport owns wire policy, this
/// envelope only classifies the outcome.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
library;

import 'dart:convert';

import 'package:praxis/src/result.dart';

/// Method name sent by [HttpxRequest.get].
const String _getMethodName = 'GET';

/// Method name sent by [HttpxRequest.postJson].
const String _postMethodName = 'POST';

/// First status code reading as success (inclusive lower bound).
const int _minSuccessStatusCode = 200;

/// First status code reading as failure (exclusive upper bound).
const int _firstFailureStatusCode = 300;

/// Wire media type pinned by [HttpxRequest.postJson].
const String _jsonContentType = 'application/json';

/// Header carrying the wire media type.
const String _contentTypeHeader = 'content-type';

/// Names the injectable caller-supplied HTTP transport.
///
/// The transport receives the outgoing [HttpxRequest] and answers the
/// [HttpxResponse] the wire would carry. Tests answer fakes directly;
/// production wires `dart:io` at the composition root and keeps `dart:io`
/// out of `lib` (web-compat), with zero dependencies (SDK-first DART-SDK).
/// Header policy, auth, retry, and backoff belong to the transport, never
/// to [httpxGet] or [httpxPost] — this envelope only classifies outcomes.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a caller-supplied wire to inject (fake or `dart:io`) | [HttpxTransport] |
///
/// Stdlib gap (DART-SDK): `dart:io` owns the socket but names no
/// test-seam type, so callers hard-wire `HttpClient` and tests need the
/// network. [HttpxTransport] names the seam as one function type, so fakes
/// answer in-process and the wire stays injectable. Fidelity note
/// (AXIOM-SISTER): mirrors Axiom `httpx` discipline (single JSON envelope,
/// Which-table, purity pins) without Go/Echo signatures — client-side over
/// an injected transport instead of server-side over `echo.Context`, and
/// [Result] failures instead of `(T, error)` pairs.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final HttpxTransport fakeTransport =
///     (HttpxRequest outgoingRequest) async => const HttpxResponse(
///       statusCode: 200,
///       bodyText: '{"title":"Intro to Generics"}',
///     );
/// final HttpxResponse wireResponse = await fakeTransport(
///   HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
/// );
/// // wireResponse.statusCode == 200
/// ```
///
/// Composition-root sketch (illustrative — needs `dart:io`, never imported
/// by this package, never executed here):
///
/// ```dart
/// HttpxTransport sharedClientTransport(HttpClient sharedClient) {
///   return (HttpxRequest outgoingRequest) async {
///     final HttpClientRequest wireRequest = await sharedClient.openUrl(
///       outgoingRequest.method,
///       outgoingRequest.resourceUri,
///     );
///     for (final MapEntry<String, String> headerEntry
///         in outgoingRequest.headers.entries) {
///       wireRequest.headers.set(headerEntry.key, headerEntry.value);
///     }
///     wireRequest.write(outgoingRequest.bodyText);
///     final HttpClientResponse wireResponse = await wireRequest.close();
///     final String responseBody =
///         await wireResponse.transform(utf8.decoder).join();
///     return HttpxResponse(
///       statusCode: wireResponse.statusCode,
///       bodyText: responseBody,
///     );
///   };
/// }
/// ```
typedef HttpxTransport = Future<HttpxResponse> Function(
  HttpxRequest outgoingRequest,
);

/// Shapes one outgoing HTTP call: method, uri, headers, and body text.
///
/// The value is immutable: factories copy the caller maps, and helpers read
/// them without mutating. Build reads with [HttpxRequest.get] and writes
/// with [HttpxRequest.postJson]; the unnamed constructor stays for custom
/// methods a future slice may name.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | an outgoing call to shape (method, uri, headers, body) | [HttpxRequest] |
///
/// Stdlib gap (DART-SDK): `dart:io` `HttpClientRequest` couples shaping to
/// the socket, so shaping needs the network. [HttpxRequest] shapes the call
/// as a plain value fakes can capture and assert.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final HttpxRequest outgoingRequest = HttpxRequest.get(
///   Uri.parse('https://catalyst.example/lessons/generics-intro'),
/// );
/// // outgoingRequest.method == 'GET'
/// ```
final class HttpxRequest {
  /// Shapes a custom outgoing call with an explicit [method].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a custom method the named factories do not cover | [HttpxRequest.new] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [HttpxRequest] — shaping stays a
  /// plain value instead of a socket-bound object.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final HttpxRequest outgoingRequest = HttpxRequest.get(
  ///   Uri.parse('https://catalyst.example/lessons/generics-intro'),
  /// );
  /// // outgoingRequest.method == 'GET'
  /// ```
  const HttpxRequest({
    required this.method,
    required this.resourceUri,
    this.headers = const <String, String>{},
    this.bodyText = '',
  });

  /// Shapes a bodyless GET call for [resourceUri].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a read to shape with no body | [HttpxRequest.get] |
  ///
  /// Stdlib gap (DART-SDK): `HttpClient.getUrl` shapes the read only
  /// against a live client. [HttpxRequest.get] shapes the same read as a
  /// value [httpxGet] and fakes share.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final HttpxRequest outgoingRequest = HttpxRequest.get(
  ///   Uri.parse('https://catalyst.example/lessons/generics-intro'),
  /// );
  /// // outgoingRequest.method == 'GET'
  /// ```
  const HttpxRequest.get(
    Uri resourceUri, {
    Map<String, String> headers = const <String, String>{},
  }) : this(method: _getMethodName, resourceUri: resourceUri, headers: headers);

  /// Shapes a POST call with [requestFields] JSON-encoded as the body.
  ///
  /// Pins the `content-type: application/json` header unless [headers]
  /// already carries a caller content type, which always wins. Never
  /// mutates [requestFields] or [headers].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a write to shape with JSON-encoded fields | [HttpxRequest.postJson] |
  ///
  /// Stdlib gap (DART-SDK): `dart:convert` `jsonEncode` encodes but names
  /// no request shape, so callers scatter method, headers, and body text.
  /// [HttpxRequest.postJson] pins that triple at the codec edge (manual
  /// codecs per the ratified JSON decision — no codegen).
  ///
  /// Throws the `jsonEncode` error when [requestFields] holds values the
  /// SDK cannot encode (SDK contract, like `Uri.parse` on bad input).
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final HttpxRequest outgoingRequest = HttpxRequest.postJson(
  ///   Uri.parse('https://catalyst.example/lessons'),
  ///   <String, Object?>{'slug': 'generics-intro'},
  /// );
  /// // outgoingRequest.method == 'POST'
  /// ```
  HttpxRequest.postJson(
    Uri resourceUri,
    Map<String, Object?> requestFields, {
    Map<String, String> headers = const <String, String>{},
  }) : this(
         method: _postMethodName,
         resourceUri: resourceUri,
         headers: <String, String>{
           _contentTypeHeader: _jsonContentType,
           ...headers,
         },
         bodyText: jsonEncode(requestFields),
       );

  /// The HTTP method name (`GET` from [HttpxRequest.get]).
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an outgoing call to read the method from | [HttpxRequest.method] |
  ///
  /// Stdlib gap (DART-SDK): the method lives on the socket-bound request;
  /// [method] reads it from the plain value instead.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final HttpxRequest outgoingRequest = HttpxRequest.get(
  ///   Uri.parse('https://catalyst.example/lessons/generics-intro'),
  /// );
  /// // outgoingRequest.method == 'GET'
  /// ```
  final String method;

  /// The target uri of the outgoing call.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an outgoing call to read the target from | [HttpxRequest.resourceUri] |
  ///
  /// Stdlib gap (DART-SDK): the uri lives on the socket-bound request;
  /// [resourceUri] reads it from the plain value instead.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final HttpxRequest outgoingRequest = HttpxRequest.get(
  ///   Uri.parse('https://catalyst.example/lessons/generics-intro'),
  /// );
  /// // outgoingRequest.method == 'GET'
  /// ```
  final Uri resourceUri;

  /// The outgoing headers, read but never mutated by helpers.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an outgoing call to read headers from | [HttpxRequest.headers] |
  ///
  /// Stdlib gap (DART-SDK): header mutation lives on the socket-bound
  /// request; [headers] exposes the pinned snapshot as a read map instead.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final HttpxRequest outgoingRequest = HttpxRequest.get(
  ///   Uri.parse('https://catalyst.example/lessons/generics-intro'),
  /// );
  /// // outgoingRequest.method == 'GET'
  /// ```
  final Map<String, String> headers;

  /// The outgoing body text (empty for [HttpxRequest.get]).
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an outgoing call to read the body from | [HttpxRequest.bodyText] |
  ///
  /// Stdlib gap (DART-SDK): the body streams on the socket-bound request;
  /// [bodyText] holds the already-encoded text on the plain value instead.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final HttpxRequest outgoingRequest = HttpxRequest.postJson(
  ///   Uri.parse('https://catalyst.example/lessons'),
  ///   <String, Object?>{'slug': 'generics-intro'},
  /// );
  /// // outgoingRequest.method == 'POST'
  /// ```
  final String bodyText;
}

/// Shapes one wire reply: status code, body text, and headers.
///
/// Fakes answer [HttpxResponse] values directly, so tests pin the envelope
/// without the network. Values are immutable plain data.
final class HttpxResponse {
  /// Shapes a wire reply with its [statusCode] and [bodyText].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a wire reply to shape (fakes answer this) | [HttpxResponse.new] |
  ///
  /// Stdlib gap (DART-SDK): `dart:io` `HttpClientResponse` streams the
  /// reply off the socket, so tests need the network. [HttpxResponse]
  /// shapes the same reply as a value fakes construct directly.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const HttpxResponse wireResponse = HttpxResponse(
  ///   statusCode: 200,
  ///   bodyText: '{"title":"Intro to Generics"}',
  /// );
  /// // wireResponse.statusCode == 200
  /// ```
  const HttpxResponse({
    required this.statusCode,
    this.bodyText = '',
    this.headers = const <String, String>{},
  });

  /// The wire status code (2xx reads as success).
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a wire reply to read the status from | [HttpxResponse.statusCode] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [HttpxResponse] — the status reads
  /// off the plain value instead of the socket stream.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const HttpxResponse wireResponse = HttpxResponse(
  ///   statusCode: 200,
  ///   bodyText: '{"title":"Intro to Generics"}',
  /// );
  /// // wireResponse.statusCode == 200
  /// ```
  final int statusCode;

  /// The wire body text (empty when the reply carries none).
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a wire reply to read the body from | [HttpxResponse.bodyText] |
  ///
  /// Stdlib gap (DART-SDK): the body streams off the socket; [bodyText]
  /// holds the already-joined text on the plain value instead.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const HttpxResponse wireResponse = HttpxResponse(
  ///   statusCode: 200,
  ///   bodyText: '{"title":"Intro to Generics"}',
  /// );
  /// // wireResponse.statusCode == 200
  /// ```
  final String bodyText;

  /// The wire headers, read but never mutated by helpers.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a wire reply to read headers from | [HttpxResponse.headers] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [HttpxResponse] — headers read off
  /// the plain value instead of the socket stream.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const HttpxResponse wireResponse = HttpxResponse(
  ///   statusCode: 200,
  ///   bodyText: '{"title":"Intro to Generics"}',
  /// );
  /// // wireResponse.statusCode == 200
  /// ```
  final Map<String, String> headers;
}

/// Names a non-2xx wire reply: status code plus body text.
///
/// Travels through [Result.failure] from [httpxGet] and [httpxPost] when
/// the wire answers outside 200–299. The caller codec never runs on this
/// path: there is no body contract to decode.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a non-2xx reply to name (code + body) | [HttpxStatusFailure] |
///
/// Stdlib gap (DART-SDK): `dart:io` reports non-2xx as bare status codes
/// beside the stream, so callers scatter code checks. [HttpxStatusFailure]
/// names the failure as one typed value. Fidelity note (AXIOM-SISTER):
/// mirrors Axiom `httpx` text-carrying failure envelopes without Go
/// signatures — status plus body text instead of an Echo-rendered string.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// const HttpxStatusFailure statusFailure = HttpxStatusFailure(
///   404,
///   'missing lesson',
/// );
/// // statusFailure.statusCode == 404
/// ```
final class HttpxStatusFailure implements Exception {
  /// Names a non-2xx reply with its [statusCode] and [bodyText].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a non-2xx code and body to wrap | [HttpxStatusFailure.new] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [HttpxStatusFailure]; this
  /// constructor is the direct spelling for pattern-matching contexts.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const HttpxStatusFailure statusFailure = HttpxStatusFailure(
  ///   404,
  ///   'missing lesson',
  /// );
  /// // statusFailure.statusCode == 404
  /// ```
  const HttpxStatusFailure(this.statusCode, this.bodyText);

  /// The non-2xx wire status code.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a status failure to read the code from | [HttpxStatusFailure.statusCode] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [HttpxStatusFailure]; the code
  /// reads off the typed failure instead of a scattered check.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const HttpxStatusFailure statusFailure = HttpxStatusFailure(
  ///   404,
  ///   'missing lesson',
  /// );
  /// // statusFailure.statusCode == 404
  /// ```
  final int statusCode;

  /// The body text the failing reply carried.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a status failure to read the body from | [HttpxStatusFailure.bodyText] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [HttpxStatusFailure]; the body
  /// travels with the code instead of a second stream read.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const HttpxStatusFailure statusFailure = HttpxStatusFailure(
  ///   404,
  ///   'missing lesson',
  /// );
  /// // statusFailure.statusCode == 404
  /// ```
  final String bodyText;

  /// Renders `HttpxStatusFailure(statusCode, bodyText)` for debugging.
  @override
  String toString() =>
      'HttpxStatusFailure(statusCode: $statusCode, bodyText: $bodyText)';
}

/// Names a throw from the injected [HttpxTransport].
///
/// Travels through [Result.failure] from [httpxGet] and [httpxPost] when
/// the transport throws instead of answering. Carries the original [cause]
/// instance untouched, never a string copy.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a transport throw to name | [HttpxTransportFailure] |
///
/// Stdlib gap (DART-SDK): socket throws escape as untyped async errors, so
/// callers catch beside the call. [HttpxTransportFailure] keeps the throw
/// inside the outcome with its type.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final HttpxTransportFailure transportFailure = HttpxTransportFailure(
///   Exception('socket closed'),
/// );
/// // transportFailure.cause.toString() == 'Exception: socket closed'
/// ```
final class HttpxTransportFailure implements Exception {
  /// Names a transport throw, carrying the original [cause] untouched.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a thrown transport cause to wrap | [HttpxTransportFailure.new] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [HttpxTransportFailure]; this
  /// constructor is the direct spelling for pattern-matching contexts.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final HttpxTransportFailure transportFailure = HttpxTransportFailure(
  ///   Exception('socket closed'),
  /// );
  /// // transportFailure.cause.toString() == 'Exception: socket closed'
  /// ```
  const HttpxTransportFailure(this.cause);

  /// The original thrown value, kept identical for inspection.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a transport failure to inspect | [HttpxTransportFailure.cause] |
  ///
  /// Stdlib gap (DART-SDK): thrown causes scatter across `catch` clauses.
  /// [cause] keeps the original instance on the outcome, mirroring
  /// [Failure.cause].
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final HttpxTransportFailure transportFailure = HttpxTransportFailure(
  ///   Exception('socket closed'),
  /// );
  /// // transportFailure.cause.toString() == 'Exception: socket closed'
  /// ```
  final Object cause;

  /// Renders `HttpxTransportFailure(cause)` for debugging.
  @override
  String toString() => 'HttpxTransportFailure(cause: $cause)';
}

/// Names a codec throw: wire decode or caller decode.
///
/// Travels through [Result.failure] from [httpxGet] and [httpxPost] when
/// the wire body is not decodable JSON (empty, malformed, or a non-object
/// envelope) or when the caller codec throws on decoded fields. Carries the
/// original [cause] instance untouched.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a codec throw to name (wire or caller side) | [HttpxCodecFailure] |
///
/// Stdlib gap (DART-SDK): `dart:convert` `jsonDecode` throws
/// `FormatException` across the call boundary, and caller codecs throw
/// their own field errors. [HttpxCodecFailure] keeps both inside the
/// outcome with their types, behind the typed wrapper (no `dynamic`
/// outside this edge).
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// const HttpxCodecFailure codecFailure = HttpxCodecFailure(
///   FormatException('cut short'),
/// );
/// // codecFailure.cause.toString().contains('cut short') == true
/// ```
final class HttpxCodecFailure implements Exception {
  /// Names a codec throw, carrying the original [cause] untouched.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a thrown codec cause to wrap | [HttpxCodecFailure.new] |
  ///
  /// Stdlib gap (DART-SDK): same gap as [HttpxCodecFailure]; this
  /// constructor is the direct spelling for pattern-matching contexts.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const HttpxCodecFailure codecFailure = HttpxCodecFailure(
  ///   FormatException('cut short'),
  /// );
  /// // codecFailure.cause.toString().contains('cut short') == true
  /// ```
  const HttpxCodecFailure(this.cause);

  /// The original thrown value, kept identical for inspection.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a codec failure to inspect | [HttpxCodecFailure.cause] |
  ///
  /// Stdlib gap (DART-SDK): thrown causes scatter across `catch` clauses.
  /// [cause] keeps the original instance on the outcome, mirroring
  /// [Failure.cause].
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// const HttpxCodecFailure codecFailure = HttpxCodecFailure(
  ///   FormatException('cut short'),
  /// );
  /// // codecFailure.cause.toString().contains('cut short') == true
  /// ```
  final Object cause;

  /// Renders `HttpxCodecFailure(cause)` for debugging.
  @override
  String toString() => 'HttpxCodecFailure(cause: $cause)';
}

/// Fetches a typed body over GET through [transport].
///
/// Sends [outgoingRequest] (built with [HttpxRequest.get]), then reads the
/// reply: a non-2xx status answers `failure` with [HttpxStatusFailure]
/// without running [decodeBody]; an empty, malformed, or non-object body
/// answers `failure` with [HttpxCodecFailure]; a throw from [transport]
/// answers `failure` with [HttpxTransportFailure]; a throw from
/// [decodeBody] answers `failure` with [HttpxCodecFailure]. [decodeBody] is
/// the caller manual codec (`dart:convert` at the edge, explicit
/// `fromJson` — no codegen), so `dynamic` never leaves this boundary.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a GET call to fetch a typed body with | [httpxGet] |
///
/// Stdlib gap (DART-SDK): `dart:io` couples fetching, status checks, and
/// decoding to the socket with throws across the boundary. [httpxGet]
/// owns the typed envelope over the injected [transport], and every
/// failure travels as a typed [Result.failure]. Fidelity note
/// (AXIOM-SISTER): mirrors Axiom `httpx` single-envelope discipline
/// without Go/Echo signatures — the envelope is the caller-decoded JSON
/// object, not an Echo-rendered `Response`.
///
/// Never mutates [outgoingRequest]; every call answers a fresh [Result].
/// Throws [ArgumentError] when [outgoingRequest] carries a non-GET method
/// (programmer error, like a bad `Uri.parse` argument).
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Result<String> lessonOutcome = await httpxGet<String>(
///   (HttpxRequest outgoingRequest) async => const HttpxResponse(
///     statusCode: 200,
///     bodyText: '{"title":"Intro to Generics"}',
///   ),
///   HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
///   (Map<String, Object?> decodedJson) => decodedJson['title'] as String,
/// );
/// // lessonOutcome.getOrElse('missing') == 'Intro to Generics'
/// ```
Future<Result<DecodedBody>> httpxGet<DecodedBody>(
  HttpxTransport transport,
  HttpxRequest outgoingRequest,
  DecodedBody Function(Map<String, Object?> decodedJson) decodeBody,
) async {
  if (outgoingRequest.method != _getMethodName) {
    throw ArgumentError.value(
      outgoingRequest.method,
      'outgoingRequest.method',
      'httpxGet sends GET only',
    );
  }
  return _sendEnvelopeRequest(transport, outgoingRequest, decodeBody);
}

/// Sends JSON fields and reads a typed body over POST through [transport].
///
/// Sends [outgoingRequest] (built with [HttpxRequest.postJson]), then reads
/// the reply with the same contract as [httpxGet]: non-2xx answers
/// `failure` with [HttpxStatusFailure] without running [decodeBody];
/// undecodable or non-object bodies answer `failure` with
/// [HttpxCodecFailure]; transport throws answer `failure` with
/// [HttpxTransportFailure]; caller codec throws answer `failure` with
/// [HttpxCodecFailure]. [decodeBody] is the caller manual codec
/// (`dart:convert` at the edge, explicit `fromJson` — no codegen).
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a POST call to send fields and read a typed body with | [httpxPost] |
///
/// Stdlib gap (DART-SDK): same gap as [httpxGet] — the send, status check,
/// and decode stay one typed envelope over the injected [transport].
/// Fidelity note (AXIOM-SISTER): same Axiom `httpx` mirror as [httpxGet];
/// the POST/GET split names the method contract instead of branching on
/// strings at call sites.
///
/// Never mutates [outgoingRequest]; every call answers a fresh [Result].
/// Throws [ArgumentError] when [outgoingRequest] carries a non-POST method
/// (programmer error).
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Result<String> lessonOutcome = await httpxPost<String>(
///   (HttpxRequest outgoingRequest) async => const HttpxResponse(
///     statusCode: 201,
///     bodyText: '{"slug":"generics-intro"}',
///   ),
///   HttpxRequest.postJson(
///     Uri.parse('https://catalyst.example/lessons'),
///     <String, Object?>{'slug': 'generics-intro'},
///   ),
///   (Map<String, Object?> decodedJson) => decodedJson['slug'] as String,
/// );
/// // lessonOutcome.getOrElse('missing') == 'generics-intro'
/// ```
Future<Result<DecodedBody>> httpxPost<DecodedBody>(
  HttpxTransport transport,
  HttpxRequest outgoingRequest,
  DecodedBody Function(Map<String, Object?> decodedJson) decodeBody,
) async {
  if (outgoingRequest.method != _postMethodName) {
    throw ArgumentError.value(
      outgoingRequest.method,
      'outgoingRequest.method',
      'httpxPost sends POST only',
    );
  }
  return _sendEnvelopeRequest(transport, outgoingRequest, decodeBody);
}

/// Whether [statusCode] reads as success (200–299 inclusive).
bool _holdsSuccessStatus(int statusCode) =>
    statusCode >= _minSuccessStatusCode && statusCode < _firstFailureStatusCode;

/// Sends [outgoingRequest] and decodes the envelope into a typed outcome.
///
/// Shared by [httpxGet] and [httpxPost] after their method guards: both
/// sides of the envelope behave identically once the method is proven.
Future<Result<DecodedBody>> _sendEnvelopeRequest<DecodedBody>(
  HttpxTransport transport,
  HttpxRequest outgoingRequest,
  DecodedBody Function(Map<String, Object?> decodedJson) decodeBody,
) async {
  late final HttpxResponse wireResponse;
  try {
    wireResponse = await transport(outgoingRequest);
  } catch (transportCause) {
    return Result<DecodedBody>.failure(HttpxTransportFailure(transportCause));
  }
  if (!_holdsSuccessStatus(wireResponse.statusCode)) {
    return Result<DecodedBody>.failure(
      HttpxStatusFailure(wireResponse.statusCode, wireResponse.bodyText),
    );
  }
  late final Object? decodedEnvelope;
  try {
    decodedEnvelope = jsonDecode(wireResponse.bodyText);
  } catch (codecCause) {
    return Result<DecodedBody>.failure(HttpxCodecFailure(codecCause));
  }
  if (decodedEnvelope is! Map<String, Object?>) {
    return Result<DecodedBody>.failure(
      const HttpxCodecFailure(
        FormatException('httpx: envelope body is not a JSON object'),
      ),
    );
  }
  try {
    return Result<DecodedBody>.ok(decodeBody(decodedEnvelope));
  } catch (codecCause) {
    return Result<DecodedBody>.failure(HttpxCodecFailure(codecCause));
  }
}

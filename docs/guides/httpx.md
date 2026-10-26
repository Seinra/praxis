# httpx — a typed JSON envelope over HTTP

You fetch and post typed JSON without owning the wire: you shape calls
with `HttpxRequest`, you answer them with fakes through `HttpxTransport`,
and every outcome — value or failure — travels back inside a `Result`.

**Version:** Praxis `0.1.0-dev`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';` exposes the envelope.
Tests answer fakes in-process; production wires `dart:io` at the
composition root (never inside `lib`, which stays web-compatible).

## Concept

`dart:io` couples fetching, status checks, and decoding to the socket, so
callers scatter checks and tests need the network. `httpx` owns one typed
envelope over an injected transport instead: 2xx replies decode through
your manual codec (`dart:convert` at the edge, explicit `fromJson` — no
codegen), and every failure travels as a typed `Result.failure`. Retry,
backoff, headers, and auth belong to the transport, never to this
envelope. Server rendering and `package:http` stay out by design: one
function typedef covers fakes, `dart:io` wiring, and any third-party
adapter with zero dependencies.

## Quick path

1. Shape a read: `HttpxRequest.get(Uri.parse('https://...'))`.
2. Answer it with a fake: `(HttpxRequest outgoingRequest) async =>
   const HttpxResponse(statusCode: 200, bodyText: '{...}')`.
3. Fetch the typed body: `await httpxGet<String>(transport, request, codec)`.
4. Shape a write: `HttpxRequest.postJson(uri, <String, Object?>{...})`.
5. Send it the same way: `await httpxPost<String>(transport, request, codec)`.
6. Branch the outcome: status, transport, and codec failures each carry
   their own typed failure.

## Which function?

The package doc (`lib/src/httpx.dart`) is the source; this table mirrors
its "Which function?" table:

| When you want to ...                                  | Reach for ...          |
| ----------------------------------------------------- | ---------------------- |
| Name the injectable caller-supplied transport         | [HttpxTransport]       |
| Shape an outgoing call (method, uri, headers, body)  | [HttpxRequest]         |
| Shape a GET call with no body                         | [HttpxRequest.get]     |
| Shape a POST call with JSON-encoded fields            | [HttpxRequest.postJson] |
| Shape the wire reply fakes answer with                | [HttpxResponse]        |
| Fetch a typed body over GET                           | [httpxGet]             |
| Send JSON fields and read a typed body over POST       | [httpxPost]            |
| Name a non-2xx reply (status code + body)             | [HttpxStatusFailure]   |
| Name a transport throw                                | [HttpxTransportFailure] |
| Name a codec throw (wire decode or caller decode)     | [HttpxCodecFailure]    |

## Example

Example contents are asserted by `test/docs_guides_c_test.dart` (group `httpx guide`):

```dart
import 'package:praxis/praxis.dart';

Future<void> main() async {
  HttpxTransport fakeTransport(String bodyText, {int statusCode = 200}) {
    return (HttpxRequest outgoingRequest) async =>
        HttpxResponse(statusCode: statusCode, bodyText: bodyText);
  }

  String readTitle(Map<String, Object?> decodedJson) =>
      decodedJson['title'] as String;

  final Result<String> lessonOutcome = await httpxGet<String>(
    fakeTransport('{"title":"Intro to Generics"}'),
    HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
    readTitle,
  );
  print(lessonOutcome.getOrElse('missing')); // Output: Intro to Generics

  final Result<String> missingOutcome = await httpxGet<String>(
    fakeTransport('missing lesson', statusCode: 404),
    HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/missing')),
    readTitle,
  );
  print(missingOutcome.isFailure); // Output: true
}
```

Expected output:

```text
Intro to Generics
true
```

Run it: `dart test test/docs_guides_c_test.dart -n 'httpx guide'`.

> [!WARNING]
> Check the method before you send: `httpxGet` sends GET only and
> `httpxPost` sends POST only, and each throws `ArgumentError` on the
> wrong method (a programmer error, like a bad `Uri.parse`). Never run
> the codec yourself on a non-2xx reply either: the envelope answers
> `HttpxStatusFailure` without running your decoder, so branch on the
> outcome first and decode only on success.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Only 2xx reads as success | Status 200–299 decodes; anything else answers `failure` with `HttpxStatusFailure` carrying the code plus body text. |
| Undecodable bodies are codec failures | Empty, malformed, or non-object JSON answers `failure` with `HttpxCodecFailure`, never a bare `FormatException`. |
| Transport throws stay inside the outcome | A throw from the transport answers `failure` with `HttpxTransportFailure` carrying the original cause untouched. |
| Caller codec throws stay inside the outcome | A throw from your decode function answers `failure` with `HttpxCodecFailure`; `dynamic` never leaves this boundary. |
| Method guards throw for programmer error | A non-GET request through `httpxGet` (or non-POST through `httpxPost`) throws `ArgumentError` instead of sending. |
| Requests are values, never mutated | Neither helper mutates the outgoing request; every call answers a fresh `Result`. |

## When to use the stdlib directly

Reach for `dart:io` `HttpClient` directly when the call site needs no
test seam: a single throwaway script, a composition-root adapter you
already cover end to end, or streaming bodies this object envelope does
not shape. Reach for `dart:convert` `jsonDecode` directly for one-off
decoding with no status, transport, or codec policy. Reach for `httpx`
when fakes, typed bodies, and classified failures must travel together.

## Checklist

- [ ] You can state the status rule in one sentence (only 2xx decodes; anything else answers `HttpxStatusFailure` without running your codec).
- [ ] You can state the throw rule in one sentence (transport and codec throws stay inside the `Result` as typed failures; only a wrong-method call throws `ArgumentError`).
- [ ] You can shape a GET and a POST and branch the outcome before decoding on success.

## Next step

Join a background fetch instead of awaiting it inline: see [task](task.md)
for the eager computation with a shared `Result` outcome.

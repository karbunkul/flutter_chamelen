import 'package:chameleon/chameleon.dart';
import 'package:meta/meta.dart';

/// A base class for events, providing a unique identifier for each event.
///
/// This class serves as the foundation for specific event types such as
/// request and response events.
@immutable
interface class Event {
  /// A unique identifier for the event.
  final int id;

  /// Creates an [Event] with the specified [id].
  const Event({required this.id});
}

/// Represents a request event associated with a specific simulator.
///
/// This class is used to encapsulate information about a request
/// and the simulator that handles it. It is marked as `@internal`
/// and intended for internal use only.
@internal
@immutable
final class RequestEvent extends Event {
  /// The simulator associated with this request.
  final Simulator simulator;

  /// Creates a [RequestEvent] with the specified [id] and [simulator].
  const RequestEvent({required super.id, required this.simulator});
}

/// A base class for response events, extending the [Event] class.
///
/// This class is used as a foundation for specific response event
/// types such as success and failure responses.
@immutable
final class ResponseEvent extends Event {
  /// Creates a [ResponseEvent] with the specified [id].
  const ResponseEvent({required super.id});
}

/// Represents a successful response event with associated data.
///
/// This class encapsulates the success data of a specific type [T].
@immutable
final class ResponseSuccessEvent<T extends Object> extends ResponseEvent {
  /// The data associated with the successful response.
  final T data;

  /// Creates a [ResponseSuccessEvent] with the specified [id] and [data].
  const ResponseSuccessEvent({required super.id, required this.data});
}

/// Represents a failed response event with error information.
///
/// This class encapsulates the error object and stack trace for
/// debugging and error handling purposes.
@immutable
final class ResponseFailEvent extends ResponseEvent {
  /// The error that caused the response to fail.
  final Object error;

  /// The stack trace associated with the error.
  final StackTrace stackTrace;

  /// Creates a [ResponseFailEvent] with the specified [id], [error], and [stackTrace].
  const ResponseFailEvent({
    required super.id,
    required this.error,
    required this.stackTrace,
  });
}

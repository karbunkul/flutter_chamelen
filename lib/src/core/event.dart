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

  /// The simulator associated with this request.
  final Simulator simulator;

  /// Creates an [Event] with the specified [id].
  const Event({required this.id, required this.simulator});
}

/// Represents a request event associated with a specific simulator.
///
/// This class is used to encapsulate information about a request
/// and the simulator that handles it. It is marked as `@internal`
/// and intended for internal use only.
@internal
@immutable
final class RequestEvent extends Event {
  /// Creates a [RequestEvent] with the specified [id] and [simulator].
  const RequestEvent({required super.id, required super.simulator});
}

/// A generic response event representing the outcome of a simulation request.
///
/// This class encapsulates both successful and failed response scenarios
/// using a [SimulatorSnapshot]. It provides utility methods to determine
/// the response type and process it accordingly.
@immutable
final class ResponseEvent<T extends Object> extends Event {
  /// Indicates whether the response should be hidden from external observers.
  final bool? hide;

  /// The snapshot containing either a successful response or an error.
  final SimulatorSnapshot<T> snapshot;

  /// Creates a [ResponseEvent] with the specified [id], [simulator], and [snapshot].
  ///
  /// The optional [hide] flag can be used to suppress visibility in certain cases.
  const ResponseEvent({
    required super.id,
    required super.simulator,
    required this.snapshot,
    this.hide,
  });

  /// Returns `true` if the response contains an error.
  bool get isError => snapshot.hasError;

  /// Returns `true` if the response contains valid data.
  bool get isSuccess => snapshot.hasData;

  /// Handles the response based on its type.
  ///
  /// Calls [onSuccess] if the response contains valid data,
  /// or [onError] if it contains an error.
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(Object error) onError,
  }) {
    if (isSuccess) return onSuccess(snapshot.data);
    return onError(snapshot.error);
  }
}

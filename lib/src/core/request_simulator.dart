part of 'simulator.dart';

/// Abstract base class for request simulators.
///
/// Represents a simulator capable of sending requests and handling responses
/// within the application.
abstract base class RequestSimulator<T extends Object> extends Simulator<T> {
  const RequestSimulator({required super.name});

  /// Builds the simulator UI for interaction.
  /// This method must be implemented by subclasses to define the UI that
  /// enables users to interact with the simulator and send requests.
  ///
  /// - [context]: The [BuildContext] used for rendering the interface.
  /// - [handler]: An instance of [ResponseHandler<T>] that provides callbacks
  ///   for handling successful results and errors.
  Widget builder(BuildContext context, ResponseHandler<T> handler);

  /// Sends a request and waits for a response of type [T].
  ///
  /// This method sends a request through the [ChameleonScope] and listens for
  /// a matching response. The response is either a success or failure, and the
  /// corresponding result is completed in the returned [Future].
  ///
  /// Returns a [Future] that completes with the response data or an error.
  Future<T> request() async {
    final completer = Completer<T>();
    final scope = ChameleonScope();
    final request = scope.request(this);

    late final StreamSubscription subscription;

    // Listens for matching response events.
    subscription = scope.responseStream.where((e) {
      return request.id == e.id;
    }).listen((value) {
      if (value is ResponseSuccessEvent) {
        // Completes the future with the response data on success.
        completer.complete(value.data as FutureOr<T>);
      } else if (value is ResponseFailEvent) {
        // Completes the future with an error and stack trace on failure.
        completer.completeError(value.error, value.stackTrace);
      }
      // Cancels the subscription after handling the response.
      subscription.cancel();
    });

    return completer.future;
  }
}

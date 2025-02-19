part of 'simulator.dart';

/// Abstract base class for request simulators.
///
/// Represents a simulator capable of sending requests and handling responses
/// within the application.
abstract base class RequestSimulator<T extends Object> extends Simulator<T> {
  const RequestSimulator({required super.name});

  /// Sends a request and waits for a response of type [T].
  ///
  /// This method sends a request through the [ChameleonScope] and listens for
  /// a matching response. The response is either a success or failure, and the
  /// corresponding result is completed in the returned [Future].
  ///
  /// Returns a [Future] that completes with the response data or an error.
  Future<T> request() async {
    return switch (ChameleonScope().mode) {
      ChameleonMode.test => _implTestModeStrategy(),
      ChameleonMode.debug => _implDebugModeStrategy(),
      ChameleonMode.release => _implReleaseModeStrategy(),
    };
  }

  /// Implements the strategy for handling requests in **debug mode**.
  ///
  /// In this mode, the method listens to the [ChameleonScope] response stream
  /// for matching responses. Once a matching response is found, the future
  /// is completed with the corresponding data or error.
  Future<T> _implDebugModeStrategy() {
    final scope = ChameleonScope();
    final request = scope.request(this);

    late final StreamSubscription subscription;
    final completer = Completer<T>();

    // Listens for matching response events.
    subscription = scope.responseStream.where((e) {
      return request.id == e.id;
    }).listen((event) {
      event.when(onSuccess: (value) {
        completer.complete(value as T);
      }, onError: (error) {
        completer.completeError(error);
      });
      // Cancels the subscription after handling the response.
      subscription.cancel();
    });

    return completer.future;
  }

  /// Implements the strategy for handling requests in **release mode**.
  ///
  /// This mode is not yet implemented and throws an error if called.
  Future<T> _implReleaseModeStrategy() {
    throw UnimplementedError();
  }

  /// Implements the strategy for handling requests in **test mode**.
  ///
  /// In test mode, the method fetches a mocked response from the
  /// [ChameleonScope] and completes the future with the mock data. If no mock
  /// value is set, an error is thrown.
  Future<T> _implTestModeStrategy() {
    final scope = ChameleonScope();
    final mockValue = scope.getMock(runtimeType);

    if (mockValue != null) {
      final completer = Completer<T>();
      if (mockValue.$2 == MockType.value) {
        completer.complete(mockValue.$1 as T);
      } else {
        completer.completeError(mockValue.$1);
      }
      return completer.future;
    } else {
      throw ArgumentError('Does`nt set value for Mock');
    }
  }
}

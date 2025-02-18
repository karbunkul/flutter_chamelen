import 'dart:async';
import 'package:chameleon/chameleon.dart';
import 'package:flutter/widgets.dart';

import 'event.dart';

enum MockType { value, error }

typedef SimulateCallback = Function(RequestEvent, Object data);

/// Singleton class that acts as a communication scope for sending and receiving events.
/// It manages streams for both request and response events, enabling interaction
/// between simulators and the application.

class ChameleonScope {
  /// Internal singleton instance of `ChameleonScope`.
  static final ChameleonScope _singleton = ChameleonScope._internal();

  /// Factory constructor that returns the singleton instance of `ChameleonScope`.
  factory ChameleonScope() => _singleton;

  /// Private constructor for singleton initialization.
  ChameleonScope._internal();

  /// Internal [StreamController] to manage broadcast streams of [Event]s.
  final _controller = StreamController<Event>.broadcast();
  final _requestNotifier = _RequestNotifier([]);
  final _mocks = <Type, (Object, MockType)>{};
  SimulateCallback? _simulateCallback;
  ChameleonMode _mode = ChameleonMode.debug;

  /// Returns a filtered stream of events of type [T].
  ///
  /// This method is used internally to provide type-safe streams
  /// for specific event types.
  Stream<T> _filteredStream<T>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// Stream of [ResponseEvent]s.
  ///
  /// This stream emits events related to responses for specific requests.
  Stream<ResponseEvent> get responseStream {
    return _filteredStream<ResponseEvent>();
  }

  ChangeNotifier get requestNotifier => _requestNotifier;
  List<RequestEvent> get requests => List.unmodifiable(_requestNotifier.value);

  /// Sends a request event for the given [simulator].
  ///
  /// Generates a unique ID for the request and emits a [RequestEvent].
  /// Returns the created [RequestEvent] for tracking.
  ///
  /// - [simulator]: The simulator initiating the request.
  RequestEvent request(Simulator simulator) {
    final id = DateTime.now().microsecondsSinceEpoch;
    final event = RequestEvent(id: id, simulator: simulator);
    _requestNotifier.add(event);
    _controller.add(event);
    return event;
  }

  /// Sends a response event to the scope.
  ///
  /// Emits a [ResponseEvent] on the response stream. Used to deliver
  /// responses for specific requests.
  ///
  /// - [event]: The response event to be emitted.
  void response(ResponseEvent event) {
    _requestNotifier.remove(event);
    _controller.add(event);
  }

  /// The current mode of Chameleon.
  ChameleonMode get mode => _mode;

  /// Determines whether the overlay should be used.
  ///
  /// Returns `true` if the current mode is [ChameleonMode.debug].
  bool get useOverlay => _mode == ChameleonMode.debug;

  /// Sets the Chameleon mode.
  ///
  /// Updates the internal [_mode] to the given [mode].
  void setMode(ChameleonMode mode) {
    _mode = mode;
  }

  void setMock<T extends Object, S extends Simulator<T>>({
    required MockType type,
    required Object value,
  }) {
    final triggerIndex = _requestNotifier.value.indexWhere(
      (e) => e.simulator is S,
    );
    if (triggerIndex != -1) {
      final triggerEvent = _requestNotifier.value.elementAt(triggerIndex);
      _simulateCallback?.call(triggerEvent, value);
      return;
    }

    final mockValue = getMock(S);
    if (mockValue != null) {
      _mocks.remove(S);
    }

    final newValue = type == MockType.value ? value as T : value;
    _mocks.putIfAbsent(S, () => (newValue, type));
  }

  (Object, MockType)? getMock(Type runType) {
    if (_mocks.containsKey(runType)) {
      return _mocks[runType];
    }
    return null;
  }

  void setSimulateCallback(SimulateCallback callback) {
    _simulateCallback = callback;
  }
}

/// A notifier that tracks and manages a list of [RequestEvent]s.
/// It extends [ValueNotifier] to provide reactive updates when requests change.
final class _RequestNotifier extends ValueNotifier<List<RequestEvent>> {
  /// Creates a [_RequestNotifier] with an initial list of requests.
  _RequestNotifier(super.value);

  /// Adds a [RequestEvent] to the list.
  ///
  /// - If the request's simulator is of type [RequestSimulator],
  ///   it is inserted at the beginning of the list.
  /// - Otherwise, it is added to the end.
  ///
  /// After modification, [notifyListeners] is called to update listeners.
  void add(RequestEvent request) {
    if (request.simulator is RequestSimulator) {
      value.insert(0, request);
    } else {
      value.add(request);
    }

    notifyListeners();
  }

  /// Removes a [ResponseEvent] from the list by matching its `id`.
  ///
  /// - If a matching request is found and its simulator is a [RequestSimulator],
  ///   it is removed from the list, and [notifyListeners] is triggered.
  void remove(ResponseEvent request) {
    final reqIndex = value.indexWhere((r) => r.id == request.id);
    if (reqIndex != -1) {
      final request = value.elementAt(reqIndex);

      if (request.simulator is RequestSimulator) {
        value.removeAt(reqIndex);
        notifyListeners();
      }
    }
  }
}

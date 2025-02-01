import 'dart:async';
import 'package:chameleon/chameleon.dart';
import 'package:flutter/widgets.dart';

import 'event.dart';

/// Singleton class that acts as a communication scope for sending and receiving events.
/// It manages streams for both request and response events, enabling interaction
/// between simulators and the application.
@immutable
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
}

final class _RequestNotifier extends ValueNotifier<List<RequestEvent>> {
  _RequestNotifier(super.value);

  void add(RequestEvent request) {
    if (request.simulator is RequestSimulator) {
      value.insert(0, request);
    } else {
      value.add(request);
    }

    notifyListeners();
  }

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

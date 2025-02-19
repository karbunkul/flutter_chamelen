import 'dart:async';

import 'package:chameleon/chameleon.dart';
import 'package:chameleon/src/core/chameleon_scope.dart';
import 'package:chameleon/src/core/event.dart';
import 'package:chameleon/src/core/response_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

part 'request_simulator.dart';
part 'stream_simulator.dart';
part 'trigger_simulator.dart';

/// Base interface for all simulators.
///
/// This interface defines a common structure for all simulator types.
/// It ensures a consistent way of implementing request-response workflows.
/// Each simulator has a `name` for identification, and handles specific
/// request/response operations in a uniform manner across the application.
///
/// Specific simulators should extend this interface and define their
/// own behavior for processing requests and generating responses.
abstract interface class Simulator<T extends Object> {
  /// The name of the simulator.
  ///
  /// This field is used to uniquely identify each simulator instance,
  /// providing a way to differentiate between different simulators.
  final String name;

  /// Creates a [Simulator] with the specified [name] and optional flags.
  ///
  /// The [name] is used to uniquely identify the simulator, and the
  /// optional flags control the behavior of auto-closing and auto-hiding
  /// after resolving a request.
  const Simulator({required this.name});

  /// Builds the user interface for the simulator interaction.
  ///
  /// This method must be implemented by subclasses to define the UI
  /// that allows users to interact with the simulator and send requests.
  ///
  /// - [context]: The [BuildContext] used for rendering the UI.
  /// - [handler]: An instance of [ResponseHandler<T>] used to handle
  ///   successful results and errors from the simulator.
  Widget builder(BuildContext context, ResponseHandler<T> handler);

  /// Creates a [ResponseHandler<T>] to handle responses for a specific request.
  ///
  /// - [request]: The [RequestEvent] associated with this handler.
  /// - [onChanged]: A callback function that gets called when the response changes.
  ///
  /// This handler is used to handle success and error responses from the simulator.
  ResponseHandler<T> createHandler(
    RequestEvent request,
    ValueChanged<ResponseEvent> onChanged,
  ) {
    return ResponseHandler<T>(
      success: (value, {bool? hide}) => onChanged(
        ResponseEvent<T>(
          id: request.id,
          simulator: this,
          snapshot: SimulatorSnapshot<T>.success(value),
          hide: hide,
        ),
      ),
      error: (err, {bool? hide}) => onChanged(
        ResponseEvent<T>(
          id: request.id,
          simulator: this,
          snapshot: SimulatorSnapshot<T>.error(err),
          hide: hide,
        ),
      ),
    );
  }

  @internal
  @protected
  SimulatorSnapshot<T> castSnapshot(SimulatorSnapshot snapshot) {
    return snapshot.hasData
        ? SimulatorSnapshot<T>.success(snapshot.data as T)
        : SimulatorSnapshot<T>.error(snapshot.data);
  }
}

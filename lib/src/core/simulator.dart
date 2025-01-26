import 'dart:async';

import 'package:chameleon/src/core/chameleon_scope.dart';
import 'package:chameleon/src/core/event.dart';
import 'package:chameleon/src/core/response_handler.dart';
import 'package:flutter/widgets.dart';

part 'request_simulator.dart';

/// Base interface for all simulators.
///
/// This interface provides a common structure for all simulator types,
/// ensuring a consistent approach for implementing request-response workflows.
/// Each simulator can be identified by its `name` and can be used to handle
/// specific request/response operations in a uniform manner.
///
/// The `Simulator` interface is intended to be extended by specific simulators
/// that define the behavior for processing requests and generating responses.
interface class Simulator<T extends Object> {
  /// The name of the simulator.
  ///
  /// This field helps to identify the simulator instance.
  final String name;

  /// Creates a [Simulator] with the specified [name].
  ///
  /// The [name] is used to uniquely identify the simulator.
  const Simulator({required this.name});

  ResponseHandler<T> createHandler(
    RequestEvent request,
    ValueChanged<ResponseEvent> onChanged,
  ) {
    if (this is RequestSimulator<T>) {
      return ResponseHandler<T>(
        done: (value) => onChanged(
          ResponseSuccessEvent<T>(
            id: request.id,
            data: value,
          ),
        ),
        error: (err) => onChanged(
          ResponseFailEvent(
            id: request.id,
            error: err,
            stackTrace: StackTrace.current,
          ),
        ),
      );
    }

    throw UnimplementedError();
  }
}

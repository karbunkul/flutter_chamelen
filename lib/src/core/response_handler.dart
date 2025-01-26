import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// A handler for managing responses and errors in a type-safe manner.
///
/// This class is used to encapsulate callbacks for successful responses
/// and errors, allowing for cleaner and more maintainable code when dealing
/// with asynchronous operations or user interactions.
///
/// This class is marked as `@internal` and is intended for internal use only.
///
/// - [T]: The type of the expected successful response.
///
/// **Properties:**
///
/// - [done]: A callback invoked when the operation is successfully completed
///   with a value of type [T].
/// - [error]: A callback invoked when an error occurs, passing the error as
///   an `Object`.
@internal
@immutable
final class ResponseHandler<T extends Object> {
  /// Callback for handling successful responses of type [T].
  final ValueChanged<T> done;

  /// Callback for handling errors, receiving the error as an `Object`.
  final ValueChanged<Object> error;

  /// Creates a new [ResponseHandler] with the specified [done] and [error] callbacks.
  ///
  /// - [done]: The callback for successful responses.
  /// - [error]: The callback for error handling.
  const ResponseHandler({
    required this.done,
    required this.error,
  });
}

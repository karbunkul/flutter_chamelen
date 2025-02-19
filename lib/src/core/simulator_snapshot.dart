/// A snapshot that represents the state of a simulator's response.
///
/// This class encapsulates either a successful response with data of type [T]
/// or an error. It provides utility methods to determine the state and retrieve values.
class SimulatorSnapshot<T extends Object> {
  final T? _data;
  final Object? _error;

  SimulatorSnapshot._({T? data, Object? error})
      : _data = data,
        _error = error;

  /// Creates a successful snapshot containing the given [value].
  factory SimulatorSnapshot.success(T value) {
    return SimulatorSnapshot<T>._(data: value);
  }

  /// Creates an error snapshot containing the given [error].
  factory SimulatorSnapshot.error(Object error) {
    return SimulatorSnapshot<T>._(error: error);
  }

  /// Returns `true` if the snapshot contains data.
  bool get hasData => _data != null;

  /// Returns `true` if the snapshot contains an error.
  bool get hasError => _error != null;

  /// Returns the stored data if available.
  /// Throws an exception if accessed when `hasData` is `false`.
  T get data => _data!;

  /// Returns the stored error if available.
  /// Throws an exception if accessed when `hasError` is `false`.
  Object get error => _error!;

  /// Handles both success and error cases using the provided callbacks.
  ///
  /// - If the snapshot contains data, the [onData] callback is executed with the data.
  /// - If the snapshot contains an error, the [onError] callback is executed with the error.
  ///
  /// Returns the result of the executed callback.
  R when<R>({
    required R Function(T data) onData,
    required R Function(Object error) onError,
  }) {
    if (hasData) return onData(_data as T);
    return onError(_error as Object);
  }
}

import 'package:chameleon/src/core/chameleon_scope.dart';
import 'package:chameleon/src/core/simulator_snapshot.dart';
import 'package:meta/meta.dart';

import 'simulator.dart';

/// A mock class that simulates the behavior of a [Simulator] for testing purposes.
@visibleForTesting
final class FakeSimulator<T extends Object, S extends Simulator<T>> {
  const FakeSimulator._();

  /// Creates an instance of the [FakeSimulator] for a specific type [T] and [S].
  /// This is marked for testing purposes.
  @visibleForTesting
  static FakeSimulator<T, S>
      instance<T extends Object, S extends Simulator<T>>() {
    return _FakeSimulator<T, S>();
  }

  /// Simulates a successful completion of the simulator with the provided value.
  /// This is marked for testing purposes.
  @visibleForTesting
  void success(T value) => this.success(value);

  /// Simulates an error in the simulator with the provided error object.
  /// This is marked for testing purposes.
  @visibleForTesting
  void error(Object error) => this.error(error);
}

/// A private implementation of [FakeSimulator] that provides mock behavior.
final class _FakeSimulator<T extends Object, S extends Simulator<T>>
    implements FakeSimulator<T, S> {
  @override

  /// Implements the mock mechanism for simulating a successful completion.
  void success(T value) {
    ChameleonScope().simulate(SimulatorSnapshot<T>.success(value));

    // ChameleonScope().setMock<T, S>(type: MockType.value, value: value);
  }

  @override

  /// Implements the mock mechanism for simulating an error.
  void error(Object error) {
    ChameleonScope().simulate(SimulatorSnapshot<T>.error(error));
    // ChameleonScope().setMock<T, S>(type: MockType.error, value: error);
  }
}

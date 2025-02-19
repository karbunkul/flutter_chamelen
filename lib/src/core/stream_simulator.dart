part of 'simulator.dart';

abstract base class StreamSimulator<T extends Object> extends Simulator<T> {
  const StreamSimulator({required super.name});

  Stream<T> stream() {
    final scope = ChameleonScope();
    final request = scope.request(this);

    return scope.responseStream.where((e) => request.id == e.id).map((s) {
      if (s.isSuccess) {
        return s.snapshot.data as T;
      }

      if (s.isError) {
        throw s.snapshot.error;
      }
      throw UnimplementedError();
    });
  }
}

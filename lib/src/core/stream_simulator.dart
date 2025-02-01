part of 'simulator.dart';

abstract base class StreamSimulator<T extends Object> extends Simulator<T> {
  const StreamSimulator({required super.name});

  Stream<T> stream() {
    final scope = ChameleonScope();
    final request = scope.request(this);

    return scope.responseStream.where((e) => request.id == e.id).map((s) {
      if (s is ResponseSuccessEvent) {
        return s.data as T;
      }

      if (s is ResponseFailEvent) {
        throw s.error;
      }
      throw UnimplementedError();
    });
  }
}

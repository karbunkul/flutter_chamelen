part of 'simulator.dart';

abstract base class TriggerSimulator<T extends Object> extends Simulator<T> {
  const TriggerSimulator({required super.name});

  void onDispatch(BuildContext context, T data);
}

import 'dart:async';
import 'dart:math';

import 'package:chameleon/chameleon.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<int> _stream = VirtualDice(name: 'Dice').stream();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chameleon(
        mode: ChameleonMode.test,
        triggers: [
          VirtualScanner(name: '2d Scanner'),
        ],
        child: StreamBuilder(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasData) {
              return Center(child: Text(snap.data!.toString()));
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.print),
        onPressed: () async {
          try {
            FakeSimulator.instance<String, VirtualScanner>().success('12345');
            // FakeSimulator.instance<String, VirtualScanner>().error('12345');
            // FakeSimulator.instance<int, VirtualPrinter>().success(12);
            //
            // const printer = VirtualPrinter(name: 'Принтер');
            // final result = await printer.request();
            // print(result);
          } catch (e, st) {
            print(e);
            print(st);
          }
        },
      ),
    );
  }
}

final class VirtualPrinter extends RequestSimulator<int> {
  const VirtualPrinter({required super.name});

  @override
  Widget builder(context, handler) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ResponsePresetBar<int>(
            presets: [
              ResponseSuccessPreset(title: 'case 1', data: 1),
              ResponseSuccessPreset(title: 'case 2', data: 2),
              ResponseFailPreset(
                title: 'throw Exception',
                error: Exception('OOPS'),
              ),
            ],
            handler: handler,
          ),
        )
      ],
    );
  }
}

final class VirtualDice extends StreamSimulator<int> {
  VirtualDice({required super.name});

  bool _randomMode = false;

  Timer? _timer;

  @override
  Widget builder(context, handler) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ElevatedButton(
              onPressed: () {
                _randomMode = !_randomMode;
                (context as Element).markNeedsBuild();

                if (_randomMode) {
                  _timer = Timer.periodic(
                    const Duration(seconds: 2),
                    (_) {
                      final number = 1 + Random().nextInt(5);
                      handler.success(number);
                    },
                  );
                } else {
                  _timer?.cancel();
                }
              },
              child: Text('Random mode: ${_randomMode ? 'on' : 'off'}')),
        ),
        SliverToBoxAdapter(
          child: ResponsePresetBar<int>(
            presets: [
              ResponseSuccessPreset(title: 'Side 1', data: 1, hide: true),
              ResponseSuccessPreset(title: 'Side 2', data: 2, hide: true),
              ResponseSuccessPreset(title: 'Side 3', data: 3, hide: true),
              ResponseSuccessPreset(title: 'Side 4', data: 4, hide: true),
              ResponseSuccessPreset(title: 'Side 5', data: 5, hide: true),
              ResponseSuccessPreset(title: 'Side 6', data: 6, hide: true),
            ],
            handler: handler,
          ),
        )
      ],
    );
  }
}

final class VirtualScanner extends TriggerSimulator<String> {
  VirtualScanner({required super.name});

  @override
  Widget builder(context, handler) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onSubmitted: (value) {
              handler.success(value, hide: true);
            },
          ),
        ),
        ResponsePresetBar<String>(
          presets: [
            ResponseSuccessPreset(title: 'Value 1', data: 'Hello world'),
            ResponseSuccessPreset(title: 'Side 2', data: 'Foo bar'),
          ],
          handler: handler,
        )
      ],
    );
  }

  @override
  void onDispatch(BuildContext context, SimulatorSnapshot<String> snapshot) {
    snapshot.when(onData: (value) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(value)));
    }, onError: (err) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Ошибка $err')));
    });
  }
}

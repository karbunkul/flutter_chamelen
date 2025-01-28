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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chameleon(
        child: const SizedBox(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.print),
        onPressed: () async {
          try {
            final printer = VirtualPrinter(name: 'Принтер');
            final result = await printer.request();
            print(result);
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
  VirtualPrinter({required super.name});

  @override
  Widget builder(context, handler) {
    return ResponsePresetBar<int>(
      presets: [
        ResponseSuccessPreset(title: 'case 1', data: 1),
        ResponseSuccessPreset(title: 'case 2', data: 2),
        ResponseFailPreset(title: 'throw Exception', error: Exception('OOPS')),
      ],
      handler: handler,
    );
  }
}

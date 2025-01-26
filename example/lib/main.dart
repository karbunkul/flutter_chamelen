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
      body: const Chameleon(
        child: SizedBox(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => handler.done(1),
          child: const Text('case 1'),
        ),
        ElevatedButton(
          onPressed: () => handler.done(2),
          child: const Text('case 2'),
        ),
        ElevatedButton(
          onPressed: () => handler.error(Exception('УПС')),
          child: const Text('throw Exception'),
        )
      ],
    );
  }
}

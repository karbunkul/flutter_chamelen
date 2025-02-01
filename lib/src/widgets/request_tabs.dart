import 'package:chameleon/src/core/event.dart';
import 'package:flutter/material.dart';

class RequestTabs extends StatefulWidget {
  final VoidCallback onMinimize;
  final List<RequestEvent> requests;
  final ValueChanged<ResponseEvent> onDone;

  const RequestTabs({
    super.key,
    required this.requests,
    required this.onDone,
    required this.onMinimize,
  });

  @override
  _RequestTabsState createState() => _RequestTabsState();
}

class _RequestTabsState extends State<RequestTabs> {
  List<Tab> get _tabs {
    return widget.requests.map((e) {
      return Tab(text: e.simulator.name);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.requests.length,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Minimize window',
            onPressed: widget.onMinimize,
            icon: const Icon(Icons.close),
          ),
          title: const Text('Chameleon'),
          bottom: TabBar(tabs: _tabs, isScrollable: true),
        ),
        body: TabBarView(
          children: widget.requests.map(
            (e) {
              final handler = e.simulator.createHandler(e, widget.onDone);
              final content = e.simulator.builder(context, handler);

              if (content is ScrollView || content is Scrollable) {
                return content;
              }

              return SingleChildScrollView(child: content);
            },
          ).toList(),
        ),
      ),
    );
  }
}

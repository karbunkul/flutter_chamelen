import 'package:chameleon/chameleon.dart';
import 'package:chameleon/src/core/event.dart';
import 'package:flutter/material.dart';

class RequestTabs extends StatefulWidget {
  final List<RequestEvent> requests;
  final ValueChanged<ResponseEvent> onDone;

  const RequestTabs({
    super.key,
    required this.requests,
    required this.onDone,
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
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: TabBar(
                tabs: _tabs,
                isScrollable: true,
              ),
            ),
          ];
        },
        body: Builder(builder: (context) {
          return TabBarView(
            children: widget.requests.map((e) {
              if (e.simulator is RequestSimulator) {
                final simulator = e.simulator as RequestSimulator;
                return simulator.builder(
                  context,
                  e.simulator.createHandler(e, widget.onDone),
                );
              }

              return const SizedBox.shrink();
            }).toList(),
          );
        }),
      ),
    );
  }
}

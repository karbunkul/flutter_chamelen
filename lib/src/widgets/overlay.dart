import 'package:chameleon/chameleon.dart';
import 'package:chameleon/src/core/event.dart';
import 'package:chameleon/src/widgets/request_tabs.dart';
import 'package:flutter/material.dart';

import '../core/chameleon_scope.dart';

class ChameleonOverlay {
  late OverlayEntry _overlayEntry;

  void show(BuildContext context) {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry);
  }

  void hide() {
    _overlayEntry.remove();
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) => _OverlayContent(),
    );
  }
}

class _OverlayContent extends StatefulWidget {
  @override
  State<_OverlayContent> createState() => _OverlayContentState();
}

class _OverlayContentState extends State<_OverlayContent> {
  bool _minimize = false;

  @override
  Widget build(BuildContext context) {
    if (_scope.requests.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_minimize) {
      return Stack(
        children: [
          Positioned(
            right: 50,
            top: 50,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _minimize = false;
                });
              },
              icon: const Icon(
                Icons.maximize_outlined,
              ),
            ),
          )
        ],
      );
    }

    return AnimatedBuilder(
      animation: _scope.requestNotifier,
      builder: (context, child) {
        return RequestTabs(
          requests: _scope.requests,
          onDone: _onDone,
          onMinimize: () => setState(() => _minimize = true),
        );
      },
    );
  }

  ChameleonScope get _scope => ChameleonScope();

  void _onDone(ResponseEvent event) {
    if (event.simulator is TriggerSimulator) {
      final simulator = event.simulator as TriggerSimulator;

      if (event is ResponseSuccessEvent) {
        simulator.onDispatch(context,
            simulator.castSnapshot(SimulatorSnapshot.success(event.data)));
      } else if (event is ResponseFailEvent) {
        throw event.error;
      }
    } else {
      _scope.response(event);
    }

    if (event.hide == true && !_minimize) {
      setState(() => _minimize = true);
    }
  }
}

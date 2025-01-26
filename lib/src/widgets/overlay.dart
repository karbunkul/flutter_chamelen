import 'dart:async';

import 'package:chameleon/src/core/event.dart';
import 'package:chameleon/src/widgets/request_tabs.dart';
import 'package:flutter/material.dart';

import '../core/chameleon_scope.dart';

class ChameleonOverlay {
  late OverlayEntry _overlayEntry;

  ChameleonOverlay();

  void show(BuildContext context) {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry);
  }

  void hide() {
    _overlayEntry.remove();
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 96),
        child: SizedBox.expand(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: _OverlayContent(),
          ),
        ),
      ),
    );
  }
}

class _OverlayContent extends StatefulWidget {
  const _OverlayContent({super.key});

  @override
  State<_OverlayContent> createState() => _OverlayContentState();
}

class _OverlayContentState extends State<_OverlayContent> {
  final List<RequestEvent> _requests = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _subscription = _scope.requestStream.listen((request) {
      _requests.add(request);

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 96),
        child: SizedBox.expand(
          child: RequestTabs(
            requests: _requests,
            onDone: _onDone,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  ChameleonScope get _scope => ChameleonScope();

  void _onDone(value) {
    _scope.response(value);
    setState(() => _requests.removeWhere((e) => e.id == value.id));
  }
}

import 'dart:async';

import 'package:chameleon/src/core/event.dart';
import 'package:chameleon/src/widgets/request_tabs.dart';
import 'package:flutter/material.dart';

import '../../chameleon.dart';
import '../core/chameleon_scope.dart';

class ChameleonOverlay {
  final OverlayBuilder? builder;

  late OverlayEntry _overlayEntry;

  ChameleonOverlay({this.builder});

  void show(BuildContext context) {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry);
  }

  void hide() {
    _overlayEntry.remove();
  }

  OverlayBuilder get _builder {
    if (builder != null) {
      return builder!;
    }

    return (context, child) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chameleon')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      );
    };
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) => _OverlayContent(builder: _builder),
    );
  }
}

class _OverlayContent extends StatefulWidget {
  final OverlayBuilder builder;

  const _OverlayContent({required this.builder});

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

    return widget.builder(
      context,
      Material(
        color: Colors.transparent,
        child: RequestTabs(
          requests: _requests,
          onDone: _onDone,
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

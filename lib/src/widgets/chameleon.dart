import 'package:flutter/widgets.dart';

import 'overlay.dart';

typedef OverlayBuilder = Widget Function(BuildContext context, Widget child);

/// A widget that initializes and displays a [ChameleonOverlay] when added to the widget tree.
///
/// This widget wraps a [child] widget and automatically manages the lifecycle
/// of the [ChameleonOverlay], ensuring it is displayed and hidden appropriately.
class Chameleon extends StatefulWidget {
  /// The child widget to wrap.
  final Widget child;
  final OverlayBuilder? builder;

  /// Creates a [Chameleon] instance with the provided [child].
  const Chameleon({super.key, required this.child, this.builder});

  @override
  State<Chameleon> createState() => _ChameleonState();
}

class _ChameleonState extends State<Chameleon> {
  /// The instance of [ChameleonOverlay] managed by this widget.
  ChameleonOverlay? _overlay;

  @override
  void initState() {
    super.initState();
    // Ensure the overlay is displayed after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateOverlay());
  }

  void _updateOverlay() {
    if (mounted) {
      try {
        _overlay?.hide();
        _overlay = ChameleonOverlay(builder: widget.builder);
        _overlay?.show(context);
      } catch (e, stackTrace) {
        // Handle errors gracefully.
        debugPrint('Error displaying overlay: $e\n$stackTrace');
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    // Ensure the overlay is hidden when the widget is disposed.
    try {
      _overlay?.hide();
    } catch (e, stackTrace) {
      // Handle errors gracefully.
      debugPrint('Error hiding overlay: $e\n$stackTrace');
    }
    super.dispose();
  }
}

import 'package:chameleon/chameleon.dart';
import 'package:chameleon/src/core/chameleon_scope.dart';
import 'package:flutter/widgets.dart';

import 'overlay.dart';

/// Type for a function that creates a [Widget] to be displayed on top of the main content.
///
/// This function takes the context and the child widget, and creates a new widget
/// to be displayed over the main content (e.g., for creating overlays or dialogs).
typedef OverlayBuilder = Widget Function(BuildContext context, Widget child);

/// A widget that initializes and displays a [ChameleonOverlay] when added to the widget tree.
///
/// This widget wraps a [child] widget and automatically manages the lifecycle
/// of the [ChameleonOverlay], ensuring it is displayed and hidden at the appropriate times.
class Chameleon extends StatefulWidget {
  final Iterable<TriggerSimulator>? triggers;

  /// The child widget that will be wrapped by the [Chameleon] and displayed in the UI.
  final Widget child;

  /// Creates a [Chameleon] instance with the provided [child] widget and an optional set of [triggers].
  const Chameleon({
    super.key,
    required this.child,
    this.triggers,
  });

  @override
  State<Chameleon> createState() => _ChameleonState();
}

class _ChameleonState extends State<Chameleon> {
  /// The instance of [ChameleonOverlay] managed by this widget.
  ChameleonOverlay? _overlay;

  @override
  void initState() {
    super.initState();

    _initTriggers();

    // After the first frame is rendered, update the overlay if needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOverlay();
    });
  }

  /// Updates the display of [ChameleonOverlay], hiding the old one and showing a new one.
  void _updateOverlay() {
    if (mounted) {
      try {
        _overlay?.hide(); // Hide the current overlay if it exists.
        _overlay = ChameleonOverlay(); // Create a new overlay.
        _overlay?.show(context); // Show the new overlay.
      } catch (e, stackTrace) {
        // Log any error that occurs while displaying the overlay.
        debugPrint('Error displaying overlay: $e\n$stackTrace');
      }
    }
  }

  @override
  Widget build(context) => widget.child;

  @override
  void dispose() {
    // Ensure the overlay is hidden when the widget is disposed.
    try {
      _overlay?.hide();
    } catch (e, stackTrace) {
      // Log any error that occurs while hiding the overlay.
      debugPrint('Error hiding overlay: $e\n$stackTrace');
    }
    super.dispose();
  }

  /// Initializes triggers if they were provided in the widget's constructor.
  /// Each trigger is requested and added to the [ChameleonScope].
  void _initTriggers() {
    if (widget.triggers?.isNotEmpty == true) {
      final scope = ChameleonScope();
      for (final trigger in widget.triggers!) {
        scope.request(trigger); // Request the trigger for handling.
      }
    }
  }
}

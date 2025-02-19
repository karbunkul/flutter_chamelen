import 'package:chameleon/src/core/response_handler.dart';
import 'package:flutter/material.dart';

enum ResponseBehavior {
  success,
  fail,
}

interface class ResponsePreset<T extends Object> {
  final String title;
  final ResponseBehavior behavior;
  final bool? hide;

  ResponsePreset({required this.title, required this.behavior, this.hide});
}

final class ResponseSuccessPreset<T extends Object> extends ResponsePreset<T> {
  final T data;
  ResponseSuccessPreset({
    required super.title,
    required this.data,
    super.hide,
  }) : super(behavior: ResponseBehavior.success);
}

final class ResponseFailPreset<T extends Object> extends ResponsePreset<T> {
  final Object error;
  ResponseFailPreset({
    required super.title,
    required this.error,
    super.hide,
  }) : super(behavior: ResponseBehavior.success);
}

class ResponsePresetBar<T extends Object> extends StatefulWidget {
  final ResponseHandler<T> handler;
  final Iterable<ResponsePreset<T>> presets;

  const ResponsePresetBar({
    super.key,
    required this.handler,
    required this.presets,
  });

  @override
  State<ResponsePresetBar<T>> createState() => _ResponsePresetBarState<T>();
}

class _ResponsePresetBarState<T extends Object>
    extends State<ResponsePresetBar<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _filtered,
    );
  }

  Icon _icon(ResponsePreset preset) {
    if (preset is ResponseFailPreset) {
      return const Icon(
        Icons.error_outline_outlined,
        color: Colors.red,
      );
    }
    return const Icon(
      Icons.info_outline,
      color: Colors.green,
    );
  }

  List<Widget> get _filtered {
    return widget.presets
        .where((e) => true)
        .map(
          (e) => TextButton.icon(
            icon: _icon(e),
            onPressed: () {
              if (e is ResponseFailPreset<T>) {
                final error = e as ResponseFailPreset;
                widget.handler.error(error.error, hide: error.hide);
              } else if (e is ResponseSuccessPreset<T>) {
                widget.handler.success(e.data, hide: e.hide);
              }
            },
            label: Text(e.title),
          ),
        )
        .toList(growable: false);
  }
}

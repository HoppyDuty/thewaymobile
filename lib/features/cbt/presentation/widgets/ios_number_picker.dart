import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// A `CupertinoPicker` wheel for choosing one value from a fixed list —
/// used for question-count/duration/year selection so those feel like the
/// familiar iOS scroll-wheel rather than a generic dropdown.
class IosNumberPicker extends StatefulWidget {
  const IosNumberPicker({
    super.key,
    required this.values,
    required this.initialValue,
    required this.onChanged,
    this.label,
    this.suffix,
  });

  final List<int> values;
  final int initialValue;
  final ValueChanged<int> onChanged;
  final String? label;
  final String? suffix;

  @override
  State<IosNumberPicker> createState() => _IosNumberPickerState();
}

class _IosNumberPickerState extends State<IosNumberPicker> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    final index = widget.values.indexOf(widget.initialValue);
    _controller = FixedExtentScrollController(initialItem: index < 0 ? 0 : index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
        ],
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: AppRadius.mdRadius,
          ),
          child: CupertinoPicker(
            scrollController: _controller,
            itemExtent: 38,
            useMagnifier: true,
            magnification: 1.15,
            onSelectedItemChanged: (index) => widget.onChanged(widget.values[index]),
            selectionOverlay: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
              ),
            ),
            children: [
              for (final v in widget.values)
                Center(child: Text(widget.suffix != null ? '$v ${widget.suffix}' : '$v')),
            ],
          ),
        ),
      ],
    );
  }
}

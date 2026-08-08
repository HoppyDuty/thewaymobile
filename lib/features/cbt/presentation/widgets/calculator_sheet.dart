import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

Future<void> showCalculatorSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _CalculatorSheet(),
  );
}

/// A simple 4-function calculator available from the exam screen — most
/// Nigerian exam boards (WAEC/NECO/UTME) permit a non-programmable
/// calculator for numeric subjects, so this stands in for that.
class _CalculatorSheet extends StatefulWidget {
  const _CalculatorSheet();

  @override
  State<_CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<_CalculatorSheet> {
  String _display = '0';
  double? _stored;
  String? _pendingOp;
  bool _shouldReplaceDisplay = false;

  static const _buttons = [
    ['C', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  void _onTap(String label) {
    setState(() {
      switch (label) {
        case 'C':
          _display = '0';
          _stored = null;
          _pendingOp = null;
          _shouldReplaceDisplay = false;
        case '±':
          _display = _formatted(_parsed(_display) * -1);
        case '%':
          _display = _formatted(_parsed(_display) / 100);
        case '÷':
        case '×':
        case '-':
        case '+':
          _stored = _parsed(_display);
          _pendingOp = label;
          _shouldReplaceDisplay = true;
        case '=':
          if (_stored != null && _pendingOp != null) {
            _display = _formatted(_apply(_stored!, _parsed(_display), _pendingOp!));
            _stored = null;
            _pendingOp = null;
            _shouldReplaceDisplay = true;
          }
        case '.':
          if (!_display.contains('.')) _display = _shouldReplaceDisplay ? '0.' : '$_display.';
          _shouldReplaceDisplay = false;
        default:
          if (_shouldReplaceDisplay || _display == '0') {
            _display = label;
          } else {
            _display += label;
          }
          _shouldReplaceDisplay = false;
      }
    });
  }

  double _parsed(String value) => double.tryParse(value) ?? 0;

  String _formatted(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  double _apply(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: MediaQuery.viewPaddingOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                _display,
                style: theme.textTheme.displaySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          for (final row in _buttons)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  for (final label in row)
                    Expanded(
                      flex: label == '0' ? 2 : 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _CalcButton(label: label, onTap: () => _onTap(label)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  const _CalcButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  bool get _isOperator => const {'÷', '×', '-', '+', '='}.contains(label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1.3,
      child: Material(
        color: _isOperator ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.mdRadius,
        child: InkWell(
          borderRadius: AppRadius.mdRadius,
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: _isOperator ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

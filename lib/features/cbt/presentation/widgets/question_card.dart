import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/question_model.dart';

/// Renders a single question — every shape present in the seeder:
/// objective (lettered options, optionally with images), theory/practical
/// (free-text answer), and any `specialType` (normal/comprehension/register/
/// literature — the passage itself is shown by the caller once per block,
/// not repeated per question). Doubles as both the interactive exam-screen
/// widget (pass [onAnswerChanged]) and the read-only review-screen widget
/// (omit it, optionally pass [showCorrection] to reveal right/wrong).
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.subjectName,
    this.topicName,
    this.questionNumber,
    this.selectedAnswer,
    this.onAnswerChanged,
    this.isBookmarked = false,
    this.onToggleBookmark,
    this.onAskAi,
    this.showCorrection = false,
    this.orderedOptions,
  });

  final QuestionModel question;
  final String subjectName;
  final String? topicName;
  final int? questionNumber;
  final String? selectedAnswer;
  final ValueChanged<String?>? onAnswerChanged;
  final bool isBookmarked;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onAskAi;
  final bool showCorrection;

  /// This attempt's shuffled option order (see
  /// `ExamSessionState.orderedOptionsFor`) — falls back to the question's
  /// natural database order when omitted (e.g. the read-only bookmark
  /// viewer, which has no exam session/shuffle to pull from).
  final List<OptionModel>? orderedOptions;

  static const _typeLabels = {
    'objective': 'Objective',
    'theory': 'Theory',
    'practical': 'Practical',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(subjectName),
                ),
                if (topicName != null)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(topicName!),
                  ),
                if (question.year != null)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text('${question.year}'),
                  ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(_typeLabels[question.questionType] ?? question.questionType),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (questionNumber != null) ...[
                  Text('$questionNumber.', style: theme.textTheme.titleMedium),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Expanded(child: Text(question.body, style: theme.textTheme.bodyLarge)),
                if (onToggleBookmark != null)
                  IconButton(
                    icon: Icon(isBookmarked ? AppIcons.bookmarkSelected : AppIcons.bookmark),
                    color: isBookmarked ? theme.colorScheme.primary : null,
                    tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark this question',
                    onPressed: onToggleBookmark,
                  ),
                if (onAskAi != null)
                  IconButton(
                    icon: const Icon(AppIcons.sparkles),
                    tooltip: 'Ask Shepherd about this question',
                    onPressed: onAskAi,
                  ),
              ],
            ),
            if (question.bodyImageUrl != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.mdRadius,
                child: AppNetworkImage(url: question.bodyImageUrl, height: 160),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (question.isObjective) _buildOptions(context) else _buildFreeTextAnswer(context),
          ],
        ),
      ),
    );
  }

  static const _positionLabels = ['A', 'B', 'C', 'D', 'E'];

  Widget _buildOptions(BuildContext context) {
    final theme = Theme.of(context);
    final options = orderedOptions ?? question.options;

    return Column(
      children: [
        for (final (index, option) in options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _OptionTile(
              option: option,
              // The badge shows this option's *position* (A, B, C…) in the
              // shuffled display order, not its original database letter —
              // otherwise a shuffled list would show non-sequential badges
              // like "C, A, D, B". Correctness still keys off `option.key`
              // (the stable original letter), never this display position.
              displayLabel: index < _positionLabels.length ? _positionLabels[index] : '${index + 1}',
              selected: selectedAnswer?.toLowerCase() == option.key,
              onTap: onAnswerChanged != null ? () => onAnswerChanged!(option.key) : null,
              status: !showCorrection
                  ? _OptionStatus.neutral
                  : option.key == (question.correctOption ?? '').toLowerCase()
                  ? _OptionStatus.correct
                  : (selectedAnswer?.toLowerCase() == option.key ? _OptionStatus.wrong : _OptionStatus.neutral),
            ),
          ),
        if (showCorrection && question.explanation != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explanation', style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(question.explanation!),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFreeTextAnswer(BuildContext context) {
    if (onAnswerChanged != null) {
      return _FreeTextAnswerField(
        key: ValueKey(question.id),
        initialValue: selectedAnswer,
        onChanged: onAnswerChanged!,
      );
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your answer', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(selectedAnswer?.isNotEmpty == true ? selectedAnswer! : 'No answer submitted.'),
        if (showCorrection && question.correctAnswerText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Model answer', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(question.correctAnswerText!),
        ],
      ],
    );
  }
}

/// Isolated so its [TextEditingController] survives parent rebuilds (the
/// exam screen rebuilds every second for the timer) without losing cursor
/// position or dropping keystrokes — only reset when the question changes,
/// via the `ValueKey(question.id)` the caller supplies.
class _FreeTextAnswerField extends StatefulWidget {
  const _FreeTextAnswerField({super.key, required this.initialValue, required this.onChanged});

  final String? initialValue;
  final ValueChanged<String?> onChanged;

  @override
  State<_FreeTextAnswerField> createState() => _FreeTextAnswerFieldState();
}

class _FreeTextAnswerFieldState extends State<_FreeTextAnswerField> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: 6,
      minLines: 3,
      decoration: const InputDecoration(
        hintText: 'Write your answer…',
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
    );
  }
}

enum _OptionStatus { neutral, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.displayLabel,
    required this.selected,
    required this.onTap,
    required this.status,
  });

  final OptionModel option;
  final String displayLabel;
  final bool selected;
  final VoidCallback? onTap;
  final _OptionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color borderColor = theme.colorScheme.outlineVariant;
    Color? fillColor;
    IconData? trailingIcon;

    switch (status) {
      case _OptionStatus.correct:
        borderColor = context.appColors.success;
        fillColor = context.appColors.success.withValues(alpha: 0.08);
        trailingIcon = AppIcons.success;
      case _OptionStatus.wrong:
        borderColor = theme.colorScheme.error;
        fillColor = theme.colorScheme.error.withValues(alpha: 0.08);
        trailingIcon = AppIcons.error;
      case _OptionStatus.neutral:
        if (selected) {
          borderColor = theme.colorScheme.primary;
          fillColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
        }
    }

    return Material(
      color: fillColor ?? Colors.transparent,
      borderRadius: AppRadius.mdRadius,
      child: InkWell(
        borderRadius: AppRadius.mdRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: AppRadius.mdRadius,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  displayLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(option.text)),
              if (option.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: ClipRRect(
                    borderRadius: AppRadius.smRadius,
                    child: AppNetworkImage(url: option.imageUrl, width: 40, height: 40),
                  ),
                ),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(trailingIcon, color: borderColor, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

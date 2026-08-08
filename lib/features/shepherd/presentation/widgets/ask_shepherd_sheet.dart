import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../data/shepherd_api.dart';

/// Bottom sheet for a question's "explain this" action (rich HTML
/// explanation + common mistakes + key concepts, cached server-side).
Future<void> showQuestionExplanationSheet(BuildContext context, WidgetRef ref, int questionId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ShepherdSheetScaffold(
      future: ref.read(shepherdApiProvider).explainQuestion(questionId),
      builder: (context, explanation) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Html(data: explanation.explanation),
          if (explanation.keyConcepts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Key Concepts', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: AppSpacing.xs,
              children: [for (final c in explanation.keyConcepts) Chip(label: Text(c))],
            ),
          ],
          if (explanation.commonMistakes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Common Mistakes', style: Theme.of(context).textTheme.titleSmall),
            for (final m in explanation.commonMistakes)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('• '), Expanded(child: Text(m))],
                ),
              ),
          ],
        ],
      ),
    ),
  );
}

/// Bottom sheet for a free-form "ask Shepherd about X" action (dictionary
/// words, etc.) — a single one-shot message, no conversation history.
Future<void> showQuickAskSheet(BuildContext context, WidgetRef ref, {required String title, required String prompt}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ShepherdSheetScaffold(
      title: title,
      future: ref.read(shepherdApiProvider).quickAsk(prompt),
      builder: (context, message) => Text(message, style: Theme.of(context).textTheme.bodyMedium),
    ),
  );
}

class _ShepherdSheetScaffold<T> extends StatelessWidget {
  const _ShepherdSheetScaffold({required this.future, required this.builder, this.title});

  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: AppRadius.smRadius,
                    ),
                    child: Icon(Icons.auto_awesome, size: 18, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(title ?? 'Ask Shepherd', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FutureBuilder<T>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return AppErrorState(message: mapErrorToMessage(snapshot.error!));
                  }
                  return builder(context, snapshot.data as T);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

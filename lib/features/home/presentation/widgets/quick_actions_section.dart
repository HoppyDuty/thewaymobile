import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../cbt/presentation/widgets/exam_type_picker_sheet.dart';

class _QuickAction {
  const _QuickAction({required this.icon, required this.label, this.route});
  final IconData icon;
  final String label;

  /// Null for actions that open a modal instead of navigating directly
  /// (Topical Study — see [QuickActionsSection._onTap]).
  final String? route;
}

/// `app_flow.md`'s home quick-actions: Topical Study, Dictionary, My
/// Videos (downloaded), My Questions (bookmarked), My Books (downloaded).
/// My Videos/My Books route into features not built yet (Video/Books
/// phases) — the routes exist as placeholders there for now.
const _quickActions = [
  _QuickAction(icon: Icons.topic_outlined, label: 'Topical\nStudy'),
  _QuickAction(icon: Icons.menu_book_outlined, label: 'Dictionary', route: '/dictionary'),
  _QuickAction(icon: Icons.video_library_outlined, label: 'My\nVideos', route: '/videos/downloads'),
  _QuickAction(icon: Icons.bookmark_outline, label: 'My\nQuestions', route: '/cbt/bookmarks'),
  _QuickAction(icon: Icons.library_books_outlined, label: 'My\nBooks', route: '/books/saved'),
];

class QuickActionsSection extends ConsumerWidget {
  const QuickActionsSection({super.key});

  void _onTap(BuildContext context, WidgetRef ref, _QuickAction action) {
    if (action.route != null) {
      context.push(action.route!);
    } else {
      showTopicalExamTypePicker(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _quickActions.map((action) {
        return Expanded(
          child: InkWell(
            borderRadius: AppRadius.mdRadius,
            onTap: () => _onTap(context, ref, action),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: Icon(action.icon, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

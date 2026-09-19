import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/chat_models.dart';
import '../providers/conversations_controller.dart';
import '../providers/quotas_controller.dart';

/// Entry point for the full Shepherd experience — conversation history,
/// plus the weak-area analysis and study-plan generator. Reached from a
/// "Ask Shepherd" FAB on Home (the "Ask AI" buttons scattered through
/// CBT/Dictionary use the lighter one-shot sheet instead, not this).
class ShepherdHomeScreen extends ConsumerStatefulWidget {
  const ShepherdHomeScreen({super.key});

  @override
  ConsumerState<ShepherdHomeScreen> createState() => _ShepherdHomeScreenState();
}

class _ShepherdHomeScreenState extends ConsumerState<ShepherdHomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      ref.read(conversationsControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _delete(String uuid) async {
    try {
      await ref.read(conversationsControllerProvider.notifier).delete(uuid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conversationsState = ref.watch(conversationsControllerProvider);
    final quotasState = ref.watch(quotasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shepherd AI Tutor')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/shepherd/chat'),
        icon: const Icon(AppIcons.newChat),
        label: const Text('New Chat'),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          quotasState.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (quotas) => quotas.chat != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      '${quotas.chat!.remaining} of ${quotas.chat!.limit} chat messages left today',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Row(
            children: [
              Expanded(
                child: _ToolCard(
                  icon: AppIcons.insights,
                  label: 'Weak Areas',
                  onTap: () => context.push('/shepherd/weak-areas'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ToolCard(
                  icon: AppIcons.calendar,
                  label: 'Study Plan',
                  onTap: () => context.push('/shepherd/study-plan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Conversations', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          conversationsState.when(
            loading: () => AppShimmer(
              child: Column(children: [for (var i = 0; i < 4; i++) const ShimmerListTile()]),
            ),
            error: (error, _) => AppErrorState(
              message: mapErrorToMessage(error),
              onRetry: () => ref.invalidate(conversationsControllerProvider),
            ),
            data: (data) {
              if (data.items.isEmpty) {
                return const AppEmptyState(
                  title: 'No conversations yet',
                  message: 'Tap "New Chat" to start asking Shepherd anything about your exams.',
                  icon: Icons.chat_bubble_outline,
                );
              }
              return Column(
                children: [
                  for (final conversation in data.items)
                    _ConversationTile(conversation: conversation, onDelete: () => _delete(conversation.uuid)),
                  if (data.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: InkWell(
        borderRadius: AppRadius.lgRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: theme.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onDelete});

  final ConversationSummary conversation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        leading: const CircleAvatar(child: Icon(Icons.smart_toy_outlined)),
        title: Text(conversation.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          conversation.lastMessageAt != null
              ? DateFormat.yMMMd().add_jm().format(conversation.lastMessageAt!)
              : '${conversation.messageCount} messages',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
        onTap: () => context.push('/shepherd/chat/${conversation.uuid}'),
      ),
    );
  }
}

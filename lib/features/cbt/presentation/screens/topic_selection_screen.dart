import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_setup.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../providers/cbt_flow_args.dart';

/// Topic picker for [ExamMode.topical] — reads topics for the one selected
/// subject straight from the locally-synced `SubjectModel.topics`.
class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({super.key, required this.args});

  final CbtFlowArgs args;

  @override
  Widget build(BuildContext context) {
    final subjectId = args.subjectIds.first;
    final subject = HiveSetup.subjectsBox.get(subjectId);
    final topics = subject?.topics ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(subject?.name ?? 'Topics')),
      body: topics.isEmpty
          ? const AppEmptyState(
              title: 'No topics synced for this subject',
              message: 'Connect to the internet to sync the full subject/topic list.',
              icon: Icons.topic_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
                    title: Text(topic.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/cbt/setup', extra: args.copyWith(topicId: topic.id)),
                  ),
                );
              },
            ),
    );
  }
}

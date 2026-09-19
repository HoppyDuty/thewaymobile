import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../data/models/exam_type_model.dart';
import '../../data/models/offline_session_model.dart';

/// Carries the in-progress exam-setup selection between screens
/// (exam type → mode → subjects → topic → setup → exam), passed via
/// go_router's `extra` since this flow is never deep-linked.
class CbtFlowArgs {
  const CbtFlowArgs({
    required this.examType,
    required this.mode,
    this.subjectIds = const [],
    this.topicId,
  });

  final ExamTypeModel examType;
  final String mode;
  final List<int> subjectIds;
  final int? topicId;

  bool get isEnglishOnlySelection =>
      subjectIds.length == 1 && examType.subjects.any((s) => s.id == subjectIds.first && s.isEnglish);

  CbtFlowArgs copyWith({List<int>? subjectIds, int? topicId}) {
    return CbtFlowArgs(
      examType: examType,
      mode: mode,
      subjectIds: subjectIds ?? this.subjectIds,
      topicId: topicId ?? this.topicId,
    );
  }
}

/// Human-readable label/description for each of the 5 exam modes — shown
/// on the mode-selection screen so the rules are visible up front rather
/// than discovered mid-setup.
class ExamModeInfo {
  const ExamModeInfo({required this.mode, required this.title, required this.description, required this.icon});

  final String mode;
  final String title;
  final String description;
  final IconData icon;

  static const all = [
    ExamModeInfo(
      mode: ExamMode.standard,
      title: 'Standard Exam',
      description: 'Full timed mock exam with the real subject count and duration for this exam type.',
      icon: AppIcons.checklist,
    ),
    ExamModeInfo(
      mode: ExamMode.yearly,
      title: 'Yearly (Past Questions)',
      description: "A full timed exam built entirely from one past year's real questions.",
      icon: AppIcons.history,
    ),
    ExamModeInfo(
      mode: ExamMode.practice,
      title: 'Practice',
      description: 'Choose your own question count and an optional timer — great for quick drills.',
      icon: AppIcons.practice,
    ),
    ExamModeInfo(
      mode: ExamMode.study,
      title: 'Study Mode',
      description: 'Untimed, questions in a fixed order — work through a subject at your own pace.',
      icon: AppIcons.book,
    ),
    ExamModeInfo(
      mode: ExamMode.topical,
      title: 'Topical Study',
      description: 'Pick one subject and one topic and drill just that area, untimed.',
      icon: AppIcons.topic,
    ),
  ];
}

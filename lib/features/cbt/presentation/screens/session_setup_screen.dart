import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/hive_setup.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/offline_session_model.dart';
import '../../data/services/offline_question_builder.dart';
import '../providers/cbt_flow_args.dart';
import '../providers/pending_exam_configs.dart';
import '../widgets/ios_number_picker.dart';

/// Final setup step before an exam starts — the exact fields shown depend
/// on the chosen mode:
/// - Standard/Yearly: fixed question count & duration (info only), plus
///   English comprehension/register/literature toggles when applicable.
///   Yearly additionally requires an (iOS wheel) year picker.
/// - Practice: iOS wheel question-count picker + optional duration wheel.
/// - Study/Topical: iOS wheel question-count picker only, always untimed.
class SessionSetupScreen extends ConsumerStatefulWidget {
  const SessionSetupScreen({super.key, required this.args});

  final CbtFlowArgs args;

  @override
  ConsumerState<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends ConsumerState<SessionSetupScreen> {
  static const _questionCounts = [5, 10, 15, 20, 30, 40, 50, 60, 80, 100];
  static const _durations = [10, 15, 20, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 480];

  late int _questionCount;
  late int? _duration;
  late bool _isTimed;
  late int _year;
  bool _includeComprehension = true;
  bool _includeRegister = true;
  bool _includeLiterature = true;

  bool get _isStandardOrYearly => widget.args.mode == ExamMode.standard || widget.args.mode == ExamMode.yearly;
  bool get _isYearly => widget.args.mode == ExamMode.yearly;
  bool get _isPractice => widget.args.mode == ExamMode.practice;

  List<int> get _availableYears {
    final years = HiveSetup.questionsBox.values
        .where((q) => q.examTypeId == widget.args.examType.id && q.year != null)
        .map((q) => q.year!)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (years.isEmpty) {
      final current = DateTime.now().year;
      return [for (var y = current; y >= current - 15; y--) y];
    }
    return years;
  }

  @override
  void initState() {
    super.initState();
    _questionCount = 20;
    _duration = 30;
    _isTimed = _isPractice ? false : true;
    _year = _availableYears.first;
  }

  bool get _showsEnglishBlocks {
    final examType = widget.args.examType;
    if (!_isStandardOrYearly) return false;
    if (!(examType.hasComprehension || examType.hasRegister || examType.hasLiterature)) return false;
    return widget.args.examType.subjects.any((s) => s.isEnglish && widget.args.subjectIds.contains(s.id));
  }

  void _startExam() {
    final examType = widget.args.examType;
    final config = SessionConfig(
      examTypeId: examType.id,
      mode: widget.args.mode,
      subjectIds: widget.args.subjectIds,
      questionType: examType.hasTheory ? 'all' : 'objective',
      year: _isYearly ? _year : null,
      topicId: widget.args.topicId,
      questionCount: _isStandardOrYearly ? null : _questionCount,
      includeComprehension: _includeComprehension,
      includeRegister: _includeRegister,
      includeLiterature: _includeLiterature,
    );

    final durationMinutes = _isStandardOrYearly
        ? examType.standardDurationMinutes
        : (_isPractice && _isTimed ? _duration : null);

    final sessionKey = const Uuid().v4();
    ref
        .read(pendingExamConfigsProvider.notifier)
        .put(sessionKey, ExamLaunchConfig(examType: examType, sessionConfig: config, durationMinutes: durationMinutes));

    context.push('/cbt/exam/$sessionKey');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Setup')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (_isStandardOrYearly) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Exam Format', style: theme.textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Duration: ${widget.args.examType.standardDurationMinutes} minutes'),
                          Text(
                            'Questions per subject: ${widget.args.subjectIds.length} subject(s) selected — '
                            'standard counts per subject.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (_isYearly) ...[
                  IosNumberPicker(
                    label: 'Exam Year',
                    values: _availableYears,
                    initialValue: _year,
                    onChanged: (v) => setState(() => _year = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (!_isStandardOrYearly) ...[
                  IosNumberPicker(
                    label: 'Number of Questions',
                    values: _questionCounts,
                    initialValue: _questionCount,
                    onChanged: (v) => setState(() => _questionCount = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (_isPractice) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Set a time limit'),
                    value: _isTimed,
                    onChanged: (v) => setState(() => _isTimed = v),
                  ),
                  if (_isTimed)
                    IosNumberPicker(
                      label: 'Duration',
                      values: _durations,
                      initialValue: _duration ?? 30,
                      suffix: 'min',
                      onChanged: (v) => setState(() => _duration = v),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (_showsEnglishBlocks) ...[
                  Text('English Passage Blocks', style: theme.textTheme.titleSmall),
                  if (widget.args.examType.hasComprehension)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include Comprehension passage'),
                      value: _includeComprehension,
                      onChanged: (v) => setState(() => _includeComprehension = v),
                    ),
                  if (widget.args.examType.hasRegister)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include Register passage'),
                      value: _includeRegister,
                      onChanged: (v) => setState(() => _includeRegister = v),
                    ),
                  if (widget.args.examType.hasLiterature)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include Literature passage'),
                      value: _includeLiterature,
                      onChanged: (v) => setState(() => _includeLiterature = v),
                    ),
                ],
              ],
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(label: 'Start Exam', onPressed: _startExam, icon: AppIcons.play),
          ),
        ],
      ),
    );
  }
}

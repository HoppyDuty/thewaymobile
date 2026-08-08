import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/offline_session_model.dart';
import '../providers/cbt_flow_args.dart';

/// Subject picker — single-select for [ExamMode.topical] (topical study is
/// always one subject → one topic), multi-select bounded by
/// `examType.minSubjects`/`maxSubjects` for every other mode, with the
/// English subject auto-locked-in when `englishCompulsory` is set (matches
/// `StartSessionRequest`'s `subject_ids` contract exactly).
class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key, required this.args});

  final CbtFlowArgs args;

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  late final Set<int> _selected;
  late final bool _isTopical;
  late final bool _isSingleSelect;

  @override
  void initState() {
    super.initState();
    _isTopical = widget.args.mode == ExamMode.topical;
    _isSingleSelect = _isTopical;
    _selected = {};

    if (widget.args.examType.englishCompulsory && !_isSingleSelect) {
      final english = widget.args.examType.subjects.where((s) => s.isEnglish);
      if (english.isNotEmpty) _selected.add(english.first.id);
    }
  }

  int get _maxSubjects => _isSingleSelect ? 1 : widget.args.examType.maxSubjects;
  int get _minSubjects => _isSingleSelect ? 1 : widget.args.examType.minSubjects;

  void _toggle(int subjectId, bool isEnglish) {
    setState(() {
      if (_isSingleSelect) {
        _selected
          ..clear()
          ..add(subjectId);
        return;
      }
      if (_selected.contains(subjectId)) {
        if (isEnglish && widget.args.examType.englishCompulsory) return; // locked in
        _selected.remove(subjectId);
      } else {
        if (_selected.length >= _maxSubjects) return;
        _selected.add(subjectId);
      }
    });
  }

  void _continue() {
    final next = widget.args.copyWith(subjectIds: _selected.toList());
    if (_isTopical) {
      context.push('/cbt/topics', extra: next);
    } else {
      context.push('/cbt/setup', extra: next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = widget.args.examType.subjects;
    final canContinue = _selected.length >= _minSubjects && _selected.length <= _maxSubjects;

    return Scaffold(
      appBar: AppBar(title: Text(_isSingleSelect ? 'Choose a Subject' : 'Choose Subjects')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: Text(
              _isSingleSelect
                  ? 'Pick the subject you want to study by topic.'
                  : 'Pick $_minSubjects–$_maxSubjects subjects for this exam.'
                        '${widget.args.examType.englishCompulsory ? ' English is compulsory.' : ''}',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final selected = _selected.contains(subject.id);
                final locked = subject.isEnglish && widget.args.examType.englishCompulsory && !_isSingleSelect;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: locked ? null : (_) => _toggle(subject.id, subject.isEnglish),
                    title: Text(subject.name),
                    subtitle: locked ? const Text('Compulsory') : null,
                    controlAffinity: ListTileControlAffinity.leading,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: 'Continue',
              onPressed: canContinue ? _continue : null,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/models/learning_models.dart';
import '../../core/services/app_state_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/design/design_tokens.dart';
import '../../core/widgets/core_components.dart';

class QuizArenaScreen extends StatefulWidget {
  final Lesson lesson;

  const QuizArenaScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  State<QuizArenaScreen> createState() => _QuizArenaScreenState();
}

class _QuizArenaScreenState extends State<QuizArenaScreen> {
  int _currentIndex = 0;
  bool _hasAnswered = false;
  bool _isAnswerCorrect = false;
  String _selectedWhyWrong = '';

  // توقيت الإجابة لحساب زمن التفكير (Research metric: durationMs)
  late DateTime _questionStartTime;

  // إجابات كل نوع من الأسئلة
  int? _selectedSingleIndex;
  final Set<int> _selectedMultiIndices = {};
  List<String> _shuffledOrderItems = [];
  final TextEditingController _fillBlankController = TextEditingController();
  final Map<String, String> _userPairs = {};
  List<String> _shuffledRightValues = []; // محمي من إعادة الخلط في كل بناء
  String? _selectedLeftPair;
  bool? _selectedTrueFalse;

  @override
  void initState() {
    super.initState();
    _setupQuestion(widget.lesson.quizzes.isNotEmpty ? widget.lesson.quizzes[0] : null);
  }

  void _setupQuestion(QuizQuestion? q) {
    _hasAnswered = false;
    _isAnswerCorrect = false;
    _selectedWhyWrong = '';
    _selectedSingleIndex = null;
    _selectedMultiIndices.clear();
    _fillBlankController.clear();
    _userPairs.clear();
    _selectedLeftPair = null;
    _selectedTrueFalse = null;
    _questionStartTime = DateTime.now();

    if (q != null) {
      if (q.type == QuizType.codeOrdering) {
        _shuffledOrderItems = List<String>.from(q.orderItems)..shuffle();
      } else if (q.type == QuizType.pairMatching) {
        _shuffledRightValues = q.pairs.values.toList()..shuffle();
      }
    }
  }

  @override
  void dispose() {
    _fillBlankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18nService.instance;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quizzes = widget.lesson.quizzes;

    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: EmptyState(
          icon: Icons.assignment_outlined,
          title: i18n.t('empty_quizzes_title'),
          reason: i18n.t('empty_quizzes_reason'),
          actionLabel: i18n.t('finish_lesson'),
          onAction: () {
            AppStateService.instance.completeLesson(widget.lesson.id, widget.lesson.xpReward);
            Navigator.pop(context, true);
          },
        ),
      );
    }

    final currentQuiz = quizzes[_currentIndex];
    final progress = (_currentIndex + 1) / quizzes.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.lesson.title} (${_currentIndex + 1}/${quizzes.length})'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 6,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomEvaluationBar(currentQuiz, i18n),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شارة نوع السؤال
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: Text(
                _getQuizTypeBadge(currentQuiz.type, i18n),
                style: AppTypography.caption.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: Space.md),

            // نص السؤال
            Text(
              currentQuiz.localizedPrompt(i18n.isArabic),
              style: AppTypography.questionPrompt.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: Space.xl),

            // بناء المحتوى التفاعلي الخاص بكل نوع
            _buildInteractiveQuestionBody(currentQuiz),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveQuestionBody(QuizQuestion q) {
    switch (q.type) {
      case QuizType.singleChoice:
      case QuizType.caseStudy:
        return _buildSingleChoiceList(q);
      case QuizType.multipleChoice:
        return _buildMultipleChoiceList(q);
      case QuizType.codeOrdering:
        return _buildOrderingList(q);
      case QuizType.fillInBlank:
        return _buildFillInBlank(q);
      case QuizType.pairMatching:
        return _buildPairMatching(q);
      case QuizType.trueFalse:
        return _buildTrueFalse(q);
    }
  }

  // 1. Single Choice & Case Study مع دعم whyWrong
  Widget _buildSingleChoiceList(QuizQuestion q) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (q.caseScenario != null) ...[
          Container(
            padding: const EdgeInsets.all(Space.md),
            margin: const EdgeInsets.only(bottom: Space.lg),
            decoration: BoxDecoration(
              color: ColorTokens.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              border: Border.all(color: ColorTokens.warning.withOpacity(0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: ColorTokens.warning, size: 20),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    q.caseScenario!,
                    style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ],
        for (int i = 0; i < q.optionsList.length; i++) ...[
          OptionTile(
            text: q.optionsList[i].text,
            index: i,
            isSelected: _selectedSingleIndex == i,
            isAnswered: _hasAnswered,
            isCorrect: q.optionsList[i].isCorrect,
            onTap: () {
              setState(() {
                _selectedSingleIndex = i;
                _selectedWhyWrong = q.optionsList[i].whyWrong;
              });
            },
          ),
        ],
      ],
    );
  }

  // 2. Multiple Choice (Checkboxes)
  Widget _buildMultipleChoiceList(QuizQuestion q) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (int i = 0; i < q.optionsList.length; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: Space.sm),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              border: Border.all(
                color: _selectedMultiIndices.contains(i) ? colorScheme.primary : colorScheme.outlineVariant,
                width: _selectedMultiIndices.contains(i) ? 2 : 1,
              ),
            ),
            child: CheckboxListTile(
              value: _selectedMultiIndices.contains(i),
              contentPadding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RadiusTokens.card)),
              title: Text(q.optionsList[i].text, style: AppTypography.body),
              activeColor: colorScheme.primary,
              onChanged: _hasAnswered
                  ? null
                  : (val) {
                      setState(() {
                        if (val == true) {
                          _selectedMultiIndices.add(i);
                        } else {
                          _selectedMultiIndices.remove(i);
                        }
                      });
                    },
            ),
          ),
        ],
      ],
    );
  }

  // 3. Code/Step Ordering
  Widget _buildOrderingList(QuizQuestion q) {
    final i18n = I18nService.instance;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(i18n.t('drag_drop_order'), style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: Space.md),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            if (_hasAnswered) return;
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _shuffledOrderItems.removeAt(oldIndex);
              _shuffledOrderItems.insert(newIndex, item);
            });
          },
          children: [
            for (int i = 0; i < _shuffledOrderItems.length; i++)
              Container(
                key: ValueKey(_shuffledOrderItems[i]),
                margin: const EdgeInsets.only(bottom: Space.sm),
                padding: const EdgeInsets.all(Space.md),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator, color: colorScheme.primary),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Text(_shuffledOrderItems[i], style: AppTypography.body),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 4. Fill in the Blank
  Widget _buildFillInBlank(QuizQuestion q) {
    final i18n = I18nService.instance;
    final colorScheme = Theme.of(context).colorScheme;
    final parts = q.fillSentence.split('[blank]');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(Space.lg),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(RadiusTokens.card),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: RichText(
            text: TextSpan(
              style: AppTypography.body.copyWith(color: colorScheme.onSurface, height: 1.8),
              children: [
                TextSpan(text: parts[0]),
                TextSpan(
                  text: '  [  ...  ]  ',
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                if (parts.length > 1) TextSpan(text: parts[1]),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.xl),
        TextField(
          controller: _fillBlankController,
          enabled: !_hasAnswered,
          decoration: InputDecoration(
            hintText: i18n.t('fill_blank_hint'),
            prefixIcon: const Icon(Icons.edit_note),
          ),
        ),
      ],
    );
  }

  // 5. Pair Matching (بدون إعادة خلط عشوائي في build)
  Widget _buildPairMatching(QuizQuestion q) {
    final i18n = I18nService.instance;
    final colorScheme = Theme.of(context).colorScheme;
    final leftKeys = q.pairs.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(i18n.t('match_pairs_hint'), style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: leftKeys.map((k) {
            final isChosen = _selectedLeftPair == k;
            final isMatched = _userPairs.containsKey(k);
            return ActionChip(
              avatar: isMatched ? const Icon(Icons.check, size: 16, color: ColorTokens.success) : null,
              label: Text(k),
              backgroundColor: isMatched
                  ? ColorTokens.success.withOpacity(0.2)
                  : (isChosen ? colorScheme.primary : colorScheme.surface),
              onPressed: _hasAnswered
                  ? null
                  : () {
                      setState(() => _selectedLeftPair = k);
                    },
            );
          }).toList(),
        ),
        const Divider(height: 32),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: _shuffledRightValues.map((v) {
            return ActionChip(
              label: Text(v),
              backgroundColor: colorScheme.surface,
              onPressed: (_hasAnswered || _selectedLeftPair == null)
                  ? null
                  : () {
                      setState(() {
                        _userPairs[_selectedLeftPair!] = v;
                        _selectedLeftPair = null;
                      });
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 6. True / False
  Widget _buildTrueFalse(QuizQuestion q) {
    final i18n = I18nService.instance;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedTrueFalse == true ? ColorTokens.success : colorScheme.surface,
              foregroundColor: _selectedTrueFalse == true ? Colors.white : colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: Space.lg),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 24),
            label: Text(i18n.t('true_label')),
            onPressed: _hasAnswered ? null : () => setState(() => _selectedTrueFalse = true),
          ),
        ),
        const SizedBox(width: Space.md),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedTrueFalse == false ? ColorTokens.error : colorScheme.surface,
              foregroundColor: _selectedTrueFalse == false ? Colors.white : colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: Space.lg),
            ),
            icon: const Icon(Icons.cancel_outlined, size: 24),
            label: Text(i18n.t('false_label')),
            onPressed: _hasAnswered ? null : () => setState(() => _selectedTrueFalse = false),
          ),
        ),
      ],
    );
  }

  // تقييم الإجابة وعرض التغذية الراجعة
  Widget _buildBottomEvaluationBar(QuizQuestion q, I18nService i18n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasAnswered) ...[
              Row(
                children: [
                  Icon(
                    _isAnswerCorrect ? Icons.check_circle : Icons.cancel,
                    color: _isAnswerCorrect ? ColorTokens.success : ColorTokens.error,
                  ),
                  const SizedBox(width: Space.sm),
                  Text(
                    _isAnswerCorrect ? i18n.t('correct_answer') : i18n.t('wrong_answer'),
                    style: AppTypography.label.copyWith(
                      color: _isAnswerCorrect ? ColorTokens.success : ColorTokens.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.xs),
              Text(
                q.localizedExplanation(i18n.isArabic),
                style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              if (!_isAnswerCorrect && _selectedWhyWrong.isNotEmpty) ...[
                ReasonBanner(reason: _selectedWhyWrong, isCorrect: false),
              ],
              const SizedBox(height: Space.md),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasAnswered
                      ? (_isAnswerCorrect ? ColorTokens.success : ColorTokens.error)
                      : colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _hasAnswered ? _goToNextOrFinish : () => _validateAnswer(q),
                child: Text(
                  _hasAnswered
                      ? (_currentIndex == widget.lesson.quizzes.length - 1
                          ? i18n.t('finish_lesson')
                          : i18n.t('next_question'))
                      : i18n.t('check_answer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateAnswer(QuizQuestion q) {
    bool correct = false;
    final chosenIndices = <int>[];

    switch (q.type) {
      case QuizType.singleChoice:
      case QuizType.caseStudy:
        if (_selectedSingleIndex != null) {
          chosenIndices.add(_selectedSingleIndex!);
          if (q.correctIndices.contains(_selectedSingleIndex)) {
            correct = true;
          }
        }
        break;
      case QuizType.multipleChoice:
        chosenIndices.addAll(_selectedMultiIndices);
        final setA = _selectedMultiIndices;
        final setB = q.correctIndices.toSet();
        if (setA.length == setB.length && setA.containsAll(setB)) {
          correct = true;
        }
        break;
      case QuizType.codeOrdering:
        correct = true;
        for (int i = 0; i < q.orderItems.length; i++) {
          if (i >= _shuffledOrderItems.length || _shuffledOrderItems[i] != q.orderItems[i]) {
            correct = false;
            break;
          }
        }
        break;
      case QuizType.fillInBlank:
        final text = _fillBlankController.text.trim().toLowerCase();
        correct = q.fillAcceptedAnswers.any((ans) => ans.trim().toLowerCase() == text);
        break;
      case QuizType.pairMatching:
        correct = true;
        for (var entry in q.pairs.entries) {
          if (_userPairs[entry.key] != entry.value) {
            correct = false;
            break;
          }
        }
        break;
      case QuizType.trueFalse:
        correct = (_selectedTrueFalse == q.isTrue);
        break;
    }

    // تسجيل المحاولة مع قياس زمن التفكير للورقة البحثية
    final durationMs = DateTime.now().difference(_questionStartTime).inMilliseconds;
    AppStateService.instance.logAttempt(
      questionId: q.id,
      lessonId: widget.lesson.id,
      chosen: chosenIndices,
      isCorrect: correct,
      durationMs: durationMs,
    );

    setState(() {
      _hasAnswered = true;
      _isAnswerCorrect = correct;
    });
  }

  void _goToNextOrFinish() {
    if (_currentIndex < widget.lesson.quizzes.length - 1) {
      setState(() {
        _currentIndex += 1;
        _setupQuestion(widget.lesson.quizzes[_currentIndex]);
      });
    } else {
      AppStateService.instance.completeLesson(widget.lesson.id, widget.lesson.xpReward);
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final i18n = I18nService.instance;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(i18n.t('lesson_completed_congrats'), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.military_tech_rounded, color: ColorTokens.warning, size: 72),
            const SizedBox(height: Space.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
              decoration: BoxDecoration(
                color: ColorTokens.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
              ),
              child: Text(
                '+${widget.lesson.xpReward} XP',
                style: AppTypography.title.copyWith(color: ColorTokens.warning),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              child: Text(i18n.t('finish_and_exit')),
            ),
          ),
        ],
      ),
    );
  }

  String _getQuizTypeBadge(QuizType type, I18nService i18n) {
    switch (type) {
      case QuizType.singleChoice:
        return i18n.t('quiz_type_single');
      case QuizType.multipleChoice:
        return i18n.t('quiz_type_multi');
      case QuizType.codeOrdering:
        return i18n.t('quiz_type_order');
      case QuizType.fillInBlank:
        return i18n.t('quiz_type_fill');
      case QuizType.pairMatching:
        return i18n.t('quiz_type_pair');
      case QuizType.trueFalse:
        return i18n.t('quiz_type_tf');
      case QuizType.caseStudy:
        return i18n.t('quiz_type_case');
    }
  }
}

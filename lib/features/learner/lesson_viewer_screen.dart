import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/learning_models.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/design/design_tokens.dart';
import '../../core/services/app_state_service.dart';
import 'quiz_arena_screen.dart';

class LessonViewerScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonViewerScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late LessonDisplayMode _displayMode;

  // حالة نمط دولينجو الخاطف (Duolingo Bite-sized Mode)
  int _duoStepIndex = 0;
  int _duoHearts = 5;
  int _duoStreak = 1;
  int? _duoSelectedOption;
  bool _duoHasAnswered = false;
  bool _duoIsCorrect = false;

  @override
  void initState() {
    super.initState();
    _displayMode = widget.lesson.displayMode;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.lesson.cards;
    final i18n = I18nService.instance;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.localizedTitle(i18n.isArabic)),
        actions: [
          // قائمة التبديل بين أنماط العرض الثلاثة (Harmash, Sololearn, Duolingo)
          PopupMenuButton<LessonDisplayMode>(
            icon: Icon(
              _displayMode == LessonDisplayMode.harmashArticle
                  ? Icons.menu_book_rounded
                  : (_displayMode == LessonDisplayMode.duolingoBite
                      ? Icons.bolt_rounded
                      : Icons.view_carousel_rounded),
              color: colorScheme.primary,
            ),
            tooltip: 'تبديل نمط الدرس (هرمش، سولوليرن، دولينجو)',
            onSelected: (mode) {
              setState(() {
                _displayMode = mode;
                _duoStepIndex = 0;
                _duoHasAnswered = false;
                _duoSelectedOption = null;
              });
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: LessonDisplayMode.harmashArticle,
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: _displayMode == LessonDisplayMode.harmashArticle
                          ? colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: Space.sm),
                    const Text('نمط هرمش (مقال مرجعي شامل)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: LessonDisplayMode.cards,
                child: Row(
                  children: [
                    Icon(
                      Icons.view_carousel_rounded,
                      color: _displayMode == LessonDisplayMode.cards
                          ? colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: Space.sm),
                    const Text('نمط سولوليرن (بطاقات تفاعلية)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: LessonDisplayMode.duolingoBite,
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: _displayMode == LessonDisplayMode.duolingoBite
                          ? colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: Space.sm),
                    const Text('نمط دولينجو (تحديات خاطفة سريعة)'),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
            margin: const EdgeInsetsDirectional.only(end: Space.lg),
            decoration: BoxDecoration(
              color: ColorTokens.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(RadiusTokens.pill),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: ColorTokens.warning, size: 16),
                const SizedBox(width: Space.xs),
                Text(
                  '+${widget.lesson.xpReward} XP',
                  style: AppTypography.label.copyWith(color: ColorTokens.warning),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildCurrentModeBody(context, cards, i18n, colorScheme),
      bottomNavigationBar: _displayMode == LessonDisplayMode.cards
          ? _buildCardsBottomNav(cards, i18n, colorScheme)
          : null,
    );
  }

  Widget _buildCurrentModeBody(
    BuildContext context,
    List<LessonCard> cards,
    I18nService i18n,
    ColorScheme colorScheme,
  ) {
    switch (_displayMode) {
      case LessonDisplayMode.harmashArticle:
        return _buildHarmashArticleView(context, i18n, colorScheme);
      case LessonDisplayMode.duolingoBite:
        return _buildDuolingoBiteView(context, i18n, colorScheme);
      case LessonDisplayMode.cards:
        return _buildInteractiveCardsView(cards, i18n, colorScheme);
    }
  }

  /// نمط المقال المرجعي الشامل على طراز موقع هرمش (Harmash Article View)
  Widget _buildHarmashArticleView(
    BuildContext context,
    I18nService i18n,
    ColorScheme colorScheme,
  ) {
    final lesson = widget.lesson;
    final isDone = AppStateService.instance.isLessonCompleted(lesson.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // وسام نمط المقال المرجعي
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(RadiusTokens.pill),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_rounded, size: 14, color: colorScheme.primary),
                    const SizedBox(width: Space.xs),
                    Text(
                      'مقال مرجعي شامل (Harmash Style)',
                      style: AppTypography.caption.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (lesson.authorName != null) ...[
                Text(
                  'إعداد: ${lesson.authorName}',
                  style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
          const SizedBox(height: Space.md),

          // عنوان الدرس وملخصه
          Text(
            lesson.localizedTitle(i18n.isArabic),
            style: AppTypography.headline.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Space.sm),
          Container(
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              lesson.localizedSummary(i18n.isArabic),
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: Space.xl),

          // نص المقال المرجعي الطويل إن وجد
          if (lesson.articleContent != null && lesson.articleContent!.trim().isNotEmpty) ...[
            Text(
              lesson.localizedArticle(i18n.isArabic),
              style: AppTypography.body.copyWith(
                color: colorScheme.onSurface,
                height: 1.8,
              ),
            ),
            const SizedBox(height: Space.xl),
          ],

          // الفصول والمفاهيم البرمجية (Cards rendered as comprehensive article sections)
          for (int i = 0; i < lesson.cards.length; i++) ...[
            _buildArticleSection(lesson.cards[i], i + 1, i18n, colorScheme),
            const SizedBox(height: Space.xl),
          ],

          const Divider(height: 36),

          // قسم الإجراءات وخاتمة المقال
          Center(
            child: Column(
              children: [
                if (lesson.quizzes.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (ctx) => QuizArenaScreen(lesson: lesson)),
                        );
                        if (completed == true && mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      icon: const Icon(Icons.quiz_rounded),
                      label: const Text('بدء التحدي والاختبار التفاعلي للدرس 🏆'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(Space.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.md),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AppStateService.instance.completeLesson(lesson.id, lesson.xpReward);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 تم إكمال الدرس واكتساب النقاط بنجاح!'),
                          backgroundColor: ColorTokens.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                    icon: Icon(
                      isDone ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                      color: isDone ? ColorTokens.success : colorScheme.primary,
                    ),
                    label: Text(
                      isDone ? 'أتممت قراءة هذا المقال (مكتمل) ✅' : 'تسجيل إتمام الدرس وكسب الـ XP 🎯',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xxxl),
        ],
      ),
    );
  }

  /// فقرة أو قسم داخل مقال هرمش
  Widget _buildArticleSection(
    LessonCard card,
    int index,
    I18nService i18n,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: colorScheme.primary.withOpacity(0.15),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  card.localizedTitle(i18n.isArabic),
                  style: AppTypography.title.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.md),

          // الشرح النظري والمفاهيمي
          Text(
            card.localizedContent(i18n.isArabic),
            style: AppTypography.body.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.7,
            ),
          ),

          // كود المثال البرمجي مع زر النسخ السريع LTR Monospace
          if (card.codeSnippet != null && card.codeSnippet!.trim().isNotEmpty) ...[
            const SizedBox(height: Space.lg),
            _buildCodeSnippetBox(card.codeSnippet!, i18n, colorScheme),
          ],

          // تلميح تعليمي
          if (card.visualHint != null && card.visualHint!.trim().isNotEmpty) ...[
            const SizedBox(height: Space.md),
            Container(
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: ColorTokens.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(RadiusTokens.card),
                border: Border.all(color: ColorTokens.warning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded, color: ColorTokens.warning, size: 18),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      card.visualHint!,
                      style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// صندوق الكود البرمجي مع زر نسخ الكود بنقرة واحدة
  Widget _buildCodeSnippetBox(
    String code,
    I18nService i18n,
    ColorScheme colorScheme,
  ) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(RadiusTokens.card),
          border: Border.all(color: colorScheme.primary.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط أدوات الكود والنسخ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(RadiusTokens.card)),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.terminal_rounded, size: 15, color: ColorTokens.accentGreen),
                  const SizedBox(width: Space.xs),
                  Text(
                    'Code Snippet',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white70,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  // زر النسخ السريع إلى الحافظة
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 15, color: ColorTokens.accentGreen),
                    tooltip: 'نسخ الكود',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ الكود البرمجي إلى الحافظة 📋'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // نص الكود
            Padding(
              padding: const EdgeInsets.all(Space.md),
              child: SelectableText(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  color: Color(0xFFE2E8F0),
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// نمط البطاقات التفاعلية المتتابعة (Interactive Cards View)
  Widget _buildInteractiveCardsView(
    List<LessonCard> cards,
    I18nService i18n,
    ColorScheme colorScheme,
  ) {
    if (cards.isEmpty) {
      return Center(
        child: Text('لا توجد بطاقات شرح في هذا الدرس.', style: AppTypography.bodySmall),
      );
    }

    return Column(
      children: [
        // شريط مؤشر التقدم الأفقي للبطاقات
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.md),
          child: Row(
            children: List.generate(cards.length, (idx) {
              final isCurrent = idx == _currentPage;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isCurrent ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),

        // عارض البطاقات
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: cards.length,
            onPageChanged: (pg) => setState(() => _currentPage = pg),
            itemBuilder: (ctx, idx) {
              final card = cards[idx];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(Space.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.localizedTitle(i18n.isArabic),
                      style: AppTypography.headline.copyWith(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: Space.lg),
                    Text(
                      card.localizedContent(i18n.isArabic),
                      style: AppTypography.body.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: Space.xl),

                    // عزل كود البرمجة باتجاه LTR مع زر النسخ السريع
                    if (card.codeSnippet != null && card.codeSnippet!.trim().isNotEmpty) ...[
                      _buildCodeSnippetBox(card.codeSnippet!, i18n, colorScheme),
                      const SizedBox(height: Space.xl),
                    ],

                    // تلميح تعليمي ذكي (Callout)
                    if (card.visualHint != null && card.visualHint!.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(Space.md),
                        decoration: BoxDecoration(
                          color: ColorTokens.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(RadiusTokens.card),
                          border: Border.all(color: ColorTokens.warning.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.tips_and_updates_rounded, color: ColorTokens.warning, size: 20),
                            const SizedBox(width: Space.sm),
                            Expanded(
                              child: Text(
                                card.visualHint!,
                                style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurface),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardsBottomNav(
    List<LessonCard> cards,
    I18nService i18n,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentPage > 0)
              OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: MotionTokens.screen,
                    curve: MotionTokens.curve,
                  );
                },
                child: Icon(i18n.isArabic ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded),
              ),
            if (_currentPage > 0) const SizedBox(width: Space.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_currentPage < cards.length - 1) {
                    _pageController.nextPage(
                      duration: MotionTokens.screen,
                      curve: MotionTokens.curve,
                    );
                  } else {
                    if (widget.lesson.quizzes.isNotEmpty) {
                      final completed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (ctx) => QuizArenaScreen(lesson: widget.lesson)),
                      );
                      if (completed == true && mounted) {
                        Navigator.pop(context, true);
                      }
                    } else {
                      AppStateService.instance.completeLesson(widget.lesson.id, widget.lesson.xpReward);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 تم إكمال الدرس بنجاح!'),
                            backgroundColor: ColorTokens.success,
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                    }
                  }
                },
                icon: Icon(_currentPage < cards.length - 1
                    ? (i18n.isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded)
                    : Icons.play_arrow_rounded),
                label: Text(
                  _currentPage < cards.length - 1 ? i18n.t('continue_lesson') : i18n.t('start_lesson'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// نمط دولينجو: خطوات سريعة وتحديات خاطفة (Duolingo Bite-sized View)
  Widget _buildDuolingoBiteView(
    BuildContext context,
    I18nService i18n,
    ColorScheme colorScheme,
  ) {
    final lesson = widget.lesson;
    final allSteps = <dynamic>[...lesson.cards, ...lesson.quizzes];

    if (allSteps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 48),
            const SizedBox(height: Space.md),
            const Text('لا توجد خطوات متوفرة لهذا الدرس حالياً.'),
            const SizedBox(height: Space.md),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة'),
            ),
          ],
        ),
      );
    }

    // شاشة النصر عند اكتمال جميع الخطوات
    if (_duoStepIndex >= allSteps.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(Space.xl),
                decoration: BoxDecoration(
                  color: ColorTokens.accentGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 80,
                  color: ColorTokens.accentGreen,
                ),
              ),
              const SizedBox(height: Space.xl),
              Text(
                'أحسنت! أتممت التحدي الخاطف 🚀',
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Space.sm),
              Text(
                'اكتسبت +${lesson.xpReward} XP بنجاح بنمط دولينجو السريع!',
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Space.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    AppStateService.instance.completeLesson(lesson.id, lesson.xpReward);
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('إنهاء والعودة إلى شجرة المهارات'),
                  style: FilledButton.styleFrom(
                    backgroundColor: ColorTokens.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(Space.md),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentStep = allSteps[_duoStepIndex];
    final progress = (_duoStepIndex + 1) / allSteps.length;

    return Column(
      children: [
        // شريط تقدم دولينجو العلوي: مؤشر السلسلة والقلوب والتقدم
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.sm),
          color: colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              // مؤشر السلسلة (Combo / Streak)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(RadiusTokens.pill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$_duoStreak',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.md),
              // شريط التقدم الخطي
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(RadiusTokens.pill),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation<Color>(ColorTokens.accentGreen),
                  ),
                ),
              ),
              const SizedBox(width: Space.md),
              // مؤشر القلوب (Hearts)
              Row(
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$_duoHearts',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),

        // جسم التحدي الحالي
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.xl),
            child: currentStep is LessonCard
                ? _buildDuoCardStep(currentStep, _duoStepIndex + 1, allSteps.length, colorScheme)
                : _buildDuoQuizStep(currentStep as QuizQuestion, _duoStepIndex + 1, allSteps.length, colorScheme, i18n),
          ),
        ),

        // شريط التقييم السفلي
        _buildDuoBottomBar(currentStep, allSteps.length, colorScheme, i18n),
      ],
    );
  }

  Widget _buildDuoCardStep(
    LessonCard card,
    int stepNumber,
    int totalSteps,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
              ),
              child: Text(
                '💡 مفهوم سريع ($stepNumber/$totalSteps)',
                style: AppTypography.caption.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.lg),
        Text(
          card.title,
          style: AppTypography.headline.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: Space.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Space.lg),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(RadiusTokens.card),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            card.content,
            style: AppTypography.body.copyWith(
              color: colorScheme.onSurface,
              height: 1.7,
            ),
          ),
        ),
        if (card.codeSnippet != null && card.codeSnippet!.isNotEmpty) ...[
          const SizedBox(height: Space.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(RadiusTokens.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'كود توضيحي',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 16),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: card.codeSnippet!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ الكود!')),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  card.codeSnippet!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFFA6E3A1),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDuoQuizStep(
    QuizQuestion quiz,
    int stepNumber,
    int totalSteps,
    ColorScheme colorScheme,
    I18nService i18n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.18),
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
              ),
              child: Text(
                '⚡ تحدي خاطف ($stepNumber/$totalSteps)',
                style: AppTypography.caption.copyWith(
                  color: Colors.amber.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.lg),
        Text(
          quiz.localizedPrompt(i18n.isArabic),
          style: AppTypography.headline.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: Space.xl),
        for (int i = 0; i < quiz.optionsList.length; i++) ...[
          InkWell(
            onTap: _duoHasAnswered
                ? null
                : () {
                    setState(() {
                      _duoSelectedOption = i;
                    });
                  },
            borderRadius: BorderRadius.circular(RadiusTokens.card),
            child: Container(
              margin: const EdgeInsets.only(bottom: Space.md),
              padding: const EdgeInsets.all(Space.lg),
              decoration: BoxDecoration(
                color: _duoSelectedOption == i
                    ? colorScheme.primaryContainer.withOpacity(0.6)
                    : colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(RadiusTokens.card),
                border: Border.all(
                  color: _duoSelectedOption == i
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: _duoSelectedOption == i ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _duoSelectedOption == i
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        width: 2,
                      ),
                      color: _duoSelectedOption == i ? colorScheme.primary : Colors.transparent,
                    ),
                    child: _duoSelectedOption == i
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Text(
                      quiz.optionsList[i].text,
                      style: AppTypography.body.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: _duoSelectedOption == i ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDuoBottomBar(
    dynamic currentStep,
    int totalSteps,
    ColorScheme colorScheme,
    I18nService i18n,
  ) {
    final isCard = currentStep is LessonCard;

    if (isCard) {
      return Container(
        padding: const EdgeInsets.all(Space.lg),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _duoStepIndex++;
                  _duoStreak++;
                });
              },
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('استوعبت الفكرة! التالي ⚡'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(Space.md),
              ),
            ),
          ),
        ),
      );
    }

    final quiz = currentStep as QuizQuestion;

    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: _duoHasAnswered
            ? (_duoIsCorrect
                ? ColorTokens.accentGreen.withOpacity(0.15)
                : ColorTokens.error.withOpacity(0.15))
            : colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: _duoHasAnswered
                ? (_duoIsCorrect ? ColorTokens.accentGreen : ColorTokens.error)
                : colorScheme.outlineVariant,
            width: _duoHasAnswered ? 2 : 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_duoHasAnswered) ...[
              Row(
                children: [
                  Icon(
                    _duoIsCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: _duoIsCorrect ? ColorTokens.accentGreen : ColorTokens.error,
                  ),
                  const SizedBox(width: Space.sm),
                  Text(
                    _duoIsCorrect ? 'إجابة ممتازة وذكية! 🎯' : 'تحتاج لمراجعة أدق!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _duoIsCorrect ? ColorTokens.accentGreen : ColorTokens.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.xs),
              Text(
                quiz.localizedExplanation(i18n.isArabic),
                style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: Space.md),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _duoHasAnswered
                    ? () {
                        setState(() {
                          if (_duoIsCorrect) {
                            _duoStepIndex++;
                            _duoStreak++;
                          }
                          _duoHasAnswered = false;
                          _duoSelectedOption = null;
                        });
                      }
                    : (_duoSelectedOption != null
                        ? () {
                            final isCorrect = _duoSelectedOption != null &&
                                quiz.optionsList[_duoSelectedOption!].isCorrect;
                            setState(() {
                              _duoHasAnswered = true;
                              _duoIsCorrect = isCorrect;
                              if (!isCorrect && _duoHearts > 1) {
                                _duoHearts--;
                              }
                            });
                          }
                        : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _duoHasAnswered
                      ? (_duoIsCorrect ? ColorTokens.accentGreen : ColorTokens.error)
                      : colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(Space.md),
                ),
                child: Text(
                  _duoHasAnswered
                      ? (_duoIsCorrect ? 'متابعة الخطوة التالية 🚀' : 'المحاولة مجدداً 🔄')
                      : 'تحقق من الإجابة ✅',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

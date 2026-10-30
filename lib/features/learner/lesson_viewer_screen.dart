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
    final isHarmashMode = _displayMode == LessonDisplayMode.harmashArticle;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.localizedTitle(i18n.isArabic)),
        actions: [
          // زر التبديل بين نمط هرمش (مقال مرجعي شامل) ونمط البطاقات التفاعلية
          IconButton(
            icon: Icon(
              isHarmashMode ? Icons.view_carousel_rounded : Icons.menu_book_rounded,
              color: colorScheme.primary,
            ),
            tooltip: isHarmashMode
                ? 'التبديل إلى نمط البطاقات التفاعلية'
                : 'التبديل إلى نمط مقال هرمش المرجعي',
            onPressed: () {
              setState(() {
                _displayMode = isHarmashMode
                    ? LessonDisplayMode.cards
                    : LessonDisplayMode.harmashArticle;
              });
            },
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
      body: isHarmashMode
          ? _buildHarmashArticleView(context, i18n, colorScheme)
          : _buildInteractiveCardsView(cards, i18n, colorScheme),
      bottomNavigationBar: isHarmashMode ? null : _buildCardsBottomNav(cards, i18n, colorScheme),
    );
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
}

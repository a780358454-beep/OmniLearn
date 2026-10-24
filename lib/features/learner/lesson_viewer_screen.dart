import 'package:flutter/material.dart';
import '../../core/models/learning_models.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/design/design_tokens.dart';
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
        title: Text(widget.lesson.title),
        actions: [
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
      bottomNavigationBar: Container(
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
                  child: const Icon(Icons.arrow_back),
                ),
              if (_currentPage > 0) const SizedBox(width: Space.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_currentPage < cards.length - 1) {
                      _pageController.nextPage(
                        duration: MotionTokens.screen,
                        curve: MotionTokens.curve,
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => QuizArenaScreen(lesson: widget.lesson)),
                      );
                    }
                  },
                  icon: Icon(_currentPage < cards.length - 1 ? Icons.arrow_forward : Icons.play_arrow_rounded),
                  label: Text(
                    _currentPage < cards.length - 1 ? i18n.t('continue_lesson') : i18n.t('start_lesson'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
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
                        card.title,
                        style: AppTypography.headline.copyWith(color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: Space.lg),

                      Text(
                        card.content,
                        style: AppTypography.body.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: Space.xl),

                      // عزل كود البرمجة باتجاه LTR حصراً
                      if (card.codeSnippet != null) ...[
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Space.lg),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(RadiusTokens.card),
                              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.code, size: 16, color: colorScheme.primary),
                                    const SizedBox(width: Space.xs),
                                    Text(
                                      i18n.t('code_snippet'),
                                      style: AppTypography.caption.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Space.sm),
                                SelectableText(
                                  card.codeSnippet!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    color: ColorTokens.accentGreen,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Space.xl),
                      ],

                      // تلميح تعليمي ذكي (Callout)
                      if (card.visualHint != null) ...[
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
      ),
    );
  }
}

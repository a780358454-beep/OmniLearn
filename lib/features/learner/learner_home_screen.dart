import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/models/learning_models.dart';
import '../../core/design/design_tokens.dart';
import '../../core/widgets/core_components.dart';
import '../shared/top_navbar.dart';
import '../admin/admin_portal_screen.dart';
import '../creator/creator_studio_screen.dart';
import 'lesson_viewer_screen.dart';

class LearnerHomeScreen extends StatelessWidget {
  const LearnerHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    final i18n = I18nService.instance;
    final cur = state.activeCurriculum;
    final user = state.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const TopNavbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. شريط إحصائيات التتابع ونقاط الخبرة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.md),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatChip(
                    icon: Icons.local_fire_department_rounded,
                    color: ColorTokens.warning,
                    label: '${user.streakDays} ${i18n.t('streak_days')}',
                  ),
                  Container(width: 1, height: 24, color: colorScheme.outlineVariant),
                  StatChip(
                    icon: Icons.bolt_rounded,
                    color: colorScheme.primary,
                    label: '${user.xp} ${i18n.t('total_xp')}',
                  ),
                  Container(width: 1, height: 24, color: colorScheme.outlineVariant),
                  StatChip(
                    icon: Icons.check_circle_rounded,
                    color: ColorTokens.success,
                    label: '${user.completedLessonIds.length} ${i18n.t('completed')}',
                  ),
                ],
              ),
            ),

            // 2. أزرار الوصول السريع للأدمن والمؤلف (مبنية بصرياً ومتسقة)
            if (user.role == UserRole.admin || user.role == UserRole.creator) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, 0),
                child: Row(
                  children: [
                    if (user.role == UserRole.admin)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminPortalScreen()),
                            );
                          },
                          icon: const Icon(Icons.admin_panel_settings, size: 18),
                          label: Text(i18n.t('admin_portal')),
                        ),
                      ),
                    if (user.role == UserRole.admin) const SizedBox(width: Space.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreatorStudioScreen()),
                          );
                        },
                        icon: const Icon(Icons.draw_rounded, size: 18),
                        label: Text(i18n.t('creator_studio')),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 3. منتقي المسارات والتخصصات المستقلة
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.alt_route_rounded, color: colorScheme.primary, size: 20),
                              const SizedBox(width: Space.sm),
                              Text(
                                i18n.t('switch_curriculum'),
                                style: AppTypography.label.copyWith(color: colorScheme.onSurface),
                              ),
                            ],
                          ),
                          // زر تصدير بيانات البحث CSV
                          IconButton(
                            icon: const Icon(Icons.table_chart_outlined, size: 20),
                            tooltip: i18n.t('export_research_csv'),
                            onPressed: () => _exportCsvData(context, state),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.md),
                      Wrap(
                        spacing: Space.sm,
                        runSpacing: Space.sm,
                        children: state.curricula.map((c) {
                          final isSelected = c.id == state.activeCurriculumId;
                          return ChoiceChip(
                            selected: isSelected,
                            selectedColor: colorScheme.primary,
                            label: Text(c.name),
                            onSelected: (val) {
                              if (val) state.setActiveCurriculum(c.id);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. استعراض المقررات والدروس
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: SectionHeader(
                title: '${i18n.t('curriculum')}: ${cur.name}',
              ),
            ),
            const SizedBox(height: Space.sm),

            if (cur.courses.isEmpty)
              EmptyState(
                icon: Icons.auto_stories_outlined,
                title: i18n.t('empty_courses_title'),
                reason: i18n.t('empty_courses_reason'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                itemCount: cur.courses.length,
                itemBuilder: (ctx, cIdx) {
                  final course = cur.courses[cIdx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: Space.lg),
                    child: Padding(
                      padding: const EdgeInsets.all(Space.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(Space.sm),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                                ),
                                child: Icon(Icons.code_rounded, color: colorScheme.primary),
                              ),
                              const SizedBox(width: Space.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      style: AppTypography.title.copyWith(color: colorScheme.onSurface),
                                    ),
                                    Text(
                                      '${course.code} • ${course.description}',
                                      style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          if (course.modules.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Space.md),
                              child: Text(
                                i18n.t('coming_soon_module'),
                                style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            )
                          else
                            for (var module in course.modules) ...[
                              Text(
                                module.title,
                                style: AppTypography.label.copyWith(color: colorScheme.primary),
                              ),
                              const SizedBox(height: Space.sm),
                              for (var lesson in module.lessons)
                                if (lesson.status == ContentStatus.published)
                                  _buildLessonTile(context, state, lesson, i18n),
                              const SizedBox(height: Space.sm),
                            ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTile(BuildContext context, AppStateService state, Lesson lesson, I18nService i18n) {
    final isDone = state.isLessonCompleted(lesson.id);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: Space.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(
          color: isDone ? ColorTokens.success.withOpacity(0.4) : colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LessonViewerScreen(lesson: lesson)),
          );
        },
        leading: CircleAvatar(
          backgroundColor: isDone
              ? ColorTokens.success.withOpacity(0.15)
              : colorScheme.primary.withOpacity(0.15),
          child: Icon(
            isDone ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
            color: isDone ? ColorTokens.success : colorScheme.primary,
          ),
        ),
        title: Text(
          lesson.title,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${lesson.summary} • +${lesson.xpReward} XP',
          style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
          decoration: BoxDecoration(
            color: isDone
                ? ColorTokens.success.withOpacity(0.12)
                : colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(RadiusTokens.pill),
          ),
          child: Text(
            isDone ? i18n.t('review_lesson') : i18n.t('start_lesson'),
            style: AppTypography.caption.copyWith(
              color: isDone ? ColorTokens.success : colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _exportCsvData(BuildContext context, AppStateService state) async {
    final csv = await state.exportResearchCsv();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('بيانات المحاولات البحثية (Research CSV)'),
        content: SingleChildScrollView(
          child: SelectableText(
            csv,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }
}

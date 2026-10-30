import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/models/learning_models.dart';
import '../../core/design/design_tokens.dart';
import '../../core/widgets/core_components.dart';
import '../shared/top_navbar.dart';
import '../shared/role_guard.dart';
import '../admin/admin_portal_screen.dart';
import '../creator/creator_studio_screen.dart';
import 'lesson_viewer_screen.dart';

class LearnerHomeScreen extends StatefulWidget {
  const LearnerHomeScreen({Key? key}) : super(key: key);

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen> {
  String? _selectedCourseId;

  IconData _resolveCourseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'code':
        return Icons.code_rounded;
      case 'architecture':
      case 'design':
        return Icons.account_tree_rounded;
      case 'mobile':
      case 'phone':
        return Icons.smartphone_rounded;
      case 'hci':
      case 'ui':
        return Icons.touch_app_rounded;
      case 'research':
        return Icons.menu_book_rounded;
      case 'cloud':
      case 'enterprise':
        return Icons.cloud_done_rounded;
      case 'security':
      case 'ethics':
        return Icons.verified_user_rounded;
      case 'web':
        return Icons.language_rounded;
      case 'data_object':
      case 'algorithm':
      case 'dsa':
        return Icons.data_object_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  int _totalPublishedLessons(Course course) {
    var count = 0;
    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        if (lesson.isApproved) {
          count++;
        }
      }
    }
    return count;
  }

  int _completedLessons(Course course, AppStateService state) {
    var count = 0;
    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        if (lesson.isApproved && state.isLessonCompleted(lesson.id)) {
          count++;
        }
      }
    }
    return count;
  }

  Lesson? _findNextLesson(Course course, AppStateService state) {
    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        if (lesson.status == ContentStatus.published && !state.isLessonCompleted(lesson.id)) {
          return lesson;
        }
      }
    }
    return null;
  }

  Lesson? _findFirstLesson(Course course) {
    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        if (lesson.status == ContentStatus.published) {
          return lesson;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    final i18n = I18nService.instance;
    final cur = state.activeCurriculum;
    final user = state.currentUser;
    final cs = Theme.of(context).colorScheme;

    // تحديد المادة النشطة المعروضة
    Course? activeCourse;
    if (_selectedCourseId != null) {
      for (final c in cur.courses) {
        if (c.id == _selectedCourseId) {
          activeCourse = c;
          break;
        }
      }
    }

    if (activeCourse == null && cur.courses.isNotEmpty) {
      // تفضيل المادة التي بدأها الطالب ولم يكملها، أو أول مادة
      activeCourse = cur.courses.firstWhere(
        (c) {
          final total = _totalPublishedLessons(c);
          final done = _completedLessons(c, state);
          return done < total && done > 0;
        },
        orElse: () => cur.courses.first,
      );
      _selectedCourseId = activeCourse.id;
    }

    final totalActiveLessons = activeCourse != null ? _totalPublishedLessons(activeCourse) : 0;
    final doneActiveLessons = activeCourse != null ? _completedLessons(activeCourse, state) : 0;
    final activeProgress = totalActiveLessons > 0 ? (doneActiveLessons / totalActiveLessons) : 0.0;
    final nextLesson = activeCourse != null ? _findNextLesson(activeCourse, state) : null;
    final firstLesson = activeCourse != null ? _findFirstLesson(activeCourse) : null;

    // استخراج باقي المواد للتمرير الجانبي
    final otherCourses = cur.courses.where((c) => c.id != activeCourse?.id).toList();

    return Scaffold(
      appBar: const TopNavbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. شريط الإحصائيات (Streak, XP, Level, Completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.md),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(bottom: BorderSide(color: cs.outlineVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatChip(
                    icon: Icons.local_fire_department_rounded,
                    color: ColorTokens.warning,
                    label: '${user.streakDays} ${i18n.t('streak_days')}',
                  ),
                  Container(width: 1, height: 24, color: cs.outlineVariant),
                  StatChip(
                    icon: Icons.bolt_rounded,
                    color: cs.primary,
                    label: '${user.xp} XP',
                  ),
                  Container(width: 1, height: 24, color: cs.outlineVariant),
                  StatChip(
                    icon: Icons.military_tech_rounded,
                    color: Colors.amber.shade700,
                    label: 'Lv.${user.level}',
                  ),
                  Container(width: 1, height: 24, color: cs.outlineVariant),
                  StatChip(
                    icon: Icons.check_circle_rounded,
                    color: ColorTokens.success,
                    label: '${user.completedLessonIds.length} ${i18n.t('completed')}',
                  ),
                ],
              ),
            ),

            // شريط نسبة التقدم نحو المستوى التالي (Level Progress Nudge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.xs + 2),
              color: cs.surfaceContainerLow,
              child: Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: Space.xs),
                  Text(
                    'Lv.${user.level} (${user.xpInCurrentLevel}/100 XP)',
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                      child: LinearProgressIndicator(
                        value: user.levelProgress,
                        minHeight: 6,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Text(
                    'Lv.${user.level + 1}',
                    style: AppTypography.caption.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // تنبيه المسودات المحلية الجاهزة للمزامنة السحابية (Offline Queue Banner)
            if (state.hasLocalDrafts)
              Container(
                margin: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, 0),
                padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  border: Border.all(color: Colors.amber.shade700.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: Colors.amber.shade800, size: 22),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Text(
                        '${i18n.t('offline_drafts_found')} (${state.getLocalDrafts().length})',
                        style: AppTypography.caption.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () async {
                        await state.syncAllLocalDrafts();
                      },
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: Space.md),
                      ),
                      child: Text(i18n.t('sync_all_drafts'), style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),

            // شريط الإشعارات الخفيفة والتحفيز (Micro-Notification Banner)
            if (state.notificationMessage != null)
              Container(
                margin: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, 0),
                padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                decoration: BoxDecoration(
                  color: ColorTokens.accentGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  border: Border.all(color: ColorTokens.accentGreen.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign_rounded, color: ColorTokens.accentGreen, size: 22),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Text(
                        state.notificationMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => state.dismissNotification(),
                    ),
                  ],
                ),
              ),

            // 2. أزرار الوصول السريع للمساهمة وإدارة النظام المحمية بـ RoleGuard
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, 0),
              child: Row(
                children: [
                  if (user.role == UserRole.admin) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RoleGuard(
                                roles: [UserRole.admin],
                                child: AdminPortalScreen(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.admin_panel_settings, size: 18),
                        label: Text(i18n.t('admin_portal')),
                      ),
                    ),
                    const SizedBox(width: Space.md),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreatorStudioScreen()),
                        );
                      },
                      icon: const Icon(Icons.draw_rounded, size: 18),
                      label: Text(
                        user.role == UserRole.student
                            ? i18n.t('contribute_lesson')
                            : i18n.t('creator_studio'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // شريط بيان المسار البرمجي الحالي (Track Badge)
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.terminal_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: Space.xs),
                    Text(
                      '${i18n.t('track_label')}: ',
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        cur.name,
                        style: AppTypography.caption.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => _openAllCoursesModal(context, state, i18n),
                      child: Text(
                        i18n.t('switch_curriculum'),
                        style: AppTypography.caption.copyWith(
                          color: cs.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. المادة التي ستدرسها وتقدمك فيها (Hero Active Course Card)
            if (activeCourse != null) ...[
              Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(RadiusTokens.card),
                    border: Border.all(color: cs.primary.withOpacity(0.35), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(Space.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // وسام المادة قيد الدراسة وكود المقرر
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(RadiusTokens.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_stories_rounded, size: 16, color: cs.primary),
                                const SizedBox(width: Space.xs),
                                Text(
                                  i18n.t('active_course'),
                                  style: AppTypography.caption.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(RadiusTokens.pill),
                            ),
                            child: Text(
                              activeCourse.code,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.md),

                      // عنوان ووصف المادة
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(Space.md),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(RadiusTokens.field),
                            ),
                            child: Icon(_resolveCourseIcon(activeCourse.iconName), color: cs.primary, size: 28),
                          ),
                          const SizedBox(width: Space.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeCourse.title,
                                  style: AppTypography.title.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: Space.xs),
                                Text(
                                  activeCourse.description,
                                  style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.lg),

                      // شريط تقدم المادة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$doneActiveLessons ${i18n.t('completed_of_total')} $totalActiveLessons ${i18n.t('lessons_unit')}',
                            style: AppTypography.caption.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(activeProgress * 100).toInt()}%',
                            style: AppTypography.caption.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(RadiusTokens.pill),
                        child: LinearProgressIndicator(
                          value: activeProgress,
                          minHeight: 8,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            activeProgress >= 1.0 ? ColorTokens.success : cs.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: Space.lg),

                      // زر الإجراء المباشر: متابعة التعلم أو مراجعة المادة
                      SizedBox(
                        width: double.infinity,
                        child: nextLesson != null
                            ? FilledButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => LessonViewerScreen(lesson: nextLesson)),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: Text(
                                  '${i18n.t('continue_learning')}: ${nextLesson.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : FilledButton.tonalIcon(
                                onPressed: () {
                                  if (firstLesson != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => LessonViewerScreen(lesson: firstLesson)),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.check_circle_outline_rounded),
                                label: Text(i18n.t('review_course')),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: EmptyState(
                  icon: Icons.auto_stories_outlined,
                  title: i18n.t('empty_courses_title'),
                  reason: i18n.t('empty_courses_reason'),
                ),
              ),
            ],

            // 4. تمرير جانبي لعرض باقي الدورات + زر عرض كافة الدورات أو المواد
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${i18n.t('other_courses')} (${cur.courses.length})',
                    style: AppTypography.title.copyWith(color: cs.onSurface, fontSize: 16),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openAllCoursesModal(context, state, i18n),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.grid_view_rounded, size: 16),
                    label: Text(i18n.t('all_courses_btn')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),

            // قائمة التمرير الجانبي (Horizontal Carousel)
            SizedBox(
              height: 142,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                itemCount: cur.courses.length,
                separatorBuilder: (_, __) => const SizedBox(width: Space.md),
                itemBuilder: (ctx, idx) {
                  final course = cur.courses[idx];
                  final isCurrent = course.id == activeCourse?.id;
                  final totalL = _totalPublishedLessons(course);
                  final doneL = _completedLessons(course, state);
                  final progress = totalL > 0 ? (doneL / totalL) : 0.0;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCourseId = course.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(RadiusTokens.card),
                    child: Container(
                      width: 230,
                      padding: const EdgeInsets.all(Space.md),
                      decoration: BoxDecoration(
                        color: isCurrent ? cs.primary.withOpacity(0.08) : cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(RadiusTokens.card),
                        border: Border.all(
                          color: isCurrent ? cs.primary : cs.outlineVariant,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(Space.xs),
                                decoration: BoxDecoration(
                                  color: (isCurrent ? cs.primary : cs.onSurfaceVariant).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(RadiusTokens.field),
                                ),
                                child: Icon(
                                  _resolveCourseIcon(course.iconName),
                                  size: 18,
                                  color: isCurrent ? cs.primary : cs.onSurfaceVariant,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(RadiusTokens.pill),
                                ),
                                child: Text(
                                  course.code,
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            course.title,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? cs.primary : cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$doneL / $totalL ${i18n.t('lessons_unit')}',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: progress >= 1.0 ? ColorTokens.success : cs.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(RadiusTokens.pill),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progress >= 1.0 ? ColorTokens.success : cs.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Space.xl),

            // 5. مفردات المادة ووحداتها والدروس التفاعلية
            if (activeCourse != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                child: SectionHeader(
                  title: '${i18n.t('syllabus_title')}: ${activeCourse.title}',
                ),
              ),
              const SizedBox(height: Space.sm),

              if (activeCourse.modules.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                  child: EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: i18n.t('coming_soon_module'),
                    reason: i18n.t('empty_courses_reason'),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                  child: Column(
                    children: [
                      for (var module in activeCourse.modules)
                        _buildModuleSkillTree(context, state, activeCourse, module, i18n, cs),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }

  /// بناء وحدة تعليمية على طراز شجرة المهارات التفاعلية (Sololearn-style Skill Tree Module)
  Widget _buildModuleSkillTree(
    BuildContext context,
    AppStateService state,
    Course activeCourse,
    CourseModule module,
    I18nService i18n,
    ColorScheme cs,
  ) {
    final approvedLessons = module.lessons.where((l) => l.isApproved).toList();
    if (approvedLessons.isEmpty) return const SizedBox.shrink();

    final doneLessonsCount = approvedLessons.where((l) => state.isLessonCompleted(l.id)).length;
    final moduleProgress = approvedLessons.isNotEmpty ? doneLessonsCount / approvedLessons.length : 0.0;
    final isModuleCompleted = doneLessonsCount == approvedLessons.length && approvedLessons.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: Space.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(
          color: isModuleCompleted ? ColorTokens.success.withOpacity(0.4) : cs.outlineVariant,
          width: isModuleCompleted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ترويسة الوحدة (Module Header)
          Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration: BoxDecoration(
              color: isModuleCompleted
                  ? ColorTokens.success.withOpacity(0.08)
                  : cs.surfaceContainerHigh.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(RadiusTokens.card)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Space.sm),
                  decoration: BoxDecoration(
                    color: (isModuleCompleted ? ColorTokens.success : cs.primary).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(RadiusTokens.field),
                  ),
                  child: Icon(
                    isModuleCompleted ? Icons.verified_rounded : Icons.folder_special_rounded,
                    color: isModuleCompleted ? ColorTokens.success : cs.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: AppTypography.title.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (module.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          module.description,
                          style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: Space.sm),
                // شارة إنجاز الوحدة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    border: Border.all(
                      color: isModuleCompleted ? ColorTokens.success : cs.outlineVariant,
                    ),
                  ),
                  child: Text(
                    '$doneLessonsCount / ${approvedLessons.length}',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isModuleCompleted ? ColorTokens.success : cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // مسار عقد الدروس التفاعلية مع خطوط الربط التسلسلي (Sequential Skill Tree Roadmap)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, Space.md),
            child: Column(
              children: [
                for (int i = 0; i < approvedLessons.length; i++)
                  _buildSkillTreeNode(
                    context: context,
                    state: state,
                    activeCourse: activeCourse,
                    lesson: approvedLessons[i],
                    isLastLesson: i == approvedLessons.length - 1,
                    i18n: i18n,
                    cs: cs,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// عقدة الدرس التفاعلية في المسار (Interactive Roadmap Node)
  Widget _buildSkillTreeNode({
    required BuildContext context,
    required AppStateService state,
    required Course activeCourse,
    required Lesson lesson,
    required bool isLastLesson,
    required I18nService i18n,
    required ColorScheme cs,
  }) {
    final isLocked = state.isLessonLocked(activeCourse, lesson.id);
    final isDone = state.isLessonCompleted(lesson.id);
    final isActive = !isDone && !isLocked;

    // تمييز نوع العقدة بصرياً
    String typeLabel;
    IconData typeIcon;
    Color typeColor;

    if (lesson.isMilestoneQuiz) {
      typeLabel = i18n.t('unit_milestone_quiz');
      typeIcon = Icons.military_tech_rounded;
      typeColor = Colors.amber.shade800;
    } else if (lesson.isCodeChallenge) {
      typeLabel = i18n.t('code_challenge');
      typeIcon = Icons.terminal_rounded;
      typeColor = Colors.teal;
    } else {
      typeLabel = i18n.t('theory_lesson');
      typeIcon = Icons.menu_book_rounded;
      typeColor = cs.primary;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. عمود العقدة والخط الرابط (Timeline Node & Connector Line)
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // دائرة العقدة التفاعلية
                GestureDetector(
                  onTap: () => _handleLessonTap(context, state, lesson, isLocked, i18n),
                  child: AnimatedContainer(
                    duration: MotionTokens.screen,
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? ColorTokens.success
                          : (isActive ? cs.primary : cs.surfaceContainerHighest),
                      border: Border.all(
                        color: isDone
                            ? ColorTokens.success
                            : (isActive ? Colors.white : cs.outlineVariant),
                        width: isActive ? 2.5 : 1.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Icon(
                        isDone
                            ? Icons.check_rounded
                            : (isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded),
                        color: isLocked ? cs.onSurfaceVariant.withOpacity(0.6) : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                // خط التوصيل بين العقد المتتالية
                if (!isLastLesson)
                  Expanded(
                    child: Container(
                      width: 3.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isDone
                            ? ColorTokens.success
                            : (isActive ? cs.primary.withOpacity(0.6) : cs.outlineVariant.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Space.md),

          // 2. بطاقة معلومات الدرس التفاعلية
          Expanded(
            child: InkWell(
              onTap: () => _handleLessonTap(context, state, lesson, isLocked, i18n),
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              child: Container(
                margin: const EdgeInsets.only(bottom: Space.lg),
                padding: const EdgeInsets.all(Space.md),
                decoration: BoxDecoration(
                  color: isActive
                      ? cs.primary.withOpacity(0.06)
                      : (isDone ? ColorTokens.success.withOpacity(0.04) : cs.surface),
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  border: Border.all(
                    color: isActive
                        ? cs.primary
                        : (isDone ? ColorTokens.success.withOpacity(0.3) : cs.outlineVariant),
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شارات النوع والمكافأة وحالة القفل
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(RadiusTokens.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(typeIcon, size: 13, color: typeColor),
                              const SizedBox(width: 4),
                              Text(
                                typeLabel,
                                style: AppTypography.caption.copyWith(
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(RadiusTokens.pill),
                          ),
                          child: Text(
                            '+${lesson.xpReward} XP',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.xs),

                    // عنوان الدرس
                    Text(
                      lesson.localizedTitle(i18n.isArabic),
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLocked ? cs.onSurfaceVariant : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // ملخص الدرس
                    Text(
                      lesson.localizedSummary(i18n.isArabic),
                      style: AppTypography.caption.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Space.sm),

                    // شارة الإجراء المباشر
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isLocked)
                          Row(
                            children: [
                              Icon(Icons.lock_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                i18n.t('lesson_locked_badge'),
                                style: AppTypography.caption.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        else if (isDone)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 4),
                            decoration: BoxDecoration(
                              color: ColorTokens.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(RadiusTokens.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 14, color: ColorTokens.success),
                                const SizedBox(width: 4),
                                Text(
                                  i18n.t('review_lesson'),
                                  style: AppTypography.caption.copyWith(
                                    color: ColorTokens.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(RadiusTokens.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow_rounded, size: 15, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  i18n.t('start_lesson'),
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLessonTap(
    BuildContext context,
    AppStateService state,
    Lesson lesson,
    bool isLocked,
    I18nService i18n,
  ) {
    if (isLocked) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 20),
              const SizedBox(width: Space.sm),
              Expanded(child: Text(i18n.t('locked_lesson_alert'))),
            ],
          ),
          backgroundColor: ColorTokens.warning,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonViewerScreen(lesson: lesson)),
    );
  }

  /// نافذة منبثقة لعرض كافة المواد والمقررات مع إمكانية التبديل أو البحث
  void _openAllCoursesModal(BuildContext context, AppStateService state, I18nService i18n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.sheet)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final cs = Theme.of(modalCtx).colorScheme;
            final activeCur = state.activeCurriculum;

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.92,
              minChildSize: 0.5,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // مقبض السحب
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: Space.md),
                          decoration: BoxDecoration(
                            color: cs.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              i18n.t('all_materials_modal'),
                              style: AppTypography.title.copyWith(color: cs.onSurface),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.table_chart_outlined, size: 20),
                            tooltip: i18n.t('export_research_csv'),
                            onPressed: () => _exportCsvData(context, state),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.md),

                      // تبديل المسار والتخصص ضمن النافذة
                      Text(
                        i18n.t('curriculum'),
                        style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: Space.xs),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: state.curricula.map((c) {
                            final isSel = c.id == state.activeCurriculumId;
                            return Padding(
                              padding: const EdgeInsets.only(left: Space.sm),
                              child: ChoiceChip(
                                selected: isSel,
                                selectedColor: cs.primary,
                                label: Text(c.name),
                                onSelected: (val) {
                                  if (val) {
                                    state.setActiveCurriculum(c.id);
                                    setModalState(() {});
                                    setState(() {
                                      _selectedCourseId = null;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(height: 24),

                      // قائمة كافة المقررات
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: activeCur.courses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: Space.sm),
                          itemBuilder: (_, cIdx) {
                            final course = activeCur.courses[cIdx];
                            final isSel = course.id == _selectedCourseId;
                            final total = _totalPublishedLessons(course);
                            final done = _completedLessons(course, state);
                            final progress = total > 0 ? (done / total) : 0.0;

                            return Container(
                              decoration: BoxDecoration(
                                color: isSel ? cs.primary.withOpacity(0.08) : cs.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(RadiusTokens.card),
                                border: Border.all(
                                  color: isSel ? cs.primary : cs.outlineVariant,
                                  width: isSel ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    _selectedCourseId = course.id;
                                  });
                                  Navigator.pop(modalCtx);
                                },
                                leading: CircleAvatar(
                                  backgroundColor: cs.primary.withOpacity(0.12),
                                  child: Icon(_resolveCourseIcon(course.iconName), color: cs.primary),
                                ),
                                title: Text(
                                  course.title,
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${course.code} • ${course.description}',
                                      style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 4,
                                        backgroundColor: cs.surfaceContainerHighest,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          progress >= 1.0 ? ColorTokens.success : cs.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSel ? cs.primary : cs.surfaceContainerHighest,
                                    foregroundColor: isSel ? cs.onPrimary : cs.onSurface,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedCourseId = course.id;
                                    });
                                    Navigator.pop(modalCtx);
                                  },
                                  child: Text(isSel ? i18n.t('active_course') : i18n.t('select_course')),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _exportCsvData(BuildContext context, AppStateService state) async {
    final csv = await state.exportResearchCsv();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(I18nService.instance.t('export_research_csv')),
        content: SingleChildScrollView(
          child: SelectableText(
            csv,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: Text(I18nService.instance.t('close'))),
        ],
      ),
    );
  }
}

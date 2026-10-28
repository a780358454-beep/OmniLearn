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
      case 'medical':
      case 'cpr':
      case 'health':
        return Icons.medical_services_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  int _totalPublishedLessons(Course course) {
    var count = 0;
    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        if (lesson.status == ContentStatus.published) {
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
        if (lesson.status == ContentStatus.published && state.isLessonCompleted(lesson.id)) {
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
            // 1. شريط الإحصائيات (Streak, XP, Completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.md),
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
                    label: '${user.xp} ${i18n.t('total_xp')}',
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

            // 2. أزرار الوصول السريع للأدمن والمؤلف
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
                            '$doneActiveLessons ${i18n.t('completed_of_total')} $totalActiveLessons دروس',
                            style: AppTypography.caption.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w640,
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
                                    '$doneL / $totalL دروس',
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
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Space.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var module in activeCourse.modules) ...[
                            Row(
                              children: [
                                Icon(Icons.bookmark_outline_rounded, size: 18, color: cs.primary),
                                const SizedBox(width: Space.xs),
                                Expanded(
                                  child: Text(
                                    module.title,
                                    style: AppTypography.label.copyWith(color: cs.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Space.sm),
                            for (var lesson in module.lessons)
                              if (lesson.status == ContentStatus.published)
                                _buildLessonTile(context, state, lesson, i18n),
                            const SizedBox(height: Space.md),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],

            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTile(BuildContext context, AppStateService state, Lesson lesson, I18nService i18n) {
    final isDone = state.isLessonCompleted(lesson.id);
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: Space.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(
          color: isDone ? ColorTokens.success.withOpacity(0.4) : cs.outlineVariant,
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
              : cs.primary.withOpacity(0.15),
          child: Icon(
            isDone ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
            color: isDone ? ColorTokens.success : cs.primary,
          ),
        ),
        title: Text(
          lesson.title,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        subtitle: Text(
          '${lesson.summary} • +${lesson.xpReward} XP',
          style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
          decoration: BoxDecoration(
            color: isDone
                ? ColorTokens.success.withOpacity(0.12)
                : cs.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(RadiusTokens.pill),
          ),
          child: Text(
            isDone ? i18n.t('review_lesson') : i18n.t('start_lesson'),
            style: AppTypography.caption.copyWith(
              color: isDone ? ColorTokens.success : cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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

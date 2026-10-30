import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/services/cloud_sync_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/models/learning_models.dart';
import '../../core/design/design_tokens.dart';
import '../../core/widgets/core_components.dart';
import '../../core/security/content_sanitizer.dart';

class CreatorStudioScreen extends StatefulWidget {
  const CreatorStudioScreen({Key? key}) : super(key: key);

  @override
  State<CreatorStudioScreen> createState() => _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends State<CreatorStudioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    final i18n = I18nService.instance;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal_rounded, color: colorScheme.primary, size: 22),
            const SizedBox(width: Space.sm),
            Text(i18n.t('studio_title')),
          ],
        ),
        actions: [
          IconButton(
            tooltip: i18n.t('push_to_cloud'),
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(i18n.t('cloud_syncing')),
                  duration: const Duration(seconds: 1),
                ),
              );
              final ok = await state.pushCurriculaToCloud();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? i18n.t('cloud_upload_success') : i18n.t('cloud_sync_failed')),
                    backgroundColor: ok ? ColorTokens.success : ColorTokens.error,
                  ),
                );
              }
            },
          ),
          IconButton(
            tooltip: i18n.t('export_json'),
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () => _showExportDialog(context, state),
          ),
          IconButton(
            tooltip: i18n.t('import_json'),
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _showImportDialog(context, state, i18n),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          tabs: [
            Tab(icon: const Icon(Icons.hub_rounded), text: i18n.t('courses')),
            Tab(icon: const Icon(Icons.assignment_turned_in_rounded), text: i18n.t('my_contributions')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurriculumTreeView(state, i18n, colorScheme),
          _buildMyContributionsView(state, i18n, colorScheme),
        ],
      ),
    );
  }

  // 1. شجرة المسار والمقررات والوحدات
  Widget _buildCurriculumTreeView(AppStateService state, I18nService i18n, ColorScheme colorScheme) {
    final cur = state.activeCurriculum;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: state.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(i18n.t('new_course')),
              onPressed: () => _showAddCourseDialog(context, state, i18n),
            )
          : null,
      body: cur.courses.isEmpty
          ? EmptyState(
              icon: Icons.code_rounded,
              title: i18n.t('empty_courses_title'),
              reason: i18n.t('empty_courses_reason'),
              actionLabel: state.isAdmin ? i18n.t('new_course') : null,
              onAction: state.isAdmin ? () => _showAddCourseDialog(context, state, i18n) : null,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(Space.lg),
              itemCount: cur.courses.length,
              itemBuilder: (ctx, idx) {
                final course = cur.courses[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: Space.lg),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary.withOpacity(0.12),
                      child: Icon(Icons.code_rounded, color: colorScheme.primary),
                    ),
                    title: Text(course.title, style: AppTypography.title.copyWith(fontSize: 16)),
                    subtitle: Text('${course.code} • ${course.modules.length} ${i18n.t('unit_label')}'),
                    trailing: state.isAdmin
                        ? IconButton(
                            icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
                            tooltip: i18n.t('new_module'),
                            onPressed: () => _showAddModuleDialog(context, state, course.id, i18n),
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.description,
                              style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            const Divider(height: 24),
                            if (course.modules.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(Space.md),
                                child: Text(
                                  i18n.t('coming_soon_module'),
                                  style: AppTypography.caption,
                                ),
                              )
                            else
                              for (var module in course.modules)
                                _buildModuleItem(context, state, course.id, module, i18n),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // 2. قائمة مساهمات المستخدم ومتابعة الاعتماد
  Widget _buildMyContributionsView(AppStateService state, I18nService i18n, ColorScheme colorScheme) {
    final myLessons = state.getUserContributions(state.currentUser.id);

    if (myLessons.isEmpty) {
      return EmptyState(
        icon: Icons.post_add_rounded,
        title: 'لا توجد مساهمات مقترحة بعد',
        reason: 'يمكنك المساهمة بكتابة دروس برمجية واختبارات لترسل إلى الإدارة للاعتماد والنشر.',
        actionLabel: i18n.t('contribute_lesson'),
        onAction: () => _tabController.animateTo(0),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(Space.lg),
      itemCount: myLessons.length + (state.hasLocalDrafts ? 1 : 0),
      itemBuilder: (ctx, idx) {
        // شريط طابور المسودات المحلية الجاهزة للرفع سحابياً
        if (state.hasLocalDrafts && idx == 0) {
          final draftsCount = state.getLocalDrafts().length;
          return Container(
            margin: const EdgeInsets.only(bottom: Space.lg),
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: Colors.amber.shade700.withOpacity(0.12),
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              border: Border.all(color: Colors.amber.shade700.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: Colors.amber.shade800, size: 24),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i18n.t('offline_drafts_found')} ($draftsCount)',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'اضغط هنا لرفع كافة المسودات للمراجعة والاعتماد السحابي دفعة واحدة.',
                        style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.sm),
                FilledButton.tonal(
                  onPressed: () async {
                    await state.syncAllLocalDrafts();
                  },
                  child: Text(i18n.t('sync_all_drafts')),
                ),
              ],
            ),
          );
        }

        final actualIdx = state.hasLocalDrafts ? idx - 1 : idx;
        final lesson = myLessons[actualIdx];
        return Card(
          margin: const EdgeInsets.only(bottom: Space.md),
          child: Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatusBadge(lesson.status, i18n),
                    const Spacer(),
                    Text(
                      '+${lesson.xpReward} XP',
                      style: AppTypography.caption.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.md),
                Text(lesson.title, style: AppTypography.title.copyWith(fontSize: 16)),
                if (lesson.titleEn != null && lesson.titleEn!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(lesson.titleEn!, style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: Space.xs),
                Text(lesson.summary, style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: Space.sm),
                Text(
                  '${lesson.cards.length} بطاقات شرح • ${lesson.quizzes.length} أسئلة',
                  style: AppTypography.caption.copyWith(color: colorScheme.primary),
                ),

                // عرض ملاحظات الإدارة وتعليق المراجعة إن وجد
                if (lesson.adminComment != null && lesson.adminComment!.isNotEmpty) ...[
                  const SizedBox(height: Space.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Space.md),
                    decoration: BoxDecoration(
                      color: (lesson.isNeedsRevision ? ColorTokens.warning : ColorTokens.error).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(RadiusTokens.card),
                      border: Border.all(
                        color: (lesson.isNeedsRevision ? ColorTokens.warning : ColorTokens.error).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              lesson.isNeedsRevision ? Icons.feedback_outlined : Icons.info_outline,
                              size: 16,
                              color: lesson.isNeedsRevision ? ColorTokens.warning : ColorTokens.error,
                            ),
                            const SizedBox(width: Space.xs),
                            Text(
                              i18n.t('admin_feedback'),
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: lesson.isNeedsRevision ? ColorTokens.warning : ColorTokens.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.adminComment!,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],

                // إجراءات دورة المراجعة والتعديل المباشر (Revision Cycle Action)
                if (lesson.isNeedsRevision || lesson.isRejected || lesson.isLocalDraft) ...[
                  const SizedBox(height: Space.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          final ctxMap = state.findLessonContext(lesson.id);
                          if (ctxMap != null) {
                            final course = ctxMap['course'] as Course;
                            final module = ctxMap['module'] as CourseModule;
                            _showAddLessonDialog(
                              context,
                              state,
                              course.id,
                              module.id,
                              i18n,
                              existingLesson: lesson,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تعذر تحديد الوحدة التابعة لهذا الدرس.')),
                            );
                          }
                        },
                        icon: Icon(
                          lesson.isNeedsRevision || lesson.isRejected
                              ? Icons.edit_note_rounded
                              : Icons.edit_document,
                          size: 18,
                        ),
                        label: Text(
                          lesson.isNeedsRevision || lesson.isRejected
                              ? i18n.t('edit_and_resubmit')
                              : i18n.t('save_changes'),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: lesson.isNeedsRevision
                              ? Colors.orange.shade800
                              : (lesson.isRejected ? ColorTokens.error : colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(ContentStatus status, I18nService i18n) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case ContentStatus.approved:
      case ContentStatus.published:
        color = ColorTokens.accentGreen;
        label = i18n.t('status_approved');
        icon = Icons.check_circle_rounded;
        break;
      case ContentStatus.pendingReview:
      case ContentStatus.inReview:
        color = ColorTokens.warning;
        label = i18n.t('status_pending');
        icon = Icons.hourglass_top_rounded;
        break;
      case ContentStatus.needsRevision:
        color = Colors.orange;
        label = i18n.t('status_needs_revision');
        icon = Icons.edit_notifications_rounded;
        break;
      case ContentStatus.rejected:
        color = ColorTokens.error;
        label = i18n.t('status_rejected');
        icon = Icons.cancel_rounded;
        break;
      case ContentStatus.localDraft:
      case ContentStatus.draft:
        color = Colors.grey;
        label = i18n.t('status_draft');
        icon = Icons.edit_document;
        break;
      default:
        color = Colors.blueGrey;
        label = status.name;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildModuleItem(
    BuildContext context,
    AppStateService state,
    String courseId,
    CourseModule module,
    I18nService i18n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: Space.md),
      padding: const EdgeInsets.all(Space.md),
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
              Expanded(
                child: Text(
                  module.title,
                  style: AppTypography.label.copyWith(color: colorScheme.primary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_task_rounded, size: 20),
                tooltip: i18n.t('contribute_lesson'),
                onPressed: () => _showAddLessonDialog(context, state, courseId, module.id, i18n),
              ),
            ],
          ),
          if (module.lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xs),
              child: Text(
                'لا توجد دروس مضافة في هذه الوحدة بعد.',
                style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            )
          else
            for (var l in module.lessons)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  l.isApproved ? Icons.verified_rounded : Icons.hourglass_empty_rounded,
                  size: 18,
                  color: l.isApproved ? ColorTokens.accentGreen : ColorTokens.warning,
                ),
                title: Text(l.title),
                subtitle: Text('${l.cards.length} بطاقات • ${l.quizzes.length} أسئلة'),
                trailing: _buildStatusBadge(l.status, i18n),
              ),
        ],
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context, AppStateService state, I18nService i18n) {
    final titleC = TextEditingController();
    final codeC = TextEditingController();
    final descC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.t('new_course')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleC, decoration: InputDecoration(labelText: i18n.t('course_title_hint'))),
            const SizedBox(height: Space.sm),
            TextField(controller: codeC, decoration: InputDecoration(labelText: i18n.t('course_code_hint'))),
            const SizedBox(height: Space.sm),
            TextField(controller: descC, decoration: InputDecoration(labelText: i18n.t('course_desc_hint'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(i18n.t('cancel'))),
          ElevatedButton(
            onPressed: () {
              if (titleC.text.isNotEmpty) {
                state.addCourseToActiveCurriculum(
                  title: titleC.text.trim(),
                  code: codeC.text.trim(),
                  description: descC.text.trim(),
                  iconName: 'code',
                );
                Navigator.pop(ctx);
              }
            },
            child: Text(i18n.t('save_changes')),
          ),
        ],
      ),
    );
  }

  void _showAddModuleDialog(BuildContext context, AppStateService state, String courseId, I18nService i18n) {
    final titleC = TextEditingController();
    final descC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.t('new_module')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleC, decoration: InputDecoration(labelText: i18n.t('module_title_hint'))),
            const SizedBox(height: Space.sm),
            TextField(controller: descC, decoration: InputDecoration(labelText: i18n.t('module_desc_hint'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(i18n.t('cancel'))),
          ElevatedButton(
            onPressed: () {
              if (titleC.text.isNotEmpty) {
                state.addModuleToCourse(
                  courseId: courseId,
                  title: titleC.text.trim(),
                  description: descC.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: Text(i18n.t('save_changes')),
          ),
        ],
      ),
    );
  }

  // نموذج إضافة واقتراح وتعديل الدرس المعزول لغوياً والمبسط للمجتمع
  void _showAddLessonDialog(
    BuildContext context,
    AppStateService state,
    String courseId,
    String moduleId,
    I18nService i18n, {
    Lesson? existingLesson,
  }) {
    // 1. التحقق الصارم من الملكية والصلاحيات قبل فتح نموذج التعديل
    if (existingLesson != null && !state.isAdmin) {
      final isOwner = existingLesson.authorId == state.currentUser.id ||
          existingLesson.creatorId == state.currentUser.id;
      final isSystem = existingLesson.authorId == null ||
          existingLesson.authorId == 'system' ||
          existingLesson.authorId == 'admin';
      if (isSystem || !isOwner) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('عذراً، دروس النظام الرسمية ودروس المؤلفين الآخرين محمية ولا يمكن تعديلها.'),
            backgroundColor: ColorTokens.error,
          ),
        );
        return;
      }
    }

    final isEditing = existingLesson != null;

    final lessonTitleArC = TextEditingController(text: existingLesson?.title ?? '');
    final lessonTitleEnC = TextEditingController(text: existingLesson?.titleEn ?? '');
    final lessonSummaryArC = TextEditingController(text: existingLesson?.summary ?? '');
    final lessonSummaryEnC = TextEditingController(text: existingLesson?.summaryEn ?? '');

    final existingCard = existingLesson != null && existingLesson.cards.isNotEmpty
        ? existingLesson.cards.first
        : null;

    final cardTitleArC = TextEditingController(text: existingCard?.title ?? '');
    final cardTitleEnC = TextEditingController(text: existingCard?.titleEn ?? '');
    final cardContentArC = TextEditingController(text: existingCard?.content ?? '');
    final cardContentEnC = TextEditingController(text: existingCard?.contentEn ?? '');
    final codeSnippetC = TextEditingController(text: existingCard?.codeSnippet ?? '');

    final existingQuiz = existingLesson != null && existingLesson.quizzes.isNotEmpty
        ? existingLesson.quizzes.first
        : null;

    QuizType selectedQuizType = existingQuiz?.type ?? QuizType.singleChoice;
    final quizPromptArC = TextEditingController(text: existingQuiz?.prompt ?? '');
    final quizPromptEnC = TextEditingController(text: existingQuiz?.promptEn ?? '');
    final quizExplanationArC = TextEditingController(text: existingQuiz?.explanation ?? '');
    final quizExplanationEnC = TextEditingController(text: existingQuiz?.explanationEn ?? '');

    String initialCorrect = '';
    String initialWrong = '';
    String initialWhyWrong = '';

    if (existingQuiz != null && existingQuiz.optionsList.isNotEmpty) {
      for (final opt in existingQuiz.optionsList) {
        if (opt.isCorrect && initialCorrect.isEmpty) {
          initialCorrect = opt.text;
        } else if (!opt.isCorrect && initialWrong.isEmpty) {
          initialWrong = opt.text;
          initialWhyWrong = opt.whyWrong;
        }
      }
    }

    final correctOptC = TextEditingController(text: initialCorrect);
    final wrongOptC = TextEditingController(text: initialWrong);
    final whyWrongC = TextEditingController(text: initialWhyWrong);

    int selectedTab = 0; // 0: عربي (RTL), 1: English & Code (LTR)

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isEditing ? Icons.edit_note_rounded : Icons.post_add_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: Space.sm),
              Text(
                isEditing
                    ? '${i18n.t('edit_and_resubmit')}: ${existingLesson.title}'
                    : i18n.t('contribute_lesson'),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شريط تبويب عزل اللغات تماماً (Bilingual Isolation Tabs)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setDState(() => selectedTab = 0),
                            borderRadius: BorderRadius.circular(RadiusTokens.pill),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: Space.xs + 2),
                              decoration: BoxDecoration(
                                color: selectedTab == 0
                                    ? Theme.of(context).colorScheme.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(RadiusTokens.pill),
                                boxShadow: selectedTab == 0
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]
                                    : [],
                              ),
                              child: Text(
                                i18n.t('arabic_content_tab'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: selectedTab == 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setDState(() => selectedTab = 1),
                            borderRadius: BorderRadius.circular(RadiusTokens.pill),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: Space.xs + 2),
                              decoration: BoxDecoration(
                                color: selectedTab == 1
                                    ? Theme.of(context).colorScheme.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(RadiusTokens.pill),
                                boxShadow: selectedTab == 1
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]
                                    : [],
                              ),
                              child: Text(
                                i18n.t('english_content_tab'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: selectedTab == 1
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.md),

                  // عرض القسم بحسب التبويب المختار
                  if (selectedTab == 0) ...[
                    // --- القسم العربي (RTL) ---
                    const Text('1. عنوان وملخص الدرس (بالعربية):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: Space.xs),
                    TextField(
                      controller: lessonTitleArC,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(labelText: i18n.t('lesson_title_hint')),
                    ),
                    const SizedBox(height: Space.sm),
                    TextField(
                      controller: lessonSummaryArC,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(labelText: i18n.t('lesson_summary_hint')),
                    ),
                    const Divider(height: 24),

                    const Text('2. بطاقة الشرح البرمجية (بالعربية):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: Space.xs),
                    TextField(
                      controller: cardTitleArC,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(labelText: i18n.t('card_title_hint')),
                    ),
                    const SizedBox(height: Space.sm),
                    TextField(
                      controller: cardContentArC,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: i18n.t('card_content_hint')),
                    ),
                    const Divider(height: 24),

                    const Text('3. السؤال التفاعلي المحلول (بالعربية):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: Space.xs),
                    DropdownButtonFormField<QuizType>(
                      value: selectedQuizType,
                      decoration: InputDecoration(labelText: i18n.t('select_quiz_type')),
                      items: QuizType.values.map((qt) {
                        return DropdownMenuItem(value: qt, child: Text(qt.name));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDState(() => selectedQuizType = val);
                      },
                    ),
                    const SizedBox(height: Space.sm),
                    TextField(
                      controller: quizPromptArC,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(labelText: i18n.t('quiz_prompt_hint')),
                    ),
                    const SizedBox(height: Space.sm),
                    TextField(
                      controller: correctOptC,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(labelText: i18n.t('correct_opt_hint')),
                    ),
                    const SizedBox(height: Space.sm),
                    TextField(
                      controller: wrongOptC,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(labelText: i18n.t('wrong_opt_hint')),
                    ),
                    const SizedBox(height: Space.sm),
                    TextField(
                      controller: whyWrongC,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(labelText: 'سبب خطأ الإجابة البديلة (whyWrong)'),
                    ),
                    const SizedBox(height: Space.sm),
                    TextField(
                      controller: quizExplanationArC,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(labelText: i18n.t('quiz_explanation_hint')),
                    ),
                  ] else ...[
                    // --- القسم الإنجليزي والأكواد (LTR) ---
                    const Text('1. Lesson Info (English LTR):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: Space.xs),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        children: [
                          TextField(
                            controller: lessonTitleEnC,
                            decoration: InputDecoration(labelText: i18n.t('title_en_hint')),
                          ),
                          const SizedBox(height: Space.sm),
                          TextField(
                            controller: lessonSummaryEnC,
                            decoration: InputDecoration(labelText: i18n.t('summary_en_hint')),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24),

                    const Text('2. Explanation & Code (English LTR):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: Space.xs),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        children: [
                          TextField(
                            controller: cardTitleEnC,
                            decoration: InputDecoration(labelText: i18n.t('card_title_en_hint')),
                          ),
                          const SizedBox(height: Space.sm),
                          TextField(
                            controller: cardContentEnC,
                            maxLines: 2,
                            decoration: InputDecoration(labelText: i18n.t('card_content_en_hint')),
                          ),
                          const SizedBox(height: Space.sm),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(RadiusTokens.card),
                              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                            ),
                            padding: const EdgeInsets.all(Space.sm),
                            child: TextField(
                              controller: codeSnippetC,
                              maxLines: 4,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: ColorTokens.accentGreen,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: '${i18n.t('code_snippet')} (LTR Monospace)',
                                labelStyle: const TextStyle(color: Colors.white70),
                                hintText: '// Write pure code snippet here...',
                                hintStyle: const TextStyle(color: Colors.white38),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24),

                    const Text('3. Quiz in English (Optional):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: Space.xs),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        children: [
                          TextField(
                            controller: quizPromptEnC,
                            decoration: InputDecoration(labelText: i18n.t('quiz_prompt_en_hint')),
                          ),
                          const SizedBox(height: Space.sm),
                          TextField(
                            controller: quizExplanationEnC,
                            decoration: InputDecoration(labelText: i18n.t('quiz_explanation_en_hint')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(i18n.t('cancel'))),
            // خيار 1: حفظ كمسودة محلية
            OutlinedButton(
              onPressed: () {
                if (lessonTitleArC.text.isNotEmpty) {
                  _saveAndSubmit(
                    state: state,
                    courseId: courseId,
                    moduleId: moduleId,
                    existingLessonId: existingLesson?.id,
                    titleAr: lessonTitleArC.text.trim(),
                    titleEn: lessonTitleEnC.text.trim(),
                    summaryAr: lessonSummaryArC.text.trim(),
                    summaryEn: lessonSummaryEnC.text.trim(),
                    cardTitleAr: cardTitleArC.text.trim(),
                    cardTitleEn: cardTitleEnC.text.trim(),
                    cardContentAr: cardContentArC.text.trim(),
                    cardContentEn: cardContentEnC.text.trim(),
                    codeSnippet: codeSnippetC.text.trim(),
                    quizType: selectedQuizType,
                    quizPromptAr: quizPromptArC.text.trim(),
                    quizPromptEn: quizPromptEnC.text.trim(),
                    correctOpt: correctOptC.text.trim(),
                    wrongOpt: wrongOptC.text.trim(),
                    whyWrong: whyWrongC.text.trim(),
                    explanationAr: quizExplanationArC.text.trim(),
                    explanationEn: quizExplanationEnC.text.trim(),
                    submitForReview: false,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(i18n.t('offline_draft_notice'))),
                  );
                }
              },
              child: Text(i18n.t('save_draft')),
            ),
            // خيار 2: إرسال للمراجعة والاعتماد السحابي
            ElevatedButton(
              onPressed: () {
                if (lessonTitleArC.text.isNotEmpty) {
                  _saveAndSubmit(
                    state: state,
                    courseId: courseId,
                    moduleId: moduleId,
                    existingLessonId: existingLesson?.id,
                    titleAr: lessonTitleArC.text.trim(),
                    titleEn: lessonTitleEnC.text.trim(),
                    summaryAr: lessonSummaryArC.text.trim(),
                    summaryEn: lessonSummaryEnC.text.trim(),
                    cardTitleAr: cardTitleArC.text.trim(),
                    cardTitleEn: cardTitleEnC.text.trim(),
                    cardContentAr: cardContentArC.text.trim(),
                    cardContentEn: cardContentEnC.text.trim(),
                    codeSnippet: codeSnippetC.text.trim(),
                    quizType: selectedQuizType,
                    quizPromptAr: quizPromptArC.text.trim(),
                    quizPromptEn: quizPromptEnC.text.trim(),
                    correctOpt: correctOptC.text.trim(),
                    wrongOpt: wrongOptC.text.trim(),
                    whyWrong: whyWrongC.text.trim(),
                    explanationAr: quizExplanationArC.text.trim(),
                    explanationEn: quizExplanationEnC.text.trim(),
                    submitForReview: true,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'تمت إعادة إرسال الدرس بنجاح مع الحفاظ على المعرّف! بانتظار الاعتماد سحابياً. 🚀'
                            : 'تم إرسال درسك بنجاح! سيتاح لجميع الطلاب فور اعتماده من الإدارة. ⏳',
                      ),
                      backgroundColor: ColorTokens.success,
                    ),
                  );
                }
              },
              child: Text(isEditing ? i18n.t('edit_and_resubmit') : i18n.t('submit_for_review')),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndSubmit({
    required AppStateService state,
    required String courseId,
    required String moduleId,
    String? existingLessonId,
    required String titleAr,
    required String titleEn,
    required String summaryAr,
    required String summaryEn,
    required String cardTitleAr,
    required String cardTitleEn,
    required String cardContentAr,
    required String cardContentEn,
    required String codeSnippet,
    required QuizType quizType,
    required String quizPromptAr,
    required String quizPromptEn,
    required String correctOpt,
    required String wrongOpt,
    required String whyWrong,
    required String explanationAr,
    required String explanationEn,
    required bool submitForReview,
  }) {
    // 1. تطبيق فلتر الأمان وتطهير المدخلات (ContentSanitizer)
    final safeTitleAr = ContentSanitizer.sanitizeText(titleAr);
    final safeTitleEn = ContentSanitizer.sanitizeText(titleEn);
    final safeSummaryAr = ContentSanitizer.sanitizeText(summaryAr);
    final safeSummaryEn = ContentSanitizer.sanitizeText(summaryEn);
    final safeCardTitleAr = ContentSanitizer.sanitizeText(cardTitleAr);
    final safeCardTitleEn = ContentSanitizer.sanitizeText(cardTitleEn);
    final safeCardContentAr = ContentSanitizer.sanitizeText(cardContentAr);
    final safeCardContentEn = ContentSanitizer.sanitizeText(cardContentEn);
    final safeCodeSnippet = ContentSanitizer.sanitizeCode(codeSnippet);
    final safePromptAr = ContentSanitizer.sanitizeText(quizPromptAr);
    final safePromptEn = ContentSanitizer.sanitizeText(quizPromptEn);
    final safeCorrect = ContentSanitizer.sanitizeText(correctOpt);
    final safeWrong = ContentSanitizer.sanitizeText(wrongOpt);
    final safeWhyWrong = ContentSanitizer.sanitizeText(whyWrong);
    final safeExpAr = ContentSanitizer.sanitizeText(explanationAr);
    final safeExpEn = ContentSanitizer.sanitizeText(explanationEn);

    // 2. ثبات المعرّف وعدم تغييره عند التعديل لحماية تقدم الطلاب
    final lessonId = existingLessonId ?? 'lesson_${DateTime.now().millisecondsSinceEpoch}';
    final existingMap = existingLessonId != null ? state.findLessonContext(existingLessonId) : null;
    final existingLesson = existingMap != null ? existingMap['lesson'] as Lesson : null;

    // التحقق الصارم من الأمان والصلاحيات
    if (existingLesson != null && !state.isAdmin) {
      final isOwner = existingLesson.authorId == state.currentUser.id ||
          existingLesson.creatorId == state.currentUser.id;
      final isSystemLesson = existingLesson.authorId == null ||
          existingLesson.authorId == 'system' ||
          existingLesson.authorId == 'admin';
      if (isSystemLesson || !isOwner) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('عذراً، لا يمكنك تعديل هذا الدرس. دروس النظام والدروس المعتمدة للآخرين محمية.'),
            backgroundColor: ColorTokens.error,
          ),
        );
        return;
      }
    }

    // 3. النسخ الظلية (Shadow Versioning): إذا كان الدرس منشوراً ومعتمداً بالفعل،
    // لا نمس النسخة المنشورة للطلاب، بل نحفظ التعديل كنسخة ظل معلقة لمراجعة الإدارة
    if (existingLesson != null && existingLesson.isApproved && !state.isAdmin && submitForReview) {
      existingLesson.pendingUpdatePayload = {
        'title': safeTitleAr,
        'titleEn': safeTitleEn.isNotEmpty ? safeTitleEn : null,
        'summary': safeSummaryAr.isNotEmpty ? safeSummaryAr : 'درس برمجي مقدم من المجتمع.',
        'summaryEn': safeSummaryEn.isNotEmpty ? safeSummaryEn : null,
        'cards': [
          LessonCard(
            title: safeCardTitleAr.isNotEmpty ? safeCardTitleAr : 'شرح المفهوم',
            titleEn: safeCardTitleEn.isNotEmpty ? safeCardTitleEn : null,
            content: safeCardContentAr.isNotEmpty ? safeCardContentAr : 'شرح وتوضيح المفهوم البرمجي.',
            contentEn: safeCardContentEn.isNotEmpty ? safeCardContentEn : null,
            codeSnippet: safeCodeSnippet.isNotEmpty ? safeCodeSnippet : null,
          ).toJson(),
        ],
        'quizzes': [
          QuizQuestion(
            id: 'q_${DateTime.now().millisecondsSinceEpoch}',
            type: quizType,
            prompt: safePromptAr.isNotEmpty ? safePromptAr : 'سؤال اختباري تفاعلي',
            promptEn: safePromptEn.isNotEmpty ? safePromptEn : null,
            explanation: safeExpAr.isNotEmpty ? safeExpAr : 'تعليل الحل الصحيح.',
            explanationEn: safeExpEn.isNotEmpty ? safeExpEn : null,
            optionsList: [
              QuizOption(
                text: safeCorrect.isNotEmpty ? safeCorrect : 'الخيار الصحيح',
                isCorrect: true,
              ),
              QuizOption(
                text: safeWrong.isNotEmpty ? safeWrong : 'الخيار البديل',
                isCorrect: false,
                whyWrong: safeWhyWrong.isNotEmpty ? safeWhyWrong : 'خيار غير دقيق برمجياً.',
              ),
            ],
          ).toJson(),
        ],
        'updatedAt': DateTime.now().toIso8601String(),
      };
      // يبقى الدرس معتمداً للطلاب دون أي انقطاع مع حفظ رسالة المراجعة
      existingLesson.submittedAt = DateTime.now();
      existingLesson.reviewThread.add(
        ReviewMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: state.currentUser.id,
          senderName: state.currentUser.name.isNotEmpty ? state.currentUser.name : 'مساهم',
          senderRole: state.currentUser.role,
          message: 'تم اقتراح تعديل على الدرس المنشور، بانتظار مراجعة واعتماد الإدارة.',
        ),
      );
      state.addLessonToModule(
        courseId: courseId,
        moduleId: moduleId,
        lesson: existingLesson,
        submitForReview: true,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال التعديل للمراجعة بنجاح، وستبقى النسخة المنشورة متاحة للطلاب.'),
          backgroundColor: ColorTokens.accentGreen,
        ),
      );
      return;
    }

    final newLesson = Lesson(
      id: lessonId,
      moduleId: moduleId,
      title: safeTitleAr,
      titleEn: safeTitleEn.isNotEmpty ? safeTitleEn : null,
      summary: safeSummaryAr.isNotEmpty ? safeSummaryAr : 'درس برمجي مقدم من المجتمع.',
      summaryEn: safeSummaryEn.isNotEmpty ? safeSummaryEn : null,
      orderIndex: 1,
      authorId: state.currentUser.id,
      authorName: state.currentUser.name,
      status: submitForReview ? ContentStatus.pendingReview : ContentStatus.localDraft,
      submittedAt: submitForReview ? DateTime.now() : null,
      cards: [
        LessonCard(
          title: safeCardTitleAr.isNotEmpty ? safeCardTitleAr : 'شرح المفهوم',
          titleEn: safeCardTitleEn.isNotEmpty ? safeCardTitleEn : null,
          content: safeCardContentAr.isNotEmpty ? safeCardContentAr : 'شرح وتوضيح المفهوم البرمجي.',
          contentEn: safeCardContentEn.isNotEmpty ? safeCardContentEn : null,
          codeSnippet: safeCodeSnippet.isNotEmpty ? safeCodeSnippet : null,
        ),
      ],
      quizzes: [
        QuizQuestion(
          id: 'q_${DateTime.now().millisecondsSinceEpoch}',
          type: quizType,
          prompt: safePromptAr.isNotEmpty ? safePromptAr : 'سؤال اختباري تفاعلي',
          promptEn: safePromptEn.isNotEmpty ? safePromptEn : null,
          explanation: safeExpAr.isNotEmpty ? safeExpAr : 'تعليل الحل الصحيح.',
          explanationEn: safeExpEn.isNotEmpty ? safeExpEn : null,
          optionsList: [
            QuizOption(
              text: safeCorrect.isNotEmpty ? safeCorrect : 'الخيار الصحيح',
              isCorrect: true,
            ),
            QuizOption(
              text: safeWrong.isNotEmpty ? safeWrong : 'الخيار البديل',
              isCorrect: false,
              whyWrong: safeWhyWrong.isNotEmpty ? safeWhyWrong : 'خيار غير دقيق برمجياً.',
            ),
          ],
        ),
      ],
    );

    state.addLessonToModule(
      courseId: courseId,
      moduleId: moduleId,
      lesson: newLesson,
      submitForReview: submitForReview,
    );
  }

  void _showExportDialog(BuildContext context, AppStateService state) {
    final jsonStr = state.exportActiveCurriculumJson();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('JSON Export (Strict Schema)'),
        content: SingleChildScrollView(
          child: SelectableText(
            jsonStr,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, AppStateService state, I18nService i18n) {
    final textC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.t('import_json')),
        content: TextField(
          controller: textC,
          maxLines: 6,
          decoration: InputDecoration(hintText: i18n.t('paste_json_hint')),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(i18n.t('cancel'))),
          ElevatedButton(
            onPressed: () {
              if (textC.text.isNotEmpty) {
                final success = state.importCurriculumFromJson(textC.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? i18n.t('import_success') : i18n.t('import_error')),
                    backgroundColor: success ? ColorTokens.success : ColorTokens.error,
                  ),
                );
              }
            },
            child: Text(i18n.t('save_changes')),
          ),
        ],
      ),
    );
  }
}

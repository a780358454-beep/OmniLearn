import 'package:flutter/material.dart';
import '../shared/role_guard.dart';
import '../../core/services/app_state_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/models/learning_models.dart';
import '../../core/design/design_tokens.dart';
import '../../core/widgets/core_components.dart';

class CreatorStudioScreen extends StatefulWidget {
  const CreatorStudioScreen({Key? key}) : super(key: key);

  @override
  State<CreatorStudioScreen> createState() => _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends State<CreatorStudioScreen> {
  @override
  Widget build(BuildContext context) {
    if (!AppStateService.instance.canAuthor) {
      return const ForbiddenScreen();
    }
    final state = AppStateService.instance;
    final i18n = I18nService.instance;
    final cur = state.activeCurriculum;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.draw_rounded, color: colorScheme.primary, size: 22),
            const SizedBox(width: Space.sm),
            Text(i18n.t('studio_title')),
          ],
        ),
        actions: [
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(i18n.t('new_course')),
        onPressed: () => _showAddCourseDialog(context, state, i18n),
      ),
      body: cur.courses.isEmpty
          ? EmptyState(
              icon: Icons.library_books_outlined,
              title: i18n.t('empty_courses_title'),
              reason: i18n.t('empty_courses_reason'),
              actionLabel: i18n.t('new_course'),
              onAction: () => _showAddCourseDialog(context, state, i18n),
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
                    subtitle: Text('${course.code} • ${course.modules.length} وحدات'),
                    trailing: IconButton(
                      icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
                      tooltip: i18n.t('new_module'),
                      onPressed: () => _showAddModuleDialog(context, state, course.id, i18n),
                    ),
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
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: Text(i18n.t('new_lesson'), style: const TextStyle(fontSize: 12)),
                onPressed: () => _showAddLessonDialog(context, state, courseId, module.id, i18n),
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          if (module.lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: Text(i18n.t('coming_soon_module'), style: AppTypography.caption),
            )
          else
            for (var lesson in module.lessons)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.play_lesson_outlined, color: ColorTokens.success, size: 18),
                title: Text(lesson.title, style: AppTypography.bodySmall),
                subtitle: Text('+${lesson.xpReward} XP • ${lesson.quizzes.length} أسئلة'),
                trailing: Text(
                  lesson.status.name.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: lesson.status == ContentStatus.published ? ColorTokens.success : ColorTokens.error,
                  ),
                ),
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

  void _showAddLessonDialog(BuildContext context, AppStateService state, String courseId, String moduleId, I18nService i18n) {
    final lessonTitleC = TextEditingController();
    final lessonSummaryC = TextEditingController();
    final cardTitleC = TextEditingController();
    final cardContentC = TextEditingController();
    final codeSnippetC = TextEditingController();

    QuizType selectedQuizType = QuizType.singleChoice;
    final quizPromptC = TextEditingController();
    final quizExplanationC = TextEditingController();
    final option1C = TextEditingController(text: 'الخيار الأول (صحيح)');
    final option2C = TextEditingController(text: 'الخيار الثاني (خاطئ)');
    final whyWrongC = TextEditingController(text: 'هذا الخيار غير صحيح وفق السياق الهندسي.');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(i18n.t('new_lesson')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: lessonTitleC, decoration: InputDecoration(labelText: i18n.t('lesson_title_hint'))),
                const SizedBox(height: Space.sm),
                TextField(controller: lessonSummaryC, decoration: InputDecoration(labelText: i18n.t('lesson_summary_hint'))),
                const Divider(height: 24),

                TextField(controller: cardTitleC, decoration: InputDecoration(labelText: i18n.t('card_title_hint'))),
                const SizedBox(height: Space.sm),
                TextField(controller: cardContentC, maxLines: 2, decoration: InputDecoration(labelText: i18n.t('card_content_hint'))),
                const SizedBox(height: Space.sm),
                TextField(controller: codeSnippetC, maxLines: 2, decoration: InputDecoration(labelText: i18n.t('code_snippet_hint'))),
                const Divider(height: 24),

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
                TextField(controller: quizPromptC, decoration: InputDecoration(labelText: i18n.t('quiz_prompt_hint'))),
                const SizedBox(height: Space.sm),
                TextField(controller: quizExplanationC, decoration: InputDecoration(labelText: i18n.t('quiz_explanation_hint'))),
                const SizedBox(height: Space.sm),
                TextField(controller: option1C, decoration: InputDecoration(labelText: i18n.t('correct_opt_hint'))),
                const SizedBox(height: Space.sm),
                TextField(controller: option2C, decoration: InputDecoration(labelText: i18n.t('wrong_opt_hint'))),
                const SizedBox(height: Space.sm),
                TextField(controller: whyWrongC, decoration: const InputDecoration(labelText: 'سبب خطأ الإجابة البديلة (whyWrong)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(i18n.t('cancel'))),
            ElevatedButton(
              onPressed: () {
                if (lessonTitleC.text.isNotEmpty) {
                  final newLesson = Lesson(
                    id: 'lesson_${DateTime.now().millisecondsSinceEpoch}',
                    moduleId: moduleId,
                    title: lessonTitleC.text.trim(),
                    summary: lessonSummaryC.text.trim(),
                    orderIndex: 1,
                    cards: [
                      LessonCard(
                        title: cardTitleC.text.isNotEmpty ? cardTitleC.text : 'شرح المفهوم',
                        content: cardContentC.text.isNotEmpty ? cardContentC.text : 'محتوى توضيحي.',
                        codeSnippet: codeSnippetC.text.isNotEmpty ? codeSnippetC.text : null,
                      ),
                    ],
                    quizzes: [
                      QuizQuestion(
                        id: 'q_${DateTime.now().millisecondsSinceEpoch}',
                        type: selectedQuizType,
                        prompt: quizPromptC.text.isNotEmpty ? quizPromptC.text : 'سؤال اختباري تفاعلي',
                        explanation: quizExplanationC.text.isNotEmpty ? quizExplanationC.text : 'تفسير منطقي للحل.',
                        optionsList: [
                          QuizOption(text: option1C.text, isCorrect: true),
                          QuizOption(text: option2C.text, isCorrect: false, whyWrong: whyWrongC.text),
                        ],
                      ),
                    ],
                  );

                  state.addLessonToModule(
                    courseId: courseId,
                    moduleId: moduleId,
                    lesson: newLesson,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: Text(i18n.t('save_and_publish')),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, AppStateService state) {
    final jsonStr = state.exportActiveCurriculumJson();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('JSON Export'),
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

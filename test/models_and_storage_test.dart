import 'package:flutter_test/flutter_test.dart';
import 'package:codesphere/core/models/learning_models.dart';
import 'package:codesphere/core/security/content_sanitizer.dart';

void main() {
  group('OmniLearn Models & Schema Tests', () {
    test('QuizQuestion optionsList and whyWrong serialization', () {
      final q = QuizQuestion(
        id: 'test_q1',
        type: QuizType.singleChoice,
        prompt: 'ما هي عاصمة البرمجة؟',
        explanation: 'تفسير منطقي',
        optionsList: [
          const QuizOption(text: 'دارت', isCorrect: true),
          const QuizOption(text: 'بايثون', isCorrect: false, whyWrong: 'لغة عامة وليست عاصمة'),
        ],
      );

      final json = q.toJson();
      final revived = QuizQuestion.fromJson(json);

      expect(revived.id, 'test_q1');
      expect(revived.optionsList.length, 2);
      expect(revived.optionsList[0].isCorrect, true);
      expect(revived.optionsList[1].whyWrong, 'لغة عامة وليست عاصمة');
      expect(revived.correctIndices, [0]);
    });

    test('Attempt model toCsvRow generation', () {
      final attempt = Attempt(
        id: 'att_101',
        userId: 'student_99',
        questionId: 'q_swe_1',
        lessonId: 'lesson_scrum',
        sessionId: 'session_abc',
        chosen: [1],
        isCorrect: true,
        durationMs: 4500,
        phase: AttemptPhase.practice,
      );

      final csvLine = attempt.toCsvRow();
      expect(csvLine, contains('att_101,student_99,q_swe_1,lesson_scrum,session_abc,"1",true,4500,practice'));
    });

    test('CurriculumDomain schemaVersion validation', () {
      final domain = CurriculumDomain(
        id: 'test_domain',
        name: 'تجريبي',
        code: 'TEST',
        description: 'وصف',
        category: DomainCategory.computing,
        iconName: 'code',
      );

      final json = domain.toJson();
      expect(json['schemaVersion'], kCurrentSchemaVersion);

      final revived = CurriculumDomain.fromJson(json);
      expect(revived.name, 'تجريبي');
      expect(revived.schemaVersion, kCurrentSchemaVersion);
    });

    test('Lesson moderation and bilingual schema serialization', () {
      final lesson = Lesson(
        id: 'test_l1',
        moduleId: 'mod_web',
        title: 'أساسيات REST',
        titleEn: 'REST Fundamentals',
        summary: 'ملخص عربي',
        summaryEn: 'English summary',
        orderIndex: 1,
        authorId: 'contributor_42',
        authorName: 'أحمد المبرمج',
        adminComment: 'يرجى مراجعة المثال البرمجي',
        status: ContentStatus.needsRevision,
        submittedAt: DateTime(2026, 10, 30),
        reviewedAt: DateTime(2026, 10, 30, 2),
      );

      final json = lesson.toJson();
      expect(json['titleEn'], 'REST Fundamentals');
      expect(json['status'], 'needsRevision');
      expect(json['adminComment'], 'يرجى مراجعة المثال البرمجي');

      final revived = Lesson.fromJson(json);
      expect(revived.title, 'أساسيات REST');
      expect(revived.titleEn, 'REST Fundamentals');
      expect(revived.isNeedsRevision, isTrue);
      expect(revived.isApproved, isFalse);
      expect(revived.adminComment, 'يرجى مراجعة المثال البرمجي');
    });

    test('AppUser Level System dynamic calculation and progression', () {
      final user = AppUser(
        id: 'usr_lvl_1',
        name: 'سارة',
        email: 'sara@test.com',
        role: UserRole.student,
        xp: 250,
      );

      expect(user.level, 3); // (250 ~/ 100) + 1 = 3
      expect(user.xpInCurrentLevel, 50);
      expect(user.xpNeededForNextLevel, 50);
      expect(user.levelProgress, 0.5);
      expect(user.levelTitle, contains('مطور مبتدئ'));

      user.xp = 1200;
      expect(user.level, 13);
      expect(user.levelTitle, contains('Senior Developer'));
    });

    test('Lesson Node Type classification (Theory, Code Challenge, Milestone Quiz)', () {
      final theoryLesson = Lesson(
        id: 'l_theory',
        moduleId: 'm1',
        title: 'مقدمة نظرية',
        summary: 'شرح المفاهيم',
        orderIndex: 1,
        cards: [LessonCard(title: 'مفهوم', content: 'نص نظري بدون كود')],
      );
      expect(theoryLesson.isTheory, isTrue);
      expect(theoryLesson.isCodeChallenge, isFalse);
      expect(theoryLesson.isMilestoneQuiz, isFalse);

      final codeLesson = Lesson(
        id: 'l_code',
        moduleId: 'm1',
        title: 'تطبيق عملي',
        summary: 'تحدي كود',
        orderIndex: 2,
        cards: [LessonCard(title: 'تحدي', content: 'شرح', codeSnippet: 'void main() {}')],
      );
      expect(codeLesson.isCodeChallenge, isTrue);

      final quizLesson = Lesson(
        id: 'l_quiz',
        moduleId: 'm1',
        title: 'اختبار الوحدة',
        summary: 'تقييم شامل',
        orderIndex: 3,
        cards: [],
        quizzes: [
          QuizQuestion(id: 'q1', type: QuizType.singleChoice, prompt: 'س1', explanation: 'ج1'),
          QuizQuestion(id: 'q2', type: QuizType.singleChoice, prompt: 'س2', explanation: 'ج2'),
          QuizQuestion(id: 'q3', type: QuizType.singleChoice, prompt: 'س3', explanation: 'ج3'),
        ],
      );
      expect(quizLesson.isMilestoneQuiz, isTrue);
    });

    test('ContentSanitizer strips malicious script tags and keeps pure code intact', () {
      const malicious = '<script>alert("hack")</script>مرحبا بالبرمجة <img src="x" onerror="alert(1)">';
      final safe = ContentSanitizer.sanitizeText(malicious);
      expect(safe, isNot(contains('<script>')));
      expect(safe, isNot(contains('onerror=')));
      expect(safe, contains('مرحبا بالبرمجة'));
      expect(ContentSanitizer.isSafe(malicious), isFalse);

      const pureCode = 'void main() {\n  print("Hello CodeSphere");\n}';
      expect(ContentSanitizer.sanitizeCode(pureCode), pureCode);
      expect(ContentSanitizer.isSafe(pureCode), isTrue);
    });

    test('Harmash Article mode, Shadow Versioning, and ReviewMessage serialization', () {
      final lesson = Lesson(
        id: 'lesson_harmash_1',
        moduleId: 'mod_harmash',
        title: 'مدخل إلى لغة Dart',
        summary: 'مقال مرجعي شامل',
        orderIndex: 1,
        displayMode: LessonDisplayMode.harmashArticle,
        articleContent: '# أساسيات لغة Dart\nلغة كائنية حديثة مصممة من Google...',
        pendingUpdatePayload: {
          'title': 'مدخل متقدم للغة Dart',
          'articleContent': '# تحديث معمق لأساسيات Dart...',
        },
        reviewThread: [
          ReviewMessage(
            id: 'm1',
            senderId: 'admin_1',
            senderName: 'المدير',
            senderRole: UserRole.admin,
            message: 'يرجى تدعيم المقال بأمثلة للـ Async/Await',
          ),
        ],
      );

      expect(lesson.displayMode, LessonDisplayMode.harmashArticle);
      expect(lesson.hasShadowUpdate, isTrue);
      expect(lesson.reviewThread.length, 1);
      expect(lesson.reviewThread.first.senderRole, UserRole.admin);

      final json = lesson.toJson();
      final revived = Lesson.fromJson(json);

      expect(revived.displayMode, LessonDisplayMode.harmashArticle);
      expect(revived.articleContent, contains('أساسيات لغة Dart'));
      expect(revived.hasShadowUpdate, isTrue);
      expect(revived.pendingUpdatePayload?['title'], 'مدخل متقدم للغة Dart');
      expect(revived.reviewThread.length, 1);
      expect(revived.reviewThread.first.message, contains('Async/Await'));
    });
  });
}

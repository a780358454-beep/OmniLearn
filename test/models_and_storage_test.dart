import 'package:flutter_test/flutter_test.dart';
import 'package:codesphere/core/models/learning_models.dart';

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
  });
}

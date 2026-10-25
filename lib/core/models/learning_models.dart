import 'dart:convert';

/// إصدار هيكل البيانات لحماية الاستيراد والتحقق من التوافق
const int kCurrentSchemaVersion = 2;

/// أدوار المستخدمين في النظام
enum UserRole {
  admin,
  creator,
  student,
}

/// دورة حياة نشر المحتوى (Governance & Publishing Lifecycle)
enum ContentStatus {
  draft,       // مسودة
  inReview,    // قيد المراجعة
  published,   // منشور ومتاح للطلاب
  suspended,   // معلق بقرار إداري
  archived,    // مؤرشف
}

/// الأنواع السبعة للاختبارات التفاعلية
enum QuizType {
  singleChoice,   // اختيار من متعدد أحادي
  multipleChoice, // اختيار متعدد (Checkboxes)
  codeOrdering,   // ترتيب أسطر كود / خطوات
  fillInBlank,    // ملء الفراغات
  pairMatching,   // مطابقة المفاهيم والأزواج
  trueFalse,      // صح أو خطأ مع تعليل
  caseStudy,      // تحدي دراسة حالة وسيناريو تحليلي
}

/// تصنيفات المجالات والمناهج
enum DomainCategory {
  computing,
  medical,
  languages,
  engineering,
  general,
}

/// مراحل محاولات التعلم (مفيدة للدراسات البحثية والتقييم القبلي والبعدي)
enum AttemptPhase {
  pre,      // اختبار تشخيصي قبلي
  practice, // تدريب واختبار مرحلي
  post,     // اختبار بعدي لقياس الأثر
}

/// مستويات التعليل والشرح
enum ExplanationLevel {
  brief,    // سطر واحد سريع
  standard, // شرح قياسي
  deep,     // شرح معمق مع مراجع ومصادر
}

class ExplanationLevels {
  final String brief;
  final String standard;
  final String deep;

  const ExplanationLevels({
    required this.brief,
    required this.standard,
    required this.deep,
  });

  Map<String, dynamic> toJson() => {
    'brief': brief,
    'standard': standard,
    'deep': deep,
  };

  factory ExplanationLevels.fromJson(Map<String, dynamic> json) => ExplanationLevels(
    brief: json['brief'] ?? '',
    standard: json['standard'] ?? '',
    deep: json['deep'] ?? '',
  );
}

/// نموذج خيار السؤال المزود بتعليل الخطأ (whyWrong)
class QuizOption {
  final String text;
  final bool isCorrect;
  final String whyWrong;

  const QuizOption({
    required this.text,
    required this.isCorrect,
    this.whyWrong = '',
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isCorrect': isCorrect,
    'whyWrong': whyWrong,
  };

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
    text: json['text'] ?? '',
    isCorrect: json['isCorrect'] ?? false,
    whyWrong: json['whyWrong'] ?? '',
  );
}

/// نموذج المحاولة الفردية لحفظ سجل الطالب للورقة البحثية (Attempt Log)
class Attempt {
  final String id;
  final String userId;
  final String questionId;
  final String lessonId;
  final String sessionId;
  final List<int> chosen;
  final bool isCorrect;
  final int durationMs;
  final AttemptPhase phase;
  final DateTime createdAt;

  Attempt({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.lessonId,
    required this.sessionId,
    required this.chosen,
    required this.isCorrect,
    required this.durationMs,
    this.phase = AttemptPhase.practice,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'questionId': questionId,
    'lessonId': lessonId,
    'sessionId': sessionId,
    'chosen': chosen,
    'isCorrect': isCorrect,
    'durationMs': durationMs,
    'phase': phase.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Attempt.fromJson(Map<String, dynamic> json) => Attempt(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    questionId: json['questionId'] ?? '',
    lessonId: json['lessonId'] ?? '',
    sessionId: json['sessionId'] ?? '',
    chosen: List<int>.from(json['chosen'] ?? []),
    isCorrect: json['isCorrect'] ?? false,
    durationMs: json['durationMs'] ?? 0,
    phase: AttemptPhase.values.firstWhere(
      (e) => e.name == json['phase'],
      orElse: () => AttemptPhase.practice,
    ),
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );

  /// تصدير المحاولة لسطر CSV
  String toCsvRow() {
    return '$id,$userId,$questionId,$lessonId,$sessionId,"${chosen.join(';')}",$isCorrect,$durationMs,${phase.name},${createdAt.toIso8601String()}';
  }
}

/// إعدادات وهوية التطبيق
class AppBrandingConfig {
  String appName;
  String appTagline;
  String logoIcon;
  int primaryColorValue;
  int accentColorValue;
  String activeCurriculumId;
  bool isDarkMode;
  DateTime lastActiveDate;

  AppBrandingConfig({
    required this.appName,
    required this.appTagline,
    this.logoIcon = "terminal",
    this.primaryColorValue = 0xFF4F46E5, // Indigo compliant
    this.accentColorValue = 0xFF047857,  // Darker emerald compliant
    this.activeCurriculumId = "curriculum_software_dev",
    this.isDarkMode = true,
    DateTime? lastActiveDate,
  }) : lastActiveDate = lastActiveDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'appTagline': appTagline,
    'logoIcon': logoIcon,
    'primaryColorValue': primaryColorValue,
    'accentColorValue': accentColorValue,
    'activeCurriculumId': activeCurriculumId,
    'isDarkMode': isDarkMode,
    'lastActiveDate': lastActiveDate.toIso8601String(),
  };

  factory AppBrandingConfig.fromJson(Map<String, dynamic> json) => AppBrandingConfig(
    appName: json['appName'] ?? 'OmniLearn',
    appTagline: json['appTagline'] ?? 'Universal Learning Engine',
    logoIcon: json['logoIcon'] ?? 'terminal',
    primaryColorValue: json['primaryColorValue'] ?? 0xFF4F46E5,
    accentColorValue: json['accentColorValue'] ?? 0xFF047857,
    activeCurriculumId: json['activeCurriculumId'] ?? 'curriculum_software_dev',
    isDarkMode: json['isDarkMode'] ?? true,
    lastActiveDate: DateTime.tryParse(json['lastActiveDate'] ?? '') ?? DateTime.now(),
  );
}

/// نموذج المستخدم والحسابات
class AppUser {
  final String id;
  String name;
  String email;
  String username;
  String salt;
  String passwordHash;
  UserRole role;
  bool isActive;
  bool isApproved;
  bool isPremium;
  bool mustChangePassword;
  int xp;
  int streakDays;
  DateTime createdAt;
  DateTime lastActiveDate;
  DateTime? lastLoginAt;
  List<String> completedLessonIds;
  List<String> assignedCourseIds;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.username = '',
    this.salt = '',
    this.passwordHash = '',
    required this.role,
    this.isActive = true,
    this.isApproved = true,
    this.isPremium = false,
    this.mustChangePassword = false,
    this.xp = 0,
    this.streakDays = 1,
    DateTime? createdAt,
    DateTime? lastActiveDate,
    this.lastLoginAt,
    List<String>? completedLessonIds,
    List<String>? assignedCourseIds,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastActiveDate = lastActiveDate ?? DateTime.now(),
        completedLessonIds = completedLessonIds ?? [],
        assignedCourseIds = assignedCourseIds ?? [];

  bool get isAdmin => role == UserRole.admin;
  bool get isCreator => role == UserRole.creator;
  bool get canAuthor => role == UserRole.admin || role == UserRole.creator;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'username': username,
    'salt': salt,
    'passwordHash': passwordHash,
    'role': role.name,
    'isActive': isActive,
    'isApproved': isApproved,
    'isPremium': isPremium,
    'mustChangePassword': mustChangePassword,
    'xp': xp,
    'streakDays': streakDays,
    'createdAt': createdAt.toIso8601String(),
    'lastActiveDate': lastActiveDate.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
    'completedLessonIds': completedLessonIds,
    'assignedCourseIds': assignedCourseIds,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    username: json['username'] ?? '',
    salt: json['salt'] ?? '',
    passwordHash: json['passwordHash'] ?? '',
    role: UserRole.values.firstWhere(
      (e) => e.name == json['role'],
      orElse: () => UserRole.student,
    ),
    isActive: json['isActive'] ?? true,
    isApproved: json['isApproved'] ?? true,
    isPremium: json['isPremium'] ?? false,
    mustChangePassword: json['mustChangePassword'] ?? false,
    xp: json['xp'] ?? 0,
    streakDays: json['streakDays'] ?? 1,
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    lastActiveDate: DateTime.tryParse(json['lastActiveDate'] ?? '') ?? DateTime.now(),
    lastLoginAt: json['lastLoginAt'] == null ? null : DateTime.tryParse(json['lastLoginAt']),
    completedLessonIds: List<String>.from(json['completedLessonIds'] ?? []),
    assignedCourseIds: List<String>.from(json['assignedCourseIds'] ?? []),
  );
}

/// بطاقة تعليمية داخل الدرس (Micro-Learning Card)
class LessonCard {
  final String title;
  final String content;
  final String? codeSnippet;
  final String? visualHint;
  final String? calloutType;

  LessonCard({
    required this.title,
    required this.content,
    this.codeSnippet,
    this.visualHint,
    this.calloutType,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'codeSnippet': codeSnippet,
    'visualHint': visualHint,
    'calloutType': calloutType,
  };

  factory LessonCard.fromJson(Map<String, dynamic> json) => LessonCard(
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    codeSnippet: json['codeSnippet'],
    visualHint: json['visualHint'],
    calloutType: json['calloutType'],
  );
}

/// نموذج السؤال التفاعلي بالأنواع السبعة
class QuizQuestion {
  final String id;
  final QuizType type;
  final String prompt;
  final String explanation;
  final ExplanationLevels? explanationLevels;
  final List<QuizOption> optionsList;

  // لأسئلة ترتيب الأسطر / الخطوات (بدون ترقيم مسرّب)
  final List<String> orderItems;

  // لأسئلة ملء الفراغات
  final String fillSentence;
  final List<String> fillAcceptedAnswers;

  // لأسئلة مطابقة الأزواج
  final Map<String, String> pairs;

  // لأسئلة صح / خطأ
  final bool isTrue;

  // لأسئلة دراسة الحالة
  final String? caseScenario;

  // توثيق المصدر للأخلاقيات والمصادر الطبية
  final String? source;
  final String? reviewedBy;

  QuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.explanation,
    this.explanationLevels,
    List<QuizOption>? optionsList,
    List<String>? options,
    List<int>? correctIndices,
    List<String>? orderItems,
    this.fillSentence = '',
    List<String>? fillAcceptedAnswers,
    Map<String, String>? pairs,
    this.isTrue = true,
    this.caseScenario,
    this.source,
    this.reviewedBy,
  }) : optionsList = optionsList ?? _buildOptions(options, correctIndices),
       orderItems = orderItems ?? [],
       fillAcceptedAnswers = fillAcceptedAnswers ?? [],
       pairs = pairs ?? {};

  static List<QuizOption> _buildOptions(List<String>? options, List<int>? correctIndices) {
    if (options == null) return [];
    final correctSet = (correctIndices ?? []).toSet();
    return List.generate(options.length, (idx) {
      final isCorr = correctSet.contains(idx);
      return QuizOption(
        text: options[idx],
        isCorrect: isCorr,
        whyWrong: isCorr ? '' : 'هذا الخيار غير صحيح وفق السياق الهندسي/العلمي.',
      );
    });
  }

  // التوافق العكسي
  List<String> get options => optionsList.map((o) => o.text).toList();
  List<int> get correctIndices {
    final list = <int>[];
    for (int i = 0; i < optionsList.length; i++) {
      if (optionsList[i].isCorrect) list.add(i);
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'prompt': prompt,
    'explanation': explanation,
    'explanationLevels': explanationLevels?.toJson(),
    'optionsList': optionsList.map((o) => o.toJson()).toList(),
    'orderItems': orderItems,
    'fillSentence': fillSentence,
    'fillAcceptedAnswers': fillAcceptedAnswers,
    'pairs': pairs,
    'isTrue': isTrue,
    'caseScenario': caseScenario,
    'source': source,
    'reviewedBy': reviewedBy,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] ?? '',
    type: QuizType.values.firstWhere(
      (e) => e.name == json['type'], 
      orElse: () => QuizType.singleChoice
    ),
    prompt: json['prompt'] ?? '',
    explanation: json['explanation'] ?? '',
    explanationLevels: json['explanationLevels'] != null 
        ? ExplanationLevels.fromJson(json['explanationLevels']) 
        : null,
    optionsList: (json['optionsList'] as List? ?? [])
        .map((o) => QuizOption.fromJson(o))
        .toList(),
    orderItems: List<String>.from(json['orderItems'] ?? []),
    fillSentence: json['fillSentence'] ?? '',
    fillAcceptedAnswers: List<String>.from(json['fillAcceptedAnswers'] ?? []),
    pairs: Map<String, String>.from(json['pairs'] ?? {}),
    isTrue: json['isTrue'] ?? true,
    caseScenario: json['caseScenario'],
    source: json['source'],
    reviewedBy: json['reviewedBy'],
  );
}

/// نموذج الدرس التفاعلي
class Lesson {
  final String id;
  final String moduleId;
  String title;
  String summary;
  int orderIndex;
  int xpReward;
  ContentStatus status;
  String creatorId;
  List<LessonCard> cards;
  List<QuizQuestion> quizzes;

  Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.orderIndex,
    this.xpReward = 50,
    this.status = ContentStatus.published,
    this.creatorId = 'admin',
    List<LessonCard>? cards,
    List<QuizQuestion>? quizzes,
  }) : cards = cards ?? [],
       quizzes = quizzes ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'moduleId': moduleId,
    'title': title,
    'summary': summary,
    'orderIndex': orderIndex,
    'xpReward': xpReward,
    'status': status.name,
    'creatorId': creatorId,
    'cards': cards.map((c) => c.toJson()).toList(),
    'quizzes': quizzes.map((q) => q.toJson()).toList(),
  };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] ?? '',
    moduleId: json['moduleId'] ?? '',
    title: json['title'] ?? '',
    summary: json['summary'] ?? '',
    orderIndex: json['orderIndex'] ?? 0,
    xpReward: json['xpReward'] ?? 50,
    status: ContentStatus.values.firstWhere(
      (e) => e.name == json['status'], 
      orElse: () => ContentStatus.published
    ),
    creatorId: json['creatorId'] ?? 'admin',
    cards: (json['cards'] as List? ?? []).map((c) => LessonCard.fromJson(c)).toList(),
    quizzes: (json['quizzes'] as List? ?? []).map((q) => QuizQuestion.fromJson(q)).toList(),
  );
}

/// وحدة تعليمية (Module)
class CourseModule {
  final String id;
  final String courseId;
  String title;
  String description;
  int orderIndex;
  ContentStatus status;
  List<Lesson> lessons;

  CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.orderIndex,
    this.status = ContentStatus.published,
    List<Lesson>? lessons,
  }) : lessons = lessons ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'title': title,
    'description': description,
    'orderIndex': orderIndex,
    'status': status.name,
    'lessons': lessons.map((l) => l.toJson()).toList(),
  };

  factory CourseModule.fromJson(Map<String, dynamic> json) => CourseModule(
    id: json['id'] ?? '',
    courseId: json['courseId'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    orderIndex: json['orderIndex'] ?? 0,
    status: ContentStatus.values.firstWhere(
      (e) => e.name == json['status'], 
      orElse: () => ContentStatus.published
    ),
    lessons: (json['lessons'] as List? ?? []).map((l) => Lesson.fromJson(l)).toList(),
  );
}

/// مقرر دراسي (Course)
class Course {
  final String id;
  final String curriculumId;
  String title;
  String code;
  String description;
  String iconName;
  ContentStatus status;
  List<CourseModule> modules;

  Course({
    required this.id,
    required this.curriculumId,
    required this.title,
    required this.code,
    required this.description,
    required this.iconName,
    this.status = ContentStatus.published,
    List<CourseModule>? modules,
  }) : modules = modules ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'curriculumId': curriculumId,
    'title': title,
    'code': code,
    'description': description,
    'iconName': iconName,
    'status': status.name,
    'modules': modules.map((m) => m.toJson()).toList(),
  };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] ?? '',
    curriculumId: json['curriculumId'] ?? '',
    title: json['title'] ?? '',
    code: json['code'] ?? '',
    description: json['description'] ?? '',
    iconName: json['iconName'] ?? 'code',
    status: ContentStatus.values.firstWhere(
      (e) => e.name == json['status'], 
      orElse: () => ContentStatus.published
    ),
    modules: (json['modules'] as List? ?? []).map((m) => CourseModule.fromJson(m)).toList(),
  );
}

/// منهج / مسار كامل (Curriculum Domain)
class CurriculumDomain {
  final String id;
  String name;
  String code;
  String description;
  DomainCategory category;
  String iconName;
  int schemaVersion;
  List<Course> courses;

  CurriculumDomain({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.category,
    required this.iconName,
    this.schemaVersion = kCurrentSchemaVersion,
    List<Course>? courses,
  }) : courses = courses ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'description': description,
    'category': category.name,
    'iconName': iconName,
    'schemaVersion': schemaVersion,
    'courses': courses.map((c) => c.toJson()).toList(),
  };

  factory CurriculumDomain.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'] ?? 1;
    if (version > kCurrentSchemaVersion) {
      throw FormatException('إصدار المنهج ($version) أحدث من دعم النظام ($kCurrentSchemaVersion). يرجى تحديث التطبيق.');
    }

    return CurriculumDomain(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      category: DomainCategory.values.firstWhere(
        (e) => e.name == json['category'], 
        orElse: () => DomainCategory.general
      ),
      iconName: json['iconName'] ?? 'domain',
      schemaVersion: version,
      courses: (json['courses'] as List? ?? []).map((c) => Course.fromJson(c)).toList(),
    );
  }
}

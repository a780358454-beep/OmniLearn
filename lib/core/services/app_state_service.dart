import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/learning_models.dart';
import '../repositories/storage_repository.dart';
import '../../data/initial_curricula.dart';

class AppStateService extends ChangeNotifier {
  static final AppStateService instance = AppStateService._();
  AppStateService._() {
    _initialize();
  }

  late AppBrandingConfig _branding;
  late List<CurriculumDomain> _curricula;
  late List<AppUser> _users;
  late AppUser _currentUser;
  late String _activeCurriculumId;
  String _activeSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';

  AppBrandingConfig get branding => _branding;
  List<CurriculumDomain> get curricula => _curricula;
  List<AppUser> get users => _users;
  AppUser get currentUser => _currentUser;
  String get activeCurriculumId => _activeCurriculumId;
  String get activeSessionId => _activeSessionId;
  bool get isDarkMode => _branding.isDarkMode;

  CurriculumDomain get activeCurriculum {
    return _curricula.firstWhere(
      (c) => c.id == _activeCurriculumId,
      orElse: () => _curricula.isNotEmpty 
          ? _curricula.first 
          : CurriculumDomain(
              id: 'empty',
              name: 'مسار فارغ',
              code: 'EMPTY',
              description: '',
              category: DomainCategory.general,
              iconName: 'folder',
            ),
    );
  }

  Future<void> _initialize() async {
    // 1. الإعدادات الافتراضية
    _branding = AppBrandingConfig(
      appName: 'OmniLearn',
      appTagline: 'Universal Learning & Assessment Engine',
      logoIcon: 'terminal',
      primaryColorValue: 0xFF4F46E5, // Indigo compliant
      accentColorValue: 0xFF047857,  // Darker emerald compliant
      activeCurriculumId: 'curriculum_software_dev',
      isDarkMode: true,
    );

    _curricula = InitialCurriculaData.getCurricula();
    _activeCurriculumId = _branding.activeCurriculumId;

    _users = [
      AppUser(
        id: 'admin_root',
        name: 'مدير المنصة (Admin)',
        email: 'admin@omnilearn.org',
        role: UserRole.admin,
        xp: 1500,
        streakDays: 12,
      ),
      AppUser(
        id: 'creator_1',
        name: 'م. أحمد (مؤلف مناهج الحاسوب)',
        email: 'ahmed@omnilearn.org',
        role: UserRole.creator,
        xp: 600,
        streakDays: 6,
        assignedCourseIds: ['course_se', 'course_sad'],
      ),
      AppUser(
        id: 'student_1',
        name: 'سامي (طالب ومبرمج متدرب)',
        email: 'sami@learner.com',
        role: UserRole.student,
        xp: 150,
        streakDays: 3,
        completedLessonIds: [],
      ),
    ];

    _currentUser = _users.first;

    // 2. محاولة استرجاع البيانات المحفوظة من SharedPreferences
    final loadedBranding = await StorageRepository.loadBranding();
    if (loadedBranding != null) {
      _branding = loadedBranding;
      _activeCurriculumId = _branding.activeCurriculumId;
    }

    final loadedCurricula = await StorageRepository.loadCurricula();
    if (loadedCurricula != null && loadedCurricula.isNotEmpty) {
      _curricula = loadedCurricula;
    }

    final loadedProgress = await StorageRepository.loadUserProgress(_currentUser.id);
    if (loadedProgress != null) {
      _currentUser.xp = loadedProgress['xp'] ?? _currentUser.xp;
      _currentUser.streakDays = loadedProgress['streakDays'] ?? _currentUser.streakDays;
      _currentUser.completedLessonIds = List<String>.from(loadedProgress['completedLessonIds'] ?? []);
      if (loadedProgress['lastActiveDate'] != null) {
        _currentUser.lastActiveDate = DateTime.tryParse(loadedProgress['lastActiveDate']) ?? DateTime.now();
      }
    }

    _touchStreak();
    notifyListeners();
  }

  // --- محرك تتابع الأيام الحقيقي (Streak Engine) ---
  void _touchStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      _currentUser.lastActiveDate.year,
      _currentUser.lastActiveDate.month,
      _currentUser.lastActiveDate.day,
    );

    final diff = today.difference(last).inDays;
    if (diff == 1) {
      _currentUser.streakDays += 1;
    } else if (diff > 1) {
      _currentUser.streakDays = 1;
    }
    _currentUser.lastActiveDate = now;
    _persistUserProgress();
  }

  // --- تبديل الوضع الليلي / الفاتح ---
  void toggleThemeMode() {
    _branding.isDarkMode = !_branding.isDarkMode;
    StorageRepository.saveBranding(_branding);
    notifyListeners();
  }

  // --- تبديل الحساب والدور (معاينة تجريبية Demo) ---
  void switchCurrentUser(AppUser user) {
    _currentUser = user;
    _touchStreak();
    notifyListeners();
  }

  void switchRole(UserRole role) {
    final found = _users.firstWhere(
      (u) => u.role == role,
      orElse: () => _users.isNotEmpty ? _users.first : AppUser(
        id: 'usr_temp',
        name: 'Guest User',
        email: 'guest@omnilearn.org',
        role: role,
      ),
    );
    _currentUser = found;
    _touchStreak();
    notifyListeners();
  }

  // --- ميزات الأدمن: هوية التطبيق وتخصيص الأيقونة والألوان والسياسات ---
  void updateBranding({
    required String appName,
    required String appTagline,
    required String logoIcon,
    required int primaryColorValue,
    required int accentColorValue,
  }) {
    _branding.appName = appName;
    _branding.appTagline = appTagline;
    _branding.logoIcon = logoIcon;
    _branding.primaryColorValue = primaryColorValue;
    _branding.accentColorValue = accentColorValue;
    StorageRepository.saveBranding(_branding);
    notifyListeners();
  }

  // --- ميزات الأدمن: إدارة الحسابات مع حماية آخر مدير من الحذف ---
  void createUser({
    required String name,
    required String email,
    required UserRole role,
  }) {
    final newUser = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
    );
    _users.add(newUser);
    notifyListeners();
  }

  void toggleUserStatus(String userId) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx].isActive = !_users[idx].isActive;
      notifyListeners();
    }
  }

  bool deleteUser(String userId) {
    final target = _users.firstWhere((u) => u.id == userId, orElse: () => _users.first);
    // حماية: منع حذف آخر مدير للنظام منعاً لانهيار الصلاحيات
    if (target.role == UserRole.admin) {
      final adminCount = _users.where((u) => u.role == UserRole.admin).length;
      if (adminCount <= 1) {
        return false; // لا يمكن حذف المدير الوحيد
      }
    }

    _users.removeWhere((u) => u.id == userId);
    if (_currentUser.id == userId && _users.isNotEmpty) {
      _currentUser = _users.first;
    }
    notifyListeners();
    return true;
  }

  // --- ميزات الأدمن: حوكمة ونشر المحتوى ---
  void setContentPublishStatus({
    required String lessonId,
    required ContentStatus status,
  }) {
    for (var curriculum in _curricula) {
      for (var course in curriculum.courses) {
        for (var module in course.modules) {
          final lIndex = module.lessons.indexWhere((l) => l.id == lessonId);
          if (lIndex != -1) {
            module.lessons[lIndex].status = status;
            StorageRepository.saveCurricula(_curricula);
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  // --- إدارة المسارات المنفصلة ---
  void createNewCurriculum({
    required String name,
    required String code,
    required String description,
    required DomainCategory category,
    required String iconName,
  }) {
    final newCurriculum = CurriculumDomain(
      id: 'curriculum_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      code: code,
      description: description,
      category: category,
      iconName: iconName,
      courses: [],
    );
    _curricula.add(newCurriculum);
    _activeCurriculumId = newCurriculum.id;
    StorageRepository.saveCurricula(_curricula);
    notifyListeners();
  }

  void setActiveCurriculum(String curriculumId) {
    _activeCurriculumId = curriculumId;
    _branding.activeCurriculumId = curriculumId;
    StorageRepository.saveBranding(_branding);
    notifyListeners();
  }

  // --- استوديو المؤلف (Creator Studio) ---
  void addCourseToActiveCurriculum({
    required String title,
    required String code,
    required String description,
    required String iconName,
  }) {
    final newCourse = Course(
      id: 'course_${DateTime.now().millisecondsSinceEpoch}',
      curriculumId: _activeCurriculumId,
      title: title,
      code: code,
      description: description,
      iconName: iconName,
      status: ContentStatus.published,
    );
    activeCurriculum.courses.add(newCourse);
    StorageRepository.saveCurricula(_curricula);
    notifyListeners();
  }

  void addModuleToCourse({
    required String courseId,
    required String title,
    required String description,
  }) {
    final course = activeCurriculum.courses.firstWhere((c) => c.id == courseId);
    final newModule = CourseModule(
      id: 'mod_${DateTime.now().millisecondsSinceEpoch}',
      courseId: courseId,
      title: title,
      description: description,
      orderIndex: course.modules.length + 1,
      status: ContentStatus.published,
    );
    course.modules.add(newModule);
    StorageRepository.saveCurricula(_curricula);
    notifyListeners();
  }

  void addLessonToModule({
    required String courseId,
    required String moduleId,
    required Lesson lesson,
  }) {
    final course = activeCurriculum.courses.firstWhere((c) => c.id == courseId);
    final module = course.modules.firstWhere((m) => m.id == moduleId);
    module.lessons.add(lesson);
    StorageRepository.saveCurricula(_curricula);
    notifyListeners();
  }

  // --- تصدير واستيراد المناهج ---
  String exportActiveCurriculumJson() {
    return const JsonEncoder.withIndent('  ').convert(activeCurriculum.toJson());
  }

  bool importCurriculumFromJson(String jsonContent) {
    try {
      final decoded = json.decode(jsonContent) as Map<String, dynamic>;
      final domain = CurriculumDomain.fromJson(decoded);
      _curricula.removeWhere((c) => c.id == domain.id);
      _curricula.add(domain);
      _activeCurriculumId = domain.id;
      StorageRepository.saveCurricula(_curricula);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Import error: $e");
      return false;
    }
  }

  // --- تسجيل المحاولات للورقة البحثية (Research Attempt Logger) ---
  void logAttempt({
    required String questionId,
    required String lessonId,
    required List<int> chosen,
    required bool isCorrect,
    required int durationMs,
    AttemptPhase phase = AttemptPhase.practice,
  }) {
    final attempt = Attempt(
      id: 'att_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.id,
      questionId: questionId,
      lessonId: lessonId,
      sessionId: _activeSessionId,
      chosen: chosen,
      isCorrect: isCorrect,
      durationMs: durationMs,
      phase: phase,
    );
    StorageRepository.recordAttempt(attempt);
  }

  Future<String> exportResearchCsv() async {
    return await StorageRepository.exportAttemptsCsv();
  }

  // --- تتبع إنجاز الطالب والـ XP ---
  bool isLessonCompleted(String lessonId) {
    return _currentUser.completedLessonIds.contains(lessonId);
  }

  void completeLesson(String lessonId, int earnedXp) {
    if (!_currentUser.completedLessonIds.contains(lessonId)) {
      _currentUser.completedLessonIds.add(lessonId);
      _currentUser.xp += earnedXp;
      _touchStreak();
      _persistUserProgress();
      notifyListeners();
    }
  }

  void _persistUserProgress() {
    StorageRepository.saveUserProgress(
      userId: _currentUser.id,
      xp: _currentUser.xp,
      streakDays: _currentUser.streakDays,
      lastActiveDate: _currentUser.lastActiveDate,
      completedLessonIds: _currentUser.completedLessonIds,
    );
  }

  int get completedLessonsCount => _currentUser.completedLessonIds.length;
}

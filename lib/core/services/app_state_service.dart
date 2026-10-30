import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/learning_models.dart';
import '../repositories/storage_repository.dart';
import '../security/password_hasher.dart';
import 'cloud_sync_service.dart';
import '../../data/initial_curricula.dart';

/// نتيجة أي عملية مصادقة — رسالة واضحة بدل استثناء.
class AuthResult {
  final bool success;
  final String? message;

  const AuthResult.ok()
      : success = true,
        message = null;

  const AuthResult.fail(this.message) : success = false;

  bool get ok => success;
}

class AppStateService extends ChangeNotifier {
  static final AppStateService instance = AppStateService._();

  AppStateService._();

  Future<void>? _initFuture;

  String? _startupError;
  String? get startupError => _startupError;

  /// بيانات آخر حساب أنشأه المدير — تُعرض مرة واحدة للتسليم.
  String? lastCreatedUsername;
  String? lastCreatedPassword;

  /// تهيئة صريحة تُنتظر من main() قبل أول إطار.
  Future<void> ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  late AppBrandingConfig _branding;
  late List<CurriculumDomain> _curricula;
  late List<AppUser> _users;
  late AppUser _currentUser;
  late String _activeCurriculumId;

  bool _isReady = false;
  bool _isAuthenticated = false;
  String _activeSessionId =
      'session_${DateTime.now().millisecondsSinceEpoch}';

  bool get isReady => _isReady;
  bool get isAuthenticated => _isAuthenticated;
  AppBrandingConfig get branding => _branding;
  List<CurriculumDomain> get curricula => _curricula;
  List<AppUser> get users => _users;
  AppUser get currentUser => _currentUser;
  String get activeCurriculumId => _activeCurriculumId;
  String get activeSessionId => _activeSessionId;
  bool get isDarkMode => _branding.isDarkMode;
  bool get isAdmin => _currentUser.isAdmin;
  bool get canAuthor => _currentUser.canAuthor;

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
              category: DomainCategory.computing,
              iconName: 'folder',
            ),
    );
  }

  AppUser _guest() =>
      AppUser(id: 'guest', name: '', email: '', role: UserRole.student);

  // --- الإقلاع ---
  Future<void> _initialize() async {
    // قيم افتراضية أولاً حتى لا يبقى أي حقل غير مهيأ عند الخطأ
    _users = <AppUser>[];
    _currentUser = _guest();
    _curricula = <CurriculumDomain>[];
    _activeCurriculumId = 'curriculum_software_dev';

    try {
      _branding = AppBrandingConfig(
      appName: 'OmniLearn',
      appTagline: 'محرك التعلم الشامل — أي مجال، أي درس',
      logoIcon: 'terminal',
      primaryColorValue: 0xFF4F46E5,
      accentColorValue: 0xFF047857,
      activeCurriculumId: 'curriculum_software_dev',
      isDarkMode: true,
    );

    _curricula = InitialCurriculaData.getCurricula();
    _activeCurriculumId = _branding.activeCurriculumId;
    _currentUser = _guest();

    final loadedUsers = await StorageRepository.loadUsers();
    if (loadedUsers != null && loadedUsers.isNotEmpty) {
      _users = loadedUsers;
    } else {
      _users = [_buildSeedAdmin()];
      await StorageRepository.saveUsers(_users);
    }

    final loadedBranding = await StorageRepository.loadBranding();
    if (loadedBranding != null) {
      _branding = loadedBranding;
      _activeCurriculumId = loadedBranding.activeCurriculumId;
    }

    final loadedCurricula = await StorageRepository.loadCurricula();
    if (loadedCurricula != null && loadedCurricula.isNotEmpty) {
      _curricula = loadedCurricula;
    }

    final sessionId = await StorageRepository.loadSessionUserId();
    if (sessionId != null) {
      for (final u in _users) {
        if (u.id == sessionId && u.isActive) {
          _currentUser = u;
          _isAuthenticated = true;
          await _loadProgressFor(u);
          break;
        }
      }
    }

    if (_isAuthenticated) {
      _touchStreak();
    }

    // تهيئة خدمة المزامنة السحابية ومحاولة مزامنة الخلفية
    try {
      await CloudSyncService.instance.ensureInitialized();
      unawaited(_triggerBackgroundSync());
    } catch (_) {}

    } catch (e) {
      debugPrint('Init error: $e');
      _startupError = e.toString();
      // ضمان وجود حساب مدير حتى لو فشل التخزين
      if (_users.isEmpty) {
        try {
          _users = [_buildSeedAdmin()];
        } catch (_) {
          _users = <AppUser>[];
        }
      }
      if (_curricula.isEmpty) {
        try {
          _curricula = InitialCurriculaData.getCurricula();
        } catch (_) {
          _curricula = <CurriculumDomain>[];
        }
      }
      _currentUser = _guest();
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  /// حساب المدير الأول — كلمة السر الافتراضية: 1234
  AppUser _buildSeedAdmin() {
    final salt = PasswordHasher.generateSalt();
    return AppUser(
      id: 'admin_root',
      name: 'عبودي',
      email: 'abodi@omnilearn.app',
      username: 'abodi',
      salt: salt,
      passwordHash: PasswordHasher.hash('1234', salt),
      role: UserRole.admin,
      mustChangePassword: true,
    );
  }

  // --- المصادقة ---
  Future<AuthResult> login(String username, String password) async {
    final key = username.trim().toLowerCase();
    if (key.isEmpty || password.isEmpty) {
      return const AuthResult.fail('أدخل اسم المستخدم وكلمة السر');
    }

    AppUser? found;
    for (final u in _users) {
      if (u.username.toLowerCase() == key || u.email.toLowerCase() == key) {
        found = u;
        break;
      }
    }

    if (found == null) {
      return const AuthResult.fail('لا يوجد حساب بهذا المعرّف');
    }
    if (!found.isActive) {
      return const AuthResult.fail('هذا الحساب معطّل — راجع المدير');
    }
    if (!PasswordHasher.verify(password, found.salt, found.passwordHash)) {
      return const AuthResult.fail('كلمة السر غير صحيحة');
    }

    await _startSession(found);
    return const AuthResult.ok();
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanUser = username.trim().toLowerCase();

    if (cleanName.length < 2) {
      return const AuthResult.fail('الاسم قصير جدًا');
    }
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(cleanEmail)) {
      return const AuthResult.fail('البريد الإلكتروني غير صالح');
    }
    if (cleanUser.length < 3) {
      return const AuthResult.fail('اسم المستخدم ٣ أحرف على الأقل');
    }
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(cleanUser)) {
      return const AuthResult.fail(
        'اسم المستخدم: حروف إنجليزية وأرقام و _ فقط',
      );
    }
    if (password.length < 6) {
      return const AuthResult.fail('كلمة السر ٦ أحرف على الأقل');
    }
    const weakPasswords = ['1234', '12345', '123456', 'password', 'qwerty'];
    if (weakPasswords.contains(password.toLowerCase())) {
      return const AuthResult.fail('كلمة السر ضعيفة جدًا — اختر كلمة أقوى');
    }
    if (_users.any((u) => u.username.toLowerCase() == cleanUser)) {
      return const AuthResult.fail('اسم المستخدم مستخدم بالفعل');
    }
    if (_users.any((u) => u.email.toLowerCase() == cleanEmail)) {
      return const AuthResult.fail('البريد الإلكتروني مسجّل بالفعل');
    }
    // منع التقاطع: بريد مستخدم = اسم دخول لمستخدم آخر، والعكس
    if (_users.any((u) => u.email.toLowerCase() == cleanUser) ||
        _users.any((u) => u.username.toLowerCase() == cleanEmail)) {
      return const AuthResult.fail('هذا المعرّف مستخدم للدخول بطريقة أخرى');
    }

    final salt = PasswordHasher.generateSalt();
    final user = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      email: cleanEmail,
      username: cleanUser,
      salt: salt,
      passwordHash: PasswordHasher.hash(password, salt),
      role: UserRole.student,
    );

    _users.add(user);
    await StorageRepository.saveUsers(_users);
    await _startSession(user);
    return const AuthResult.ok();
  }

  Future<void> _startSession(AppUser user) async {
    _currentUser = user;
    _isAuthenticated = true;
    user.lastLoginAt = DateTime.now();
    _activeSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    await _loadProgressFor(user);
    await StorageRepository.saveUsers(_users);
    await StorageRepository.saveSessionUserId(user.id);
    _touchStreak();
    notifyListeners();
  }

  Future<void> logout() async {
    await _persistUserProgress();
    await StorageRepository.clearSession();
    _currentUser = _guest();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<AuthResult> changeOwnPassword(
    String oldPassword,
    String newPassword,
  ) async {
    if (!_isAuthenticated) {
      return const AuthResult.fail('يجب تسجيل الدخول أولاً');
    }
    if (!PasswordHasher.verify(
      oldPassword,
      _currentUser.salt,
      _currentUser.passwordHash,
    )) {
      return const AuthResult.fail('كلمة السر الحالية غير صحيحة');
    }
    if (newPassword.length < 4) {
      return const AuthResult.fail('كلمة السر الجديدة ٤ أحرف على الأقل');
    }
    if (newPassword == oldPassword) {
      return const AuthResult.fail('اختر كلمة سر مختلفة عن الحالية');
    }

    final salt = PasswordHasher.generateSalt();
    _currentUser.salt = salt;
    _currentUser.passwordHash = PasswordHasher.hash(newPassword, salt);
    _currentUser.mustChangePassword = false;
    await StorageRepository.saveUsers(_users);
    notifyListeners();
    return const AuthResult.ok();
  }

  Future<AuthResult> resetUserPassword(
    String userId,
    String newPassword,
  ) async {
    if (!isAdmin) {
      return const AuthResult.fail('غير مصرّح');
    }
    if (newPassword.length < 4) {
      return const AuthResult.fail('كلمة السر ٤ أحرف على الأقل');
    }
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx == -1) {
      return const AuthResult.fail('المستخدم غير موجود');
    }
    final salt = PasswordHasher.generateSalt();
    _users[idx].salt = salt;
    _users[idx].passwordHash = PasswordHasher.hash(newPassword, salt);
    _users[idx].mustChangePassword = true;
    await StorageRepository.saveUsers(_users);
    notifyListeners();
    return const AuthResult.ok();
  }

  // --- إدارة الحسابات (المدير فقط) ---
  AuthResult createUser({
    required String name,
    required String email,
    required UserRole role,
    String? username,
    String? password,
  }) {
    if (!isAdmin) {
      return const AuthResult.fail('غير مصرّح');
    }

    final cleanEmail = email.trim().toLowerCase();
    var cleanUser = (username ?? cleanEmail.split('@').first)
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    if (cleanUser.isEmpty) cleanUser = 'user';

    var candidate = cleanUser;
    var i = 1;
    while (_users.any((u) => u.username.toLowerCase() == candidate)) {
      candidate = '$cleanUser$i';
      i++;
    }

    if (_users.any((u) => u.email.toLowerCase() == cleanEmail)) {
      return const AuthResult.fail('البريد الإلكتروني مسجّل بالفعل');
    }

    final plain = (password == null || password.isEmpty) ? '1234' : password;
    lastCreatedUsername = candidate;
    lastCreatedPassword = plain;
    final salt = PasswordHasher.generateSalt();

    _users.add(
      AppUser(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        email: cleanEmail,
        username: candidate,
        salt: salt,
        passwordHash: PasswordHasher.hash(plain, salt),
        role: role,
        mustChangePassword: true,
      ),
    );
    StorageRepository.saveUsers(_users);
    notifyListeners();
    return const AuthResult.ok();
  }

  void toggleUserStatus(String userId) {
    if (!isAdmin) return;
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx].isActive = !_users[idx].isActive;
      StorageRepository.saveUsers(_users);
      notifyListeners();
    }
  }

  bool deleteUser(String userId) {
    if (!isAdmin) return false;
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx == -1) return false;
    if (_users[idx].role == UserRole.admin) {
      final admins = _users.where((u) => u.role == UserRole.admin).length;
      if (admins <= 1) return false;
    }
    _users.removeAt(idx);
    StorageRepository.saveUsers(_users);
    notifyListeners();
    return true;
  }

  // --- الهوية والمظهر ---
  void updateBranding({
    required String appName,
    required String appTagline,
    required String logoIcon,
    required int primaryColorValue,
    required int accentColorValue,
  }) {
    if (!isAdmin) return;
    _branding.appName = appName;
    _branding.appTagline = appTagline;
    _branding.logoIcon = logoIcon;
    _branding.primaryColorValue = primaryColorValue;
    _branding.accentColorValue = accentColorValue;
    StorageRepository.saveBranding(_branding);
    notifyListeners();
  }

  void toggleThemeMode() {
    _branding.isDarkMode = !_branding.isDarkMode;
    StorageRepository.saveBranding(_branding);
    notifyListeners();
  }

  // --- حوكمة المحتوى ---
  void setContentPublishStatus({
    required String lessonId,
    required ContentStatus status,
  }) {
    if (!isAdmin) return;
    for (final curriculum in _curricula) {
      for (final course in curriculum.courses) {
        for (final module in course.modules) {
          final lIndex = module.lessons.indexWhere((l) => l.id == lessonId);
          if (lIndex != -1) {
            module.lessons[lIndex].status = status;
            StorageRepository.saveCurricula(_curricula);
            notifyListeners();
            unawaited(pushCurriculaToCloud());
            return;
          }
        }
      }
    }
  }

  // --- المسارات ---
  void createNewCurriculum({
    required String name,
    required String code,
    required String description,
    required DomainCategory category,
    required String iconName,
  }) {
    if (!isAdmin) return;
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
    unawaited(pushCurriculaToCloud());
  }

  void setActiveCurriculum(String curriculumId) {
    if (!isAdmin) return;
    _activeCurriculumId = curriculumId;
    _branding.activeCurriculumId = curriculumId;
    StorageRepository.saveBranding(_branding);
    notifyListeners();
  }

  // --- استوديو المؤلف ---
  void addCourseToActiveCurriculum({
    required String title,
    required String code,
    required String description,
    required String iconName,
  }) {
    if (!canAuthor) return;
    activeCurriculum.courses.add(
      Course(
        id: 'course_${DateTime.now().millisecondsSinceEpoch}',
        curriculumId: _activeCurriculumId,
        title: title,
        code: code,
        description: description,
        iconName: iconName,
        status: ContentStatus.published,
      ),
    );
    StorageRepository.saveCurricula(_curricula);
    notifyListeners();
    unawaited(pushCurriculaToCloud());
  }

  void addModuleToCourse({
    required String courseId,
    required String title,
    required String description,
  }) {
    if (!canAuthor) return;
    final course = activeCurriculum.courses.firstWhere((c) => c.id == courseId);
    course.modules.add(
      CourseModule(
        id: 'mod_${DateTime.now().millisecondsSinceEpoch}',
        courseId: courseId,
        title: title,
        description: description,
        orderIndex: course.modules.length + 1,
        status: ContentStatus.published,
      ),
    );
    StorageRepository.saveCurricula(_curricula);
    notifyListeners();
    unawaited(pushCurriculaToCloud());
  }

  void addLessonToModule({
    required String courseId,
    required String moduleId,
    required Lesson lesson,
    bool submitForReview = true,
  }) {
    if (!canAuthor) return;
    final course = activeCurriculum.courses.firstWhere((c) => c.id == courseId);
    final module = course.modules.firstWhere((m) => m.id == moduleId);

    // ربط هوية المؤلف
    lesson.authorId ??= _currentUser.id;
    lesson.authorName ??= _currentUser.name;

    // قيد صارم: لا نشر مباشر بدون اعتماد الإدارة
    if (!isAdmin) {
      lesson.status = submitForReview
          ? ContentStatus.pendingReview
          : ContentStatus.localDraft;
      if (submitForReview) {
        lesson.submittedAt = DateTime.now();
      }
    }

    final existingIndex = module.lessons.indexWhere((l) => l.id == lesson.id);
    if (existingIndex >= 0) {
      module.lessons[existingIndex] = lesson;
    } else {
      module.lessons.add(lesson);
    }

    StorageRepository.saveCurricula(_curricula);
    notifyListeners();

    if (submitForReview) {
      unawaited(pushCurriculaToCloud());
    }
  }

  // --- دورة المساهمة المجتمعية والمراجعة والاعتماد (Moderation) ---
  List<Lesson> getPendingReviewLessons() {
    final list = <Lesson>[];
    for (final c in _curricula) {
      for (final course in c.courses) {
        for (final m in course.modules) {
          for (final l in m.lessons) {
            if (l.isPendingReview) {
              list.add(l);
            }
          }
        }
      }
    }
    return list;
  }

  List<Lesson> getUserContributions(String userId) {
    final list = <Lesson>[];
    for (final c in _curricula) {
      for (final course in c.courses) {
        for (final m in course.modules) {
          for (final l in m.lessons) {
            if (l.authorId == userId || l.creatorId == userId) {
              list.add(l);
            }
          }
        }
      }
    }
    return list;
  }

  // --- إدارة المسودات المحلية وطابور المزامنة الذكي (Offline Drafts Queue) ---
  List<Lesson> getLocalDrafts() {
    final list = <Lesson>[];
    for (final c in _curricula) {
      for (final course in c.courses) {
        for (final m in course.modules) {
          for (final l in m.lessons) {
            if (l.isLocalDraft && (l.authorId == _currentUser.id || l.creatorId == _currentUser.id || isAdmin)) {
              list.add(l);
            }
          }
        }
      }
    }
    return list;
  }

  bool get hasLocalDrafts => getLocalDrafts().isNotEmpty;

  /// رفع ومزامنة كافة المسودات المحلية دفعة واحدة إلى السحابة بحالة قيد المراجعة
  Future<int> syncAllLocalDrafts() async {
    final drafts = getLocalDrafts();
    if (drafts.isEmpty) return 0;

    int syncedCount = 0;
    final now = DateTime.now();

    for (final lesson in drafts) {
      lesson.status = ContentStatus.pendingReview;
      lesson.submittedAt = now;
      syncedCount++;
    }

    await StorageRepository.saveCurricula(_curricula);
    setNotification('🚀 تم رفع $syncedCount مسودة بنجاح للمراجعة والاعتماد السحابي!');
    notifyListeners();
    unawaited(pushCurriculaToCloud());
    return syncedCount;
  }

  /// البحث عن سياق الدرس (المسار، المادة، الوحدة) لإعادة التعديل والاعتماد
  Map<String, dynamic>? findLessonContext(String lessonId) {
    for (final cur in _curricula) {
      for (final course in cur.courses) {
        for (final module in course.modules) {
          final lIndex = module.lessons.indexWhere((l) => l.id == lessonId);
          if (lIndex != -1) {
            return {
              'curriculum': cur,
              'course': course,
              'module': module,
              'lesson': module.lessons[lIndex],
            };
          }
        }
      }
    }
    return null;
  }

  /// بنمط هرمش والتعلم المفتوح (Harmash Open-Access): كافة الدروس المعتمدة مفتوحة للتصفح المباشر دون قفل
  bool isLessonLocked(Course course, String lessonId) {
    return false; // وصول حر ومفتوح لجميع الدروس البرمجية
  }

  /// القفل محصور فقط في الاختبار النهائي المانح للشهادة
  bool isCourseCertificateUnlocked(Course course) {
    final allApproved = <Lesson>[];
    for (final m in course.modules) {
      for (final l in m.lessons) {
        if (l.isApproved) allApproved.add(l);
      }
    }
    if (allApproved.isEmpty) return false;
    return allApproved.every((l) => isLessonCompleted(l.id));
  }

  void approveLesson(String lessonId) {
    if (!isAdmin) return;
    for (final c in _curricula) {
      for (final course in c.courses) {
        for (final m in course.modules) {
          final idx = m.lessons.indexWhere((l) => l.id == lessonId);
          if (idx >= 0) {
            final lesson = m.lessons[idx];
            // تطبيق النسخة الظلية للتعديل ذرياً (Atomic Shadow Swap)
            if (lesson.hasShadowUpdate) {
              final payload = lesson.pendingUpdatePayload!;
              if (payload['title'] != null) lesson.title = payload['title'];
              if (payload['titleEn'] != null) lesson.titleEn = payload['titleEn'];
              if (payload['summary'] != null) lesson.summary = payload['summary'];
              if (payload['summaryEn'] != null) lesson.summaryEn = payload['summaryEn'];
              if (payload['articleContent'] != null) lesson.articleContent = payload['articleContent'];
              if (payload['articleContentEn'] != null) lesson.articleContentEn = payload['articleContentEn'];
              if (payload['cards'] != null) {
                lesson.cards = (payload['cards'] as List).map((c) => LessonCard.fromJson(c)).toList();
              }
              if (payload['quizzes'] != null) {
                lesson.quizzes = (payload['quizzes'] as List).map((q) => QuizQuestion.fromJson(q)).toList();
              }
              lesson.pendingUpdatePayload = null;
            }

            lesson.status = ContentStatus.approved;
            lesson.reviewedAt = DateTime.now();
            lesson.adminComment = null;
            StorageRepository.saveCurricula(_curricula);
            setNotification('🎉 تم اعتماد ونشر الدرس "${lesson.title}" بنجاح!');
            notifyListeners();
            unawaited(pushCurriculaToCloud());
            return;
          }
        }
      }
    }
  }

  /// إضافة رسالة تفاعلية داخل سلسلة مراجعة الدرس (Two-way Review Thread)
  void addReviewMessage({required String lessonId, required String message}) {
    final clean = message.trim();
    if (clean.isEmpty) return;

    for (final c in _curricula) {
      for (final course in c.courses) {
        for (final m in course.modules) {
          final idx = m.lessons.indexWhere((l) => l.id == lessonId);
          if (idx >= 0) {
            final lesson = m.lessons[idx];
            lesson.reviewThread.add(
              ReviewMessage(
                id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                senderId: _currentUser.id,
                senderName: _currentUser.name.isNotEmpty ? _currentUser.name : 'مستخدم',
                senderRole: _currentUser.role,
                message: clean,
              ),
            );
            StorageRepository.saveCurricula(_curricula);
            notifyListeners();
            unawaited(pushCurriculaToCloud());
            return;
          }
        }
      }
    }
  }

  void requestLessonRevision(String lessonId, String comment) {
    if (!isAdmin) return;
    for (final c in _curricula) {
      for (final course in c.courses) {
        for (final m in course.modules) {
          final idx = m.lessons.indexWhere((l) => l.id == lessonId);
          if (idx >= 0) {
            m.lessons[idx].status = ContentStatus.needsRevision;
            m.lessons[idx].adminComment = comment;
            m.lessons[idx].reviewedAt = DateTime.now();
            StorageRepository.saveCurricula(_curricula);
            setNotification('⚠️ تم إرسال ملاحظات التعديل للدرس "${m.lessons[idx].title}".');
            notifyListeners();
            unawaited(pushCurriculaToCloud());
            return;
          }
        }
      }
    }
  }

  void rejectLesson(String lessonId, String reason) {
    if (!isAdmin) return;
    for (final c in _curricula) {
      for (final course in c.courses) {
        for (final m in course.modules) {
          final idx = m.lessons.indexWhere((l) => l.id == lessonId);
          if (idx >= 0) {
            m.lessons[idx].status = ContentStatus.rejected;
            m.lessons[idx].adminComment = reason;
            m.lessons[idx].reviewedAt = DateTime.now();
            StorageRepository.saveCurricula(_curricula);
            setNotification('تم رفض الدرس "${m.lessons[idx].title}".');
            notifyListeners();
            unawaited(pushCurriculaToCloud());
            return;
          }
        }
      }
    }
  }

  // --- الإشعارات الخفيفة والرسائل التحفيزية ---
  String? _notificationMessage;
  String? get notificationMessage => _notificationMessage;

  void setNotification(String message) {
    _notificationMessage = message;
    notifyListeners();
  }

  void dismissNotification() {
    _notificationMessage = null;
    notifyListeners();
  }

  int _countPublishedLessons() {
    int total = 0;
    for (final c in _curricula) {
      for (final crs in c.courses) {
        for (final m in crs.modules) {
          for (final l in m.lessons) {
            if (l.isApproved) total++;
          }
        }
      }
    }
    return total;
  }

  // --- الربط والمزامنة السحابية (Cloud Sync) ---
  Future<void> _triggerBackgroundSync() async {
    try {
      final remote = await CloudSyncService.instance.pullCurricula();
      if (remote != null && remote.isNotEmpty) {
        mergeRemoteCurricula(remote);
      }
    } catch (_) {}
  }

  Future<bool> pushCurriculaToCloud() async {
    return CloudSyncService.instance.pushCurricula(_curricula);
  }

  Future<bool> pullCurriculaFromCloud() async {
    final remote = await CloudSyncService.instance.pullCurricula();
    if (remote != null && remote.isNotEmpty) {
      mergeRemoteCurricula(remote);
      return true;
    }
    return false;
  }

  void mergeRemoteCurricula(List<CurriculumDomain> remoteList) {
    final prevCount = _countPublishedLessons();

    for (final remote in remoteList) {
      final idx = _curricula.indexWhere((c) => c.id == remote.id);
      if (idx >= 0) {
        _curricula[idx] = remote;
      } else {
        _curricula.add(remote);
      }
    }

    final newCount = _countPublishedLessons();
    if (newCount > prevCount) {
      setNotification('🔥 تمت إضافة دروس برمجية جديدة، واصل تقدمك!');
    }

    // فحص تحديثات مساهمات المستخدم الحالي
    final myContributions = getUserContributions(_currentUser.id);
    for (final lesson in myContributions) {
      if (lesson.isApproved && lesson.reviewedAt != null && DateTime.now().difference(lesson.reviewedAt!).inHours < 24) {
        setNotification('🎉 تم اعتماد ونشر درسك "${lesson.title}" من قِبل الإدارة!');
        break;
      } else if (lesson.isNeedsRevision && lesson.adminComment != null) {
        setNotification('⚠️ درسك "${lesson.title}" يحتاج لتعديل وفق ملاحظات الإدارة.');
        break;
      }
    }

    StorageRepository.saveCurricula(_curricula);
    notifyListeners();
  }

  // --- التصدير والاستيراد ---
  String exportActiveCurriculumJson() {
    return JsonEncoder.withIndent('  ').convert(activeCurriculum.toJson());
  }

  bool importCurriculumFromJson(String jsonContent) {
    if (!isAdmin) return false;
    try {
      final decoded = jsonDecode(jsonContent) as Map<String, dynamic>;
      final domain = CurriculumDomain.fromJson(decoded);
      _curricula.removeWhere((c) => c.id == domain.id);
      _curricula.add(domain);
      _activeCurriculumId = domain.id;
      StorageRepository.saveCurricula(_curricula);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  // --- البحث والمحاولات ---
  void logAttempt({
    required String questionId,
    required String lessonId,
    required List<int> chosen,
    required bool isCorrect,
    required int durationMs,
    AttemptPhase phase = AttemptPhase.practice,
  }) {
    if (!_isAuthenticated) return;
    StorageRepository.recordAttempt(
      Attempt(
        id: 'att_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser.id,
        questionId: questionId,
        lessonId: lessonId,
        sessionId: _activeSessionId,
        chosen: chosen,
        isCorrect: isCorrect,
        durationMs: durationMs,
        phase: phase,
      ),
    );
  }

  Future<String> exportResearchCsv() => StorageRepository.exportAttemptsCsv();

  // --- التقدم والسلسلة ---
  bool isLessonCompleted(String lessonId) =>
      _currentUser.completedLessonIds.contains(lessonId);

  int get completedLessonsCount => _currentUser.completedLessonIds.length;

  void completeLesson(String lessonId, int earnedXp) {
    if (!_isAuthenticated) return;
    if (_currentUser.completedLessonIds.contains(lessonId)) return;

    final oldLevel = _currentUser.level;
    _currentUser.completedLessonIds.add(lessonId);
    _currentUser.xp += earnedXp;
    _touchStreak();
    _persistUserProgress();

    final newLevel = _currentUser.level;
    if (newLevel > oldLevel) {
      setNotification('🚀 ارتقاء للمستوى $newLevel! أصبحت الآن "${_currentUser.levelTitle}". واصل تميزك!');
    } else {
      setNotification('🎯 أحسنت! أكملت الدرس بنجاح وحصلت على +$earnedXp XP!');
    }
    notifyListeners();
  }

  void _touchStreak() {
    if (!_isAuthenticated) return;
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

  Future<void> _loadProgressFor(AppUser user) async {
    final loaded = await StorageRepository.loadUserProgress(user.id);
    if (loaded == null) return;
    user.xp = loaded['xp'] ?? user.xp;
    user.streakDays = loaded['streakDays'] ?? user.streakDays;
    user.completedLessonIds =
        List<String>.from(loaded['completedLessonIds'] ?? []);
    final last = loaded['lastActiveDate'];
    if (last != null) {
      user.lastActiveDate = DateTime.tryParse(last) ?? user.lastActiveDate;
    }
  }

  Future<void> _persistUserProgress() async {
    if (!_isAuthenticated) return;
    await StorageRepository.saveUserProgress(
      userId: _currentUser.id,
      xp: _currentUser.xp,
      streakDays: _currentUser.streakDays,
      lastActiveDate: _currentUser.lastActiveDate,
      completedLessonIds: _currentUser.completedLessonIds,
    );
  }
}

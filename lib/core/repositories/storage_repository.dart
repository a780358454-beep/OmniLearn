import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_models.dart';

class StorageRepository {
  static const String _keyBranding = 'omni_branding_v2';
  static const String _keyProgress = 'omni_progress_v2';
  static const String _keyCurricula = 'omni_curricula_v2';
  static const String _keyAttempts = 'omni_attempts_v2';
  static const String _keyUsers = 'omni_users_v1';
  static const String _keySession = 'omni_session_v1';
  static const String _keyCloudEndpoint = 'omni_cloud_endpoint_v1';
  static const String _keyLastSync = 'omni_last_sync_v1';
  static const String _keyUserActiveCurriculum = 'omni_user_active_curriculum_v1';

  // --- 1. حفظ واسترجاع الهوية والإعدادات ---
  static Future<void> saveBranding(AppBrandingConfig branding) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBranding, jsonEncode(branding.toJson()));
  }

  static Future<AppBrandingConfig?> loadBranding() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyBranding);
    if (raw == null) return null;
    try {
      return AppBrandingConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  // --- 2. حفظ واسترجاع تقدم الطالب والسلسلة ---
  static Future<void> saveUserProgress({
    required String userId,
    required int xp,
    required int streakDays,
    required DateTime lastActiveDate,
    required List<String> completedLessonIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'userId': userId,
      'xp': xp,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'completedLessonIds': completedLessonIds,
    };
    await prefs.setString('${_keyProgress}_$userId', jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadUserProgress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_keyProgress}_$userId');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // --- 3. حفظ واسترجاع المحاولات للورقة البحثية (Attempts) ---
  static Future<void> recordAttempt(Attempt attempt) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await loadAttempts();
    currentList.add(attempt);
    final encoded = jsonEncode(currentList.map((a) => a.toJson()).toList());
    await prefs.setString(_keyAttempts, encoded);
  }

  static Future<List<Attempt>> loadAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAttempts);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => Attempt.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// تصدير المحاولات إلى CSV جاهز للتحليل الإحصائي (SPSS / Excel)
  static Future<String> exportAttemptsCsv() async {
    final attempts = await loadAttempts();
    final buffer = StringBuffer();
    buffer.writeln(
      'id,userId,questionId,lessonId,sessionId,chosen,isCorrect,durationMs,phase,createdAt',
    );
    for (var a in attempts) {
      buffer.writeln(a.toCsvRow());
    }
    return buffer.toString();
  }

  // --- 4. حفظ واسترجاع المناهج المخصصة ---
  static Future<void> saveCurricula(List<CurriculumDomain> curricula) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(curricula.map((c) => c.toJson()).toList());
    await prefs.setString(_keyCurricula, encoded);
  }

  static Future<List<CurriculumDomain>?> loadCurricula() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCurricula);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => CurriculumDomain.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // --- 5. حفظ واسترجاع المستخدمين (الحسابات) ---
  static Future<void> saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_keyUsers, encoded);
  }

  static Future<List<AppUser>?> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUsers);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // --- 6. الجلسة الحالية ---
  static Future<void> saveSessionUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySession, userId);
  }

  static Future<String?> loadSessionUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySession);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySession);
  }

  // --- 7. الربط السحابي (Cloud Sync) ---
  static Future<void> saveCloudEndpoint(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCloudEndpoint, endpoint.trim());
  }

  static Future<String?> loadCloudEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCloudEndpoint);
  }

  static Future<void> saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSync, time.toIso8601String());
  }

  static Future<DateTime?> loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastSync);
    if (raw == null) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  // --- 8. حفظ واسترجاع المسار النشط المختار للطالب ---
  static Future<void> saveUserActiveCurriculum(String curriculumId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserActiveCurriculum, curriculumId);
  }

  static Future<String?> loadUserActiveCurriculum() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserActiveCurriculum);
  }
}

import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/models/learning_models.dart';
import '../../core/design/design_tokens.dart';
import '../auth/change_password_screen.dart';
import '../auth/login_screen.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(68);

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير';
      case UserRole.creator:
        return 'مشرف';
      case UserRole.student:
        return 'طالب';
    }
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '؟';
    return trimmed.substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    final i18n = I18nService.instance;
    final user = state.currentUser;
    final branding = state.branding;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Space.sm),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(RadiusTokens.card),
              ),
              child: const Icon(
                Icons.code_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    branding.appName,
                    style: AppTypography.title.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    state.activeCurriculum.name,
                    style: AppTypography.caption.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // الثيم
            IconButton(
              icon: Icon(
                state.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                size: 20,
              ),
              tooltip: state.isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
              onPressed: () => state.toggleThemeMode(),
            ),

            // اللغة
            InkWell(
              onTap: () => i18n.toggleLanguage(),
              borderRadius: BorderRadius.circular(RadiusTokens.field),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.sm,
                  vertical: Space.xs,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(RadiusTokens.field),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language, size: 16),
                    const SizedBox(width: Space.xs),
                    Text(
                      i18n.isArabic ? 'EN' : 'عربي',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Space.sm),

            // قائمة الحساب — لا تبديل أدوار هنا
            PopupMenuButton<String>(
              tooltip: 'الحساب',
              onSelected: (value) async {
                if (value == 'password') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                } else if (value == 'logout') {
                  await state.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.card),
              ),
              color: cs.surface,
              itemBuilder: (_) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty ? 'مستخدم' : user.name,
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _roleLabel(user.role),
                        style: AppTypography.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'password',
                  child: Row(
                    children: [
                      Icon(
                        user.mustChangePassword
                            ? Icons.warning_amber_rounded
                            : Icons.lock_reset_outlined,
                        size: 18,
                        color: user.mustChangePassword
                            ? ColorTokens.warning
                            : cs.primary,
                      ),
                      const SizedBox(width: Space.sm),
                      const Text('تغيير كلمة السر'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: ColorTokens.error),
                      SizedBox(width: Space.sm),
                      Text('تسجيل الخروج'),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 18,
                backgroundColor: cs.primary,
                child: Text(
                  _initials(user.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

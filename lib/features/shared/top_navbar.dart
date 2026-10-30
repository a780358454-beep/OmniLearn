import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/services/cloud_sync_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/models/learning_models.dart';
import '../../core/design/design_tokens.dart';
import '../auth/change_password_screen.dart';
import '../auth/login_screen.dart';
import '../creator/creator_studio_screen.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(68);

  String _roleLabel(UserRole role, I18nService i18n) {
    switch (role) {
      case UserRole.admin:
        return i18n.t('role_admin');
      case UserRole.creator:
        return i18n.t('role_creator');
      case UserRole.student:
        return i18n.t('role_student');
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
              tooltip: state.isDarkMode ? i18n.t('theme_mode_light') : i18n.t('theme_mode_dark'),
              onPressed: () => state.toggleThemeMode(),
            ),

            // المزامنة السحابية المباشرة
            AnimatedBuilder(
              animation: CloudSyncService.instance,
              builder: (context, _) {
                final cloud = CloudSyncService.instance;
                IconData icon;
                Color? iconColor;
                if (cloud.status == CloudSyncStatus.syncing) {
                  icon = Icons.sync_rounded;
                  iconColor = cs.primary;
                } else if (cloud.status == CloudSyncStatus.synced) {
                  icon = Icons.cloud_done_rounded;
                  iconColor = ColorTokens.accentGreen;
                } else if (cloud.status == CloudSyncStatus.error) {
                  icon = Icons.cloud_off_rounded;
                  iconColor = ColorTokens.error;
                } else {
                  icon = Icons.cloud_queue_rounded;
                  iconColor = cs.onSurfaceVariant;
                }

                return IconButton(
                  icon: cloud.status == CloudSyncStatus.syncing
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                        )
                      : Icon(icon, color: iconColor, size: 20),
                  tooltip: i18n.t('cloud_sync'),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(i18n.t('cloud_syncing')),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    final ok = await state.pullCurriculaFromCloud();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? i18n.t('cloud_pull_success') : i18n.t('cloud_sync_failed')),
                          backgroundColor: ok ? ColorTokens.success : ColorTokens.warning,
                        ),
                      );
                    }
                  },
                );
              },
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

            // قائمة الحساب
            PopupMenuButton<String>(
              tooltip: i18n.t('account'),
              onSelected: (value) async {
                if (value == 'contributions') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreatorStudioScreen(),
                    ),
                  );
                } else if (value == 'password') {
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
                        user.name.isEmpty ? 'User' : user.name,
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(RadiusTokens.pill),
                        ),
                        child: Text(
                          'Lv.${user.level} • ${user.levelTitle}',
                          style: AppTypography.caption.copyWith(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _roleLabel(user.role, i18n),
                        style: AppTypography.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'contributions',
                  child: Row(
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: 18, color: cs.primary),
                      const SizedBox(width: Space.sm),
                      Text(i18n.t('my_contributions')),
                    ],
                  ),
                ),
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
                      Text(i18n.t('change_password')),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18, color: ColorTokens.error),
                      const SizedBox(width: Space.sm),
                      Text(i18n.t('logout')),
                    ],
                  ),
                ),
              ],
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
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
                  Positioned(
                    bottom: -2,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(RadiusTokens.pill),
                        border: Border.all(color: cs.surface, width: 1.5),
                      ),
                      child: Text(
                        'Lv.${user.level}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

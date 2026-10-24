import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/models/learning_models.dart';
import '../../core/design/design_tokens.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onOpenAdmin;
  final VoidCallback? onOpenCreator;

  const TopNavbar({
    Key? key,
    this.onOpenAdmin,
    this.onOpenCreator,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    final i18n = I18nService.instance;
    final user = state.currentUser;
    final branding = state.branding;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // أيقونة المنصة
            Container(
              padding: const EdgeInsets.all(Space.sm),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(RadiusTokens.card),
              ),
              child: const Icon(Icons.code_rounded, color: Colors.white, size: 22),
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
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // زر تبديل الثيم (داكن / فاتح)
            IconButton(
              icon: Icon(
                state.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 20,
              ),
              tooltip: state.isDarkMode ? i18n.t('theme_mode_light') : i18n.t('theme_mode_dark'),
              onPressed: () => state.toggleThemeMode(),
            ),

            // زر تبديل اللغة (عربي / English)
            InkWell(
              onTap: () => i18n.toggleLanguage(),
              borderRadius: BorderRadius.circular(RadiusTokens.field),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(RadiusTokens.field),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language, size: 16),
                    const SizedBox(width: Space.xs),
                    Text(
                      i18n.isArabic ? 'EN' : 'عربي',
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Space.sm),

            // منتقي الدور السريع (معاينة تجريبية Demo)
            PopupMenuButton<UserRole>(
              tooltip: i18n.t('switch_role'),
              onSelected: (role) => state.switchRole(role),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RadiusTokens.card)),
              color: colorScheme.surface,
              itemBuilder: (ctx) => [
                _buildRoleItem(
                  role: UserRole.admin,
                  label: i18n.t('role_admin'),
                  icon: Icons.admin_panel_settings,
                  color: ColorTokens.warning,
                  isSelected: user.role == UserRole.admin,
                  context: context,
                ),
                _buildRoleItem(
                  role: UserRole.creator,
                  label: i18n.t('role_creator'),
                  icon: Icons.edit_note_rounded,
                  color: colorScheme.primary,
                  isSelected: user.role == UserRole.creator,
                  context: context,
                ),
                _buildRoleItem(
                  role: UserRole.student,
                  label: i18n.t('role_student'),
                  icon: Icons.school_rounded,
                  color: ColorTokens.success,
                  isSelected: user.role == UserRole.student,
                  context: context,
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(RadiusTokens.field),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(_getRoleIcon(user.role), size: 16, color: colorScheme.primary),
                    const SizedBox(width: Space.xs),
                    Text(
                      _getRoleLabel(user.role, i18n),
                      style: AppTypography.caption.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<UserRole> _buildRoleItem({
    required UserRole role,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuItem<UserRole>(
      value: role,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected) Icon(Icons.check, color: colorScheme.primary, size: 16),
        ],
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.creator:
        return Icons.draw_rounded;
      case UserRole.student:
        return Icons.school;
    }
  }

  String _getRoleLabel(UserRole role, I18nService i18n) {
    switch (role) {
      case UserRole.admin:
        return i18n.t('role_admin');
      case UserRole.creator:
        return i18n.t('role_creator');
      case UserRole.student:
        return i18n.t('role_student');
    }
  }
}

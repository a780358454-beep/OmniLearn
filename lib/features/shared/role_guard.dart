import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/models/learning_models.dart';
import '../../core/design/design_tokens.dart';

/// حارس مسار: يُظهر شاشة منع بدل الشاشة المطلوبة عند عدم امتلاك الصلاحية.
class RoleGuard extends StatelessWidget {
  final List<UserRole> roles;
  final Widget child;

  const RoleGuard({Key? key, required this.roles, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AppStateService.instance.currentUser;
    return roles.contains(user.role) ? child : const ForbiddenScreen();
  }
}

/// شاشة 403
class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Space.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: cs.error),
              const SizedBox(height: Space.lg),
              Text(
                'لا تملك صلاحية الوصول',
                style: AppTypography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Space.sm),
              Text(
                'هذه الشاشة متاحة للمدير فقط. إن كنت تعتقد أن هذا خطأ، راجع مدير المنصة.',
                style: AppTypography.bodySmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Space.xl),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('رجوع'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

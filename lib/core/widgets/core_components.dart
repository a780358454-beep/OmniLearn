import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

/// 1. بطاقة الخيار التفاعلية للاختبارات
class OptionTile extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isAnswered;
  final bool? isCorrect;
  final VoidCallback? onTap;

  const OptionTile({
    Key? key,
    required this.text,
    required this.index,
    required this.isSelected,
    this.isAnswered = false,
    this.isCorrect,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color borderColor = colorScheme.outlineVariant;
    Color bgColor = colorScheme.surface;
    Color numBg = colorScheme.surfaceContainerHighest;
    Color numColor = colorScheme.onSurface;

    if (isAnswered) {
      if (isCorrect == true) {
        borderColor = ColorTokens.success;
        bgColor = ColorTokens.success.withOpacity(0.12);
        numBg = ColorTokens.success;
        numColor = Colors.white;
      } else if (isSelected && isCorrect == false) {
        borderColor = ColorTokens.error;
        bgColor = ColorTokens.error.withOpacity(0.12);
        numBg = ColorTokens.error;
        numColor = Colors.white;
      }
    } else if (isSelected) {
      borderColor = colorScheme.primary;
      bgColor = colorScheme.primary.withOpacity(0.12);
      numBg = colorScheme.primary;
      numColor = colorScheme.onPrimary;
    }

    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: isAnswered ? null : onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          margin: const EdgeInsets.only(bottom: Space.md),
          padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(RadiusTokens.card),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: numBg,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: numColor,
                  ),
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.body.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2. مكون الحالة الفارغة (Empty State)
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String reason;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.reason,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: Space.lg),
            Text(
              title,
              style: AppTypography.title.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.sm),
            Text(
              reason,
              style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Space.xl),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 3. مكون الهيكل العظمي للتحميل (Loading Skeleton)
class LoadingSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const LoadingSkeleton({
    Key? key,
    this.height = 72,
    this.width = double.infinity,
    this.borderRadius = RadiusTokens.card,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.only(bottom: Space.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 4. مكون حالة الخطأ مع إعادة المحاولة (Error View)
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: ColorTokens.error),
            const SizedBox(height: Space.md),
            Text(
              message,
              style: AppTypography.body.copyWith(color: ColorTokens.textHigh),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 5. شارة إحصائية للأرقام (XP / Streak)
class StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const StatChip({
    Key? key,
    required this.icon,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: Space.xs),
        Text(
          label,
          style: AppTypography.label.copyWith(color: color),
        ),
      ],
    );
  }
}

/// 6. عنوان موحد للأقسام
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({
    Key? key,
    required this.title,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.title.copyWith(color: theme.colorScheme.onSurface),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 7. شريط تعليل الخطأ (Why Wrong Banner)
class ReasonBanner extends StatelessWidget {
  final String reason;
  final bool isCorrect;

  const ReasonBanner({
    Key? key,
    required this.reason,
    required this.isCorrect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? ColorTokens.success : ColorTokens.error;
    return Container(
      padding: const EdgeInsets.all(Space.md),
      margin: const EdgeInsets.only(top: Space.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: color, size: 20),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(
              reason,
              style: AppTypography.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

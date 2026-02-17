import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  OfferCard  (horizontal scroll card)
// ─────────────────────────────────────────────
class OfferCard extends StatelessWidget {
  final String title, restaurant, price, distance, pickupTime, imageUrl;
  final VoidCallback? onTap;

  const OfferCard({
    super.key,
    required this.title,
    required this.restaurant,
    required this.price,
    this.distance = '',
    this.pickupTime = '',
    this.imageUrl = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusCard)),
              child: Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.primary.withValues(alpha: 0.08),
                    child: Hero(
                      tag: title,
                      child: imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.restaurant, color: AppColors.primary, size: 36)))
                          : const Center(child: Icon(Icons.restaurant, color: AppColors.primary, size: 36)),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                      child: Text(distance, style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                     child: CircleAvatar(
                      radius: 14, backgroundColor: Colors.white.withOpacity(0.9),
                      child: const Icon(Icons.favorite_border, size: 16, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(restaurant, style: AppTextStyles.caption, maxLines: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(price, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontSize: 15)),
                      const Spacer(),
                      if (pickupTime.isNotEmpty) ...[
                        const Icon(Icons.access_time, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Text(pickupTime, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                      ],
                    ],
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

// ─────────────────────────────────────────────
//  OfferListTile  (vertical list item)
// ─────────────────────────────────────────────
class OfferListTile extends StatelessWidget {
  final String title, restaurant, price, distance, pickupTime, imageUrl;
  final VoidCallback? onTap;

  const OfferListTile({
    super.key,
    required this.title,
    required this.restaurant,
    required this.price,
    this.distance = '',
    this.pickupTime = '',
    this.imageUrl = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              child: Container(
                width: 72, height: 72,
                color: AppColors.primary.withValues(alpha: 0.08),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: AppColors.primary))
                    : const Icon(Icons.restaurant, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(restaurant, style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(price, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontSize: 14)),
                      const Spacer(),
                      if (distance.isNotEmpty)
                        Text(distance, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    ],
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

// ─────────────────────────────────────────────
//  MetricCard
// ─────────────────────────────────────────────
class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const MetricCard({super.key, required this.icon, required this.label, required this.value, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  StatusBadge
// ─────────────────────────────────────────────
enum BadgeStatus { active, soldOut, pending, suspended, completed, cancelled }

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String? customLabel;

  const StatusBadge({super.key, required this.status, this.customLabel});

  Color get _bgColor {
    switch (status) {
      case BadgeStatus.active:     return AppColors.success.withValues(alpha: 0.12);
      case BadgeStatus.soldOut:    return AppColors.orange.withValues(alpha: 0.12);
      case BadgeStatus.pending:    return AppColors.warning.withValues(alpha: 0.12);
      case BadgeStatus.suspended:  return AppColors.error.withValues(alpha: 0.12);
      case BadgeStatus.completed:  return AppColors.info.withValues(alpha: 0.12);
      case BadgeStatus.cancelled:  return AppColors.textHint.withValues(alpha: 0.12);
    }
  }

  Color get _fgColor {
    switch (status) {
      case BadgeStatus.active:     return AppColors.success;
      case BadgeStatus.soldOut:    return AppColors.orange;
      case BadgeStatus.pending:    return AppColors.warning;
      case BadgeStatus.suspended:  return AppColors.error;
      case BadgeStatus.completed:  return AppColors.info;
      case BadgeStatus.cancelled:  return AppColors.textHint;
    }
  }

  String get _label {
    if (customLabel != null) return customLabel!;
    switch (status) {
      case BadgeStatus.active:     return 'Active';
      case BadgeStatus.soldOut:    return 'Sold Out';
      case BadgeStatus.pending:    return 'Pending';
      case BadgeStatus.suspended:  return 'Suspended';
      case BadgeStatus.completed:  return 'Completed';
      case BadgeStatus.cancelled:  return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
      child: Text(_label, style: AppTextStyles.caption.copyWith(color: _fgColor, fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────
//  PrimaryButton  &  SecondaryButton
// ─────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({super.key, required this.label, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
          textStyle: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
          textStyle: AppTextStyles.titleMedium,
        ),
        child: Text(label),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AppInputField
// ─────────────────────────────────────────────
class AppInputField extends StatelessWidget {
  final String label, hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const AppInputField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Fix: Prevent infinite height in Row/Column
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          ),
        ),
      ],
    );
  }
}

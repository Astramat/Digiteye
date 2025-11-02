import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/border_radius.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// Dialog de confirmation
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final bool isDestructive;
  
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.isDestructive = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.dialog),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Icon(
              isDestructive ? Icons.warning_amber_rounded : Icons.help_outline,
              size: 48,
              color: isDestructive ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Titre
            Text(
              title,
              style: AppTextStyles.heading6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Message
            Text(
              message,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Boutons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: cancelText ?? 'Annuler',
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    text: confirmText ?? 'Confirmer',
                    backgroundColor: isDestructive ? AppColors.error : confirmButtonColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Affiche un dialog de confirmation
Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  Color? confirmButtonColor,
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => ConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmButtonColor: confirmButtonColor,
      isDestructive: isDestructive,
    ),
  );
}

/// Dialog de confirmation pour suppression
Future<bool?> showDeleteConfirmationDialog(
  BuildContext context, {
  required String itemName,
  VoidCallback? onDelete,
}) {
  return showConfirmationDialog(
    context,
    title: 'Supprimer',
    message: 'Êtes-vous sûr de vouloir supprimer "$itemName" ?',
    confirmText: 'Supprimer',
    cancelText: 'Annuler',
    isDestructive: true,
    confirmButtonColor: AppColors.error,
    onConfirm: onDelete,
  );
}

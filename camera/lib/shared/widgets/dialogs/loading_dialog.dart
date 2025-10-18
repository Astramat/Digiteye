import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/border_radius.dart';

/// Dialog de chargement
class LoadingDialog extends StatelessWidget {
  final String? message;
  final bool isDismissible;
  
  const LoadingDialog({
    super.key,
    this.message,
    this.isDismissible = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isDismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.dialog),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  message!,
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Affiche un dialog de chargement
Future<void> showLoadingDialog(
  BuildContext context, {
  String? message,
  bool isDismissible = false,
}) {
  return showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (context) => LoadingDialog(
      message: message,
      isDismissible: isDismissible,
    ),
  );
}

/// Ferme le dialog de chargement
void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

// ============================================
// REUSABLE UI COMPONENTS LIBRARY
// Professional, modern, ready-to-use widgets
// ============================================

/// Modern elevated button with role-based theming
class AppElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final MainAxisAlignment iconAlignment;

  const AppElevatedButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = AppSpacing.buttonHeightMedium,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconAlignment = MainAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading || !isEnabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.buyerPrimary,
          disabledBackgroundColor: AppColors.disabled,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.br_lg,
          ),
          elevation: isEnabled ? 4 : 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: iconAlignment,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: textColor ?? Colors.white),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        label,
                        style: AppTypography.labelLarge(
                          color: textColor ?? Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    label,
                    style: AppTypography.labelLarge(
                      color: textColor ?? Colors.white,
                    ),
                  ),
      ),
    );
  }
}

/// Modern outlined button
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? textColor;
  final bool isEnabled;
  final double? width;

  const AppOutlinedButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.isEnabled = true,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: AppSpacing.buttonHeightMedium,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor ?? AppColors.buyerPrimary,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.br_lg,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge(
            color: textColor ?? AppColors.buyerPrimary,
          ),
        ),
      ),
    );
  }
}

/// Modern text input field with validation
class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int maxLines;
  final int minLines;
  final String? errorText;
  final Color? borderColor;

  const AppTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.minLines = 1,
    this.errorText,
    this.borderColor,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.labelMedium(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          style: AppTypography.bodyMedium(),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.bodyMedium(
              color: AppColors.textHint,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(widget.suffixIcon),
                    onPressed: widget.onSuffixIconPressed ??
                        () {
                          setState(() => _obscureText = !_obscureText);
                        },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.br_md,
              borderSide: BorderSide(
                color: widget.borderColor ?? AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.br_md,
              borderSide: BorderSide(
                color: widget.borderColor ?? AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.br_md,
              borderSide: BorderSide(
                color: widget.borderColor ?? AppColors.buyerPrimary,
                width: 2,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: AppSpacing.br_md,
              borderSide: BorderSide(
                color: AppColors.error,
              ),
            ),
            contentPadding: AppSpacing.inputPadding,
            errorText: widget.errorText,
            errorStyle: AppTypography.bodySmall(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern card widget
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Border? border;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation = 2,
    this.borderRadius,
    this.onTap,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: backgroundColor ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? AppSpacing.br_lg,
        side: border?.top ?? BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? AppSpacing.cardPadding,
          child: child,
        ),
      ),
    );
  }
}

/// Loading shimmer placeholder
class AppShimmerLoader extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const AppShimmerLoader({
    Key? key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Empty state widget
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;
  final Color? iconColor;

  const AppEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppSpacing.iconXLarge * 2,
            color: iconColor ?? AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTypography.h4(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description!,
              style: AppTypography.bodyMedium(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xl),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Error state widget
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const AppErrorState({
    Key? key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      description: message,
      iconColor: AppColors.error,
      action: onRetry != null
          ? AppElevatedButton(
              label: retryLabel,
              onPressed: onRetry!,
              backgroundColor: AppColors.error,
            )
          : null,
    );
  }
}

/// Loading overlay
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const AppLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      message!,
                      style: AppTypography.bodyMedium(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Badge widget for notifications, badges
class AppBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets padding;

  const AppBadge({
    Key? key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.buyerPrimary,
        borderRadius: AppSpacing.br_lg,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}

/// Expandable section widget
class AppExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final Color? titleColor;

  const AppExpandableSection({
    Key? key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.titleColor,
  }) : super(key: key);

  @override
  State<AppExpandableSection> createState() => _AppExpandableSectionState();
}

class _AppExpandableSectionState extends State<AppExpandableSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            color: AppColors.background,
            padding: AppSpacing.p_lg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.labelLarge(
                    color: widget.titleColor ?? AppColors.textPrimary,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: widget.titleColor ?? AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            padding: AppSpacing.cardPadding,
            child: widget.child,
          ),
      ],
    );
  }
}

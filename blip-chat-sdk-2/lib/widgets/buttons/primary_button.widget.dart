import 'package:blip_ds/blip_ds.dart';

import '../../themes/app_theme.model.dart';

class PrimaryButton extends DSButton {
  PrimaryButton({
    super.key,
    super.onPressed,
    super.label,
    super.borderColor,
    super.isEnabled,
    super.isLoading,
    super.leadingIcon,
    super.trailingIcon,
  }) : super(
          backgroundColor: isEnabled
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withOpacity(.4),
          foregroundColor: AppTheme.isPrimaryColorLight
              ? DSColors.neutralDarkCity
              : DSColors.neutralLightSnow,
        );
}

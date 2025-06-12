import 'package:flutter/cupertino.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

class ProfileSettingsSwitch extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ProfileSettingsSwitch({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.getPrimaryColor(context),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: responsiveFontSizes.bodyMedium(context),
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextGreyColor(context),
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppTheme.getPrimaryColor(context),
            inactiveTrackColor: AppTheme.getDetailsGreyColor(context),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

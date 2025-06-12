import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.getBackgroundHeaderColor(context),
      title: Text(
        context.translate('profile.title'),
        style: TextStyle(
          fontSize: responsiveFontSizes.titleHeader(context),
          fontWeight: FontWeight.bold,
          color: AppTheme.white,
        ),
      ),
      leadingWidth: 100,
      automaticallyImplyLeading: false,
      leading: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: AppTheme.white,
            ),
            Text(
              context.translate('profile.back'),
              style: TextStyle(
                fontSize: responsiveFontSizes.backText(context),
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
          ],
        ),
      ),
      expandedHeight: 100,
      pinned: true,
      floating: false,
    );
  }
}

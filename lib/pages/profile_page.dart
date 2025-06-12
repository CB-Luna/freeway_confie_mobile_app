import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/profileactions/profile_avatar_name.dart';
import '../widgets/profileactions/profile_header.dart';
import '../widgets/profileactions/profile_settings_list.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final defaultUserName = context.translate('profile.defaultUser');

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundHeaderColor(context),
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const ProfileHeader(),
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      height: MediaQuery.of(context).size.height -
                          100, // Altura fija considerando el header y margen superior
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 80),
                          Text(
                            user != null ? user.fullName : defaultUserName,
                            style: TextStyle(
                              fontSize:
                                  responsiveFontSizes.titleMedium(context),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getPrimaryColor(context),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Expanded(
                            child: ProfileSettingsList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ProfileAvatarName(
                    userName: user != null ? user.fullName : defaultUserName,
                    showName: false,
                    userAvatar: user?.avatar,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

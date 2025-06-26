import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/profileactions/profile_avatar_name.dart';
import '../widgets/profileactions/profile_header.dart';
import '../widgets/profileactions/profile_settings_list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final savedName = await authProvider.getFullName();

    if (mounted) {
      setState(() {
        _userName = savedName ??
            (authProvider.currentUser?.fullName ??
                context.translate('profile.defaultUser'));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundHeaderColor(context),
      body: CustomScrollView(
        controller: ScrollController(),
        slivers: [
          const ProfileHeader(),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        height: MediaQuery.of(context)
                            .size
                            .height, // Altura fija considerando el header y margen superior
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
                            _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _userName,
                                    style: TextStyle(
                                      fontSize: responsiveFontSizes
                                          .titleMedium(context),
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.getPrimaryColor(context),
                                    ),
                                  ),
                            const SizedBox(height: 16),
                            const ProfileSettingsList(),
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
                      userName: _userName,
                      showName: false,
                      userAvatar: user?.avatar,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:freeway_app/data/constants.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/pages/webview_page.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({super.key});

  @override
  State<AppInfoPage> createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  bool _isLoading = true;
  String _deviceModel = '';
  String _osVersion = '';
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    try {
      // Obtener información de la versión de la app
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;

      // Obtener información del dispositivo
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        _osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceModel = iosInfo.model;
        _osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      }
    } catch (e) {
      _deviceModel = 'Desconocido';
      _osVersion = 'Desconocido';
      _appVersion = 'Desconocido';
      _buildNumber = 'Desconocido';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construir la UI

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundHeaderColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundHeaderColor(context),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        leadingWidth: 56,
        title: Text(
          context.translate('profile.appInfo'),
          style: TextStyle(
            color: AppTheme.white,
            fontSize: responsiveFontSizes.titleMedium(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: LoadingView(
                message: context.translate('common.loading'),
              ),
            )
          : Container(
              color: AppTheme.getBackgroundColor(context),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAppInfoCard(context),
                  const SizedBox(height: 16),
                  _buildDeviceInfoCard(context),
                  const SizedBox(height: 16),
                  _buildLegalInfoCard(context),
                ],
              ),
            ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    // La versión y build number ahora se obtienen automáticamente
    final buildDate = '02/17/2026';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/auth/Freewayfavi2.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                Text(
                  'Freeway Insurance',
                  style: TextStyle(
                    fontSize: responsiveFontSizes.titleSmall(context),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              context.translate('profile.appInfoPage.version'),
              _appVersion,
            ),
            _buildInfoRow(
              context,
              context.translate('profile.appInfoPage.build'),
              _buildNumber,
            ),
            _buildInfoRow(
              context,
              context.translate('profile.appInfoPage.buildDate'),
              buildDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('profile.appInfoPage.deviceInfo'),
              style: TextStyle(
                fontSize: responsiveFontSizes.titleSmall(context),
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              context.translate('profile.appInfoPage.device'),
              _deviceModel,
            ),
            _buildInfoRow(
              context,
              context.translate('profile.appInfoPage.operatingSystem'),
              _osVersion,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('profile.appInfoPage.legalInfo'),
              style: TextStyle(
                fontSize: responsiveFontSizes.titleSmall(context),
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              context.translate('profile.appInfoPage.license'),
              context.translate('profile.appInfoPage.valueLicense'),
            ),
            _buildInfoRow(
              context,
              context.translate('profile.appInfoPage.copyright'),
              '© ${DateTime.now().year} Freeway Insurance',
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navegar a términos de uso usando WebViewPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(
                      url: '${urlBaseEmbed}terms-of-use/',
                      title: context
                          .translate('profile.appInfoPage.termsAndConditions'),
                    ),
                  ),
                );
              },
              child: Text(
                context.translate('profile.appInfoPage.termsAndConditions'),
                style: TextStyle(
                  color: AppTheme.getPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navegar a política de privacidad usando WebViewPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(
                      url: '${urlBaseEmbed}privacy-policy/',
                      title: context
                          .translate('profile.appInfoPage.privacyPolicy'),
                    ),
                  ),
                );
              },
              child: Text(
                context.translate('profile.appInfoPage.privacyPolicy'),
                style: TextStyle(
                  color: AppTheme.getPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (izquierda)
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: responsiveFontSizes.bodyMedium(context),
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextGreyColor(context),
              ),
            ),
          ),
          const SizedBox(width: 8), // Espacio entre label y valor
          // Value (derecha) - Flexible para permitir wrapping
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: responsiveFontSizes.bodyMedium(context),
                fontWeight: FontWeight.w600,
                color: AppTheme.getPrimaryColor(context),
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

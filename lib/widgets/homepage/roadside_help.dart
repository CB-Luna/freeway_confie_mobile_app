import 'package:flutter/material.dart';
import 'package:freeway_app/data/constants.dart';
import 'package:freeway_app/data/services/web_dialog_service.dart';
import 'package:freeway_app/providers/auth_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/common/custom_dialog.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../../pages/webview_page.dart';

class RoadsideHelp extends StatefulWidget {
  const RoadsideHelp({super.key});

  @override
  State<RoadsideHelp> createState() => _RoadsideHelpState();
}

class _RoadsideHelpState extends State<RoadsideHelp>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla para cálculos responsive
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppTheme.getCardColor(context),
      child: InkWell(
        onTap: () async {
          // Verificar si ya se ha mostrado el diálogo anteriormente
          final webDialogService = WebDialogService();
          final hasBeenShown = await webDialogService.hasWebDialogBeenShown();

          bool shouldProceed = true;

          // Solo mostrar el diálogo si no se ha mostrado antes
          if (!hasBeenShown && context.mounted) {
            final result = await CustomDialog.show(
              context: context,
              title: context.translate('home.roadsideHelp.webDialogTitle'),
              message: context.translate('home.roadsideHelp.webDialogMessage'),
              positiveButtonText:
                  context.translate('home.roadsideHelp.visitWebsite'),
              negativeButtonText: context.translate('home.roadsideHelp.cancel'),
            );

            // Marcar el diálogo como mostrado
            await webDialogService.setWebDialogShown();

            shouldProceed = result == true;
          }

          if (shouldProceed && context.mounted) {
            // Obtener información del usuario actual para prellenar formularios
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final user = authProvider.currentUser;

            // Preparar datos del usuario para pasar a los formularios
            final Map<String, String> userData = {
              'firstName': user?.fullName.split(' ').first ?? '',
              'lastName': user?.fullName.split(' ').isNotEmpty == true &&
                      user!.fullName.split(' ').length > 1
                  ? user.fullName.split(' ').skip(1).join(' ')
                  : '',
              'email': user?.email ?? '',
              'phone': user?.phone ?? '',
              'zipCode': user?.zipCode ?? '',
              'city': user?.city ?? '',
              'state': user?.state ?? '',
              'street': user?.street ?? '',
            };

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewPage(
                  url: '${urlBaseEmbedBuyProduct}auto-club/step-1',
                  title: 'Freeway Auto Club',
                  userData: userData,
                  formType: 'auto_club',
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: screenWidth - 48, // Ancho adaptable
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 6, // Dar más espacio al texto
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.translate('home.roadsideHelp.needHelp'),
                      style: TextStyle(
                        fontSize: responsiveFontSizes.bodyMedium(context),
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextGreyColor(context),
                      ),
                      // Eliminamos maxLines y overflow para que el texto se muestre completo
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.translate('home.roadsideHelp.addAutoClub'),
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(context),
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveFontSizes.bodyMedium(context),
                        height: 18 / 14,
                      ),
                      // Eliminamos maxLines y overflow para que el texto se muestre completo
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Contenedor para el botón animado
              Flexible(
                flex: 4, // Dar menos espacio a la imagen
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.getBackgroundColor(context),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/home/icons/truckwhite.png',
                        width: screenWidth * 0.18, // Reducido ligeramente
                        height: screenWidth * 0.07,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8), // Reducido
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.getDetailsGreyColor(context),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

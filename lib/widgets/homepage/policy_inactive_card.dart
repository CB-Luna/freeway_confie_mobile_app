import 'package:flutter/material.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/policy_logo_utils.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/contactcenter/request_call.dart';

import '../../widgets/theme/app_theme.dart';

class PolicyInactiveCard extends StatelessWidget {
  final dynamic user;
  final String policyNumber;
  final PolicyModel? policy;

  const PolicyInactiveCard({
    required this.user,
    required this.policyNumber,
    super.key,
    this.policy,
  });

  @override
  Widget build(BuildContext context) {
    // Usar policyNumber como número de póliza a mostrar
    final String displayNumber = policy?.policyNumber ?? policyNumber;

    // Determinar si tenemos la imagen del logo de la póliza en assets
    final bool freewayLogo =
        policy?.programName.toLowerCase().contains('freeway') ?? false;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppTheme.getCardColor(context),
      child: Container(
        width: MediaQuery.of(context).size.width - 48,
        height: 180,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo - Verificar si existe un logo específico para la póliza
                PolicyLogoUtils.getPolicyLogo(
                  context,
                  policy?.carrierLogoUrl,
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: freewayLogo
                      ? MediaQuery.of(context).size.width * 0.1
                      : MediaQuery.of(context).size.width * 0.05,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${policy?.lineOfBusiness}',
                      style: TextStyle(
                        fontSize: responsiveFontSizes.policyCardTitle(context),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.grey,
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        displayNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize:
                              responsiveFontSizes.policyCardSubtitle(context),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.getRedColor(context).withAlpha(50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cancel,
                        color: AppTheme.getRedColor(context),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Inactive',
                        style: TextStyle(
                          color: AppTheme.getRedColor(context),
                          fontWeight: FontWeight.w500,
                          fontSize: responsiveFontSizes.button(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Botón de renovar póliza
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestCallPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getGreenColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  context.translate('home.policyCard.renewPolicy'),
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: responsiveFontSizes.bodyMedium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

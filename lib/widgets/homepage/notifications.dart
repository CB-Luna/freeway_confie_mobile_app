import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../../locatordevice/presentation/widgets/loading_view.dart';
import '../../providers/notification_provider.dart';
import 'notification_item_content.dart';

class NotificationsWidget extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback? onClose;

  const NotificationsWidget({
    super.key,
    this.isExpanded = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla para cálculos responsivos
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    
    // Calcular alturas responsivas basadas en el tamaño de la pantalla
    final double expandedHeight = screenHeight * 0.5; // 50% de la altura de la pantalla
    final double multiNotificationHeight = isSmallScreen ? 180 : 210;
    final double singleNotificationHeight = isSmallScreen ? 90 : 102;
    
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        debugPrint(
          'NotificationsWidget - Construyendo widget, isLoading: ${notificationProvider.isLoading}',
        );
        debugPrint(
          'NotificationsWidget - Error: ${notificationProvider.errorMessage}',
        );

        if (notificationProvider.isLoading) {
          debugPrint('NotificationsWidget - Mostrando estado de carga');
          return _buildLoadingState(context, screenWidth);
        }

        if (notificationProvider.errorMessage != null) {
          debugPrint(
            'NotificationsWidget - Mostrando error: ${notificationProvider.errorMessage}',
          );
          // Mostrar un mensaje de error discreto
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('home.notifications.title'),
                    style: TextStyle(
                      color: AppTheme.getSubtitleTextColor(context),
                      fontFamily: 'Open Sans',
                      fontSize: isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: screenWidth - (isSmallScreen ? 32 : 48),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: AppTheme.getCardColor(context),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('home.notifications.error'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getRedColor(context),
                              fontSize: isSmallScreen ? 13 : 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.translateWithArgs(
                              'home.notifications.usingDemoData',
                              args: [notificationProvider.errorMessage ?? ''],
                            ),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: AppTheme.getBodyTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        }

        final notifications = notificationProvider.notifications;
        debugPrint(
          'NotificationsWidget - Número de notificaciones: ${notifications.length}',
        );

        if (notifications.isNotEmpty) {
          debugPrint(
            'NotificationsWidget - Primera notificación: ${notifications.first.title}',
          );
        } else {
          debugPrint(
            'NotificationsWidget - No hay notificaciones para mostrar',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Products Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('home.notifications.title'),
                  style: TextStyle(
                    color: AppTheme.getSubtitleTextColor(context),
                    fontFamily: 'Open Sans',
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
            Center(
              child: SizedBox(
                width: screenWidth - (isSmallScreen ? 32 : 48),
                // Ajustar la altura según la cantidad de notificaciones y si está expandida
                height: isExpanded
                    ? expandedHeight // Altura expandida proporcional a la pantalla
                    : notifications.length > 1
                        ? multiNotificationHeight // Altura para 2 o más notificaciones
                        : notifications.length == 1
                            ? singleNotificationHeight // Altura para 1 notificación
                            : singleNotificationHeight, // Altura para estado vacío
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: AppTheme.getCardColor(context),
                  child: notifications.isEmpty
                      ? _buildEmptyState(context, isSmallScreen)
                      : Column(
                          mainAxisAlignment: isExpanded
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            // Botón para cerrar la vista expandida (solo visible cuando está expandida)
                            if (isExpanded && onClose != null)
                              GestureDetector(
                                onTap: onClose,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 25,
                                        color: AppTheme.getDetailsGreyColor(
                                          context,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: isExpanded
                                    ? const AlwaysScrollableScrollPhysics() // Scroll habilitado cuando está expandido
                                    : const NeverScrollableScrollPhysics(), // Scroll deshabilitado cuando no está expandido
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8.0 : 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Column(
                                    children: [
                                      ...List.generate(
                                        notifications.length,
                                        (index) {
                                          final notification = notifications[index];
                                          // Alternar colores: par azul, impar naranja
                                          final bool isBlue = !notification.title
                                              .contains('Welcome');
                                          final Color iconColor = isBlue
                                              ? AppTheme.getBlueColor(context)
                                              : AppTheme.getOrangeColor(context);

                                          return Column(
                                            children: [
                                              Center(
                                                child: _buildNotificationItem(
                                                  notification.policyNumber,
                                                  notification.title,
                                                  notification.location,
                                                  notification.date,
                                                  notification.time,
                                                  iconColor,
                                                  notification.id,
                                                  isBlue,
                                                  screenWidth,
                                                  isSmallScreen,
                                                ),
                                              ),
                                              if (index < notifications.length - 1)
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(
                                                      bottom: 5,
                                                    ),
                                                    child: Container(
                                                      width: isSmallScreen ? 280 : 320,
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            width: 0.5,
                                                            color: AppTheme
                                                                .getDetailsGreyColor(
                                                              context,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 2),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context, double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10.0 : 14.0),
          child: Text(
            context.translate('home.notifications.title'),
            style: TextStyle(
              color: AppTheme.getSubtitleTextColor(context),
              fontFamily: 'Open Sans',
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8.0 : 12.0),
          height: isSmallScreen ? 180 : 200,
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getBoxShadowColor(context),
                blurRadius: 25,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: LoadingView(
              message: context.translate('home.notifications.loading'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSmallScreen) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Text(
          context.translate('home.notifications.empty'),
          style: TextStyle(
            color: AppTheme.grey,
            fontSize: isSmallScreen ? 13 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String policyNumber,
    String title,
    String location,
    String date,
    String time,
    Color iconColor,
    String notificationId,
    bool isBlue,
    double screenWidth,
    bool isSmallScreen,
  ) {
    // Pasar el ancho de la pantalla al widget NotificationItemContent
    return NotificationItemContent(
      key: ValueKey('notification_$notificationId'),
      policyNumber: policyNumber,
      title: title,
      location: location,
      date: date,
      time: time,
      iconColor: iconColor,
      notificationId: notificationId,
      isBlue: isBlue,
      screenWidth: screenWidth,
      isSmallScreen: isSmallScreen,
    );
  }
}

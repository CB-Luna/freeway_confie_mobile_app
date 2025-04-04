import 'package:flutter/material.dart';
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
          return _buildLoadingState(context);
        }

        if (notificationProvider.errorMessage != null) {
          debugPrint(
            'NotificationsWidget - Mostrando error: ${notificationProvider.errorMessage}',
          );
          // Mostrar un mensaje de error discreto
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        color: AppTheme.getSubtitleTextColor(context),
                        fontFamily: 'Open Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 22 / 14,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: AppTheme.getBackgroundRedColor(
                    context,
                  ), // 0.1 de opacidad
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.getBorderRedColor(context),
                  ), // 0.2 de opacidad
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error al cargar notificaciones',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getRedColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Usando datos de ejemplo. Error: ${notificationProvider.errorMessage}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getBodyTextColor(context),
                        ),
                      ),
                    ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      color: AppTheme.getSubtitleTextColor(context),
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 22 / 14,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              // Ajustar la altura según la cantidad de notificaciones y si está expandida
              height: isExpanded
                  ? 330 // Altura expandida
                  : notifications.length > 1
                      ? 205 // Altura para 2 o más notificaciones
                      : notifications.length == 1
                          ? 102 // Altura para 1 notificación
                          : 102, // Altura para estado vacío
              child: notifications.isEmpty
                  ? _buildEmptyState()
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
                                    color:
                                        AppTheme.getDetailsGreyColor(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SingleChildScrollView(
                          physics: isExpanded
                              ? const AlwaysScrollableScrollPhysics() // Scroll habilitado cuando está expandido
                              : const NeverScrollableScrollPhysics(), // Scroll deshabilitado cuando no está expandido
                          child: Column(
                            children: [
                              ...List.generate(
                                notifications.length,
                                (index) {
                                  final notification = notifications[index];
                                  // Alternar colores: par azul, impar naranja
                                  final bool isBlue = index.isEven;
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
                                        ),
                                      ),
                                      if (index < notifications.length - 1)
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 5,
                                            ),
                                            child: Container(
                                              width: 320,
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
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Text(
            'Notifications',
            style: TextStyle(
              color: AppTheme.getSubtitleTextColor(context),
              fontFamily: 'Open Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 22 / 14,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 200,
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
          child: const Center(
            child: LoadingView(message: 'Loading notifications...'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No notifications available',
          style: TextStyle(
            color: AppTheme.grey,
            fontSize: 14,
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
  ) {
    // Usar el widget NotificationItemContent desde el archivo separado
    return NotificationItemContent(
      policyNumber: policyNumber,
      title: title,
      location: location,
      date: date,
      time: time,
      iconColor: iconColor,
      notificationId: notificationId,
      isBlue: isBlue,
    );
  }
}

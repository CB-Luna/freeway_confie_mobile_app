import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsWidget extends StatelessWidget {
  const NotificationsWidget({super.key});

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
          return _buildLoadingState();
        }

        if (notificationProvider.errorMessage != null) {
          debugPrint(
            'NotificationsWidget - Mostrando error: ${notificationProvider.errorMessage}',
          );
          // Mostrar un mensaje de error discreto
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26), // 0.1 de opacidad
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withAlpha(51),
                  ), // 0.2 de opacidad
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error al cargar notificaciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usando datos de ejemplo. Error: ${notificationProvider.errorMessage}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Mostrar notificaciones de ejemplo
              ...notificationProvider.notifications.map(
                (notification) => _buildNotificationCard(context, notification),
              ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  // Contador de notificaciones eliminado
                ],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x0A111111),
                    blurRadius: 25,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              // Limitar la altura y permitir scroll
              height: 200,
              child: notifications.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          ...List.generate(
                            notifications.length,
                            (index) {
                              final notification = notifications[index];
                              // Alternar colores: primera azul, segunda naranja, y así sucesivamente
                              final bool isBlue = index % 2 == 0;
                              final Color iconColor = isBlue
                                  ? const Color(0xFF0047BB)
                                  : const Color(0xFFC74E10);

                              return Column(
                                children: [
                                  _buildNotificationItem(
                                    notification.policyNumber,
                                    notification.title,
                                    notification.location,
                                    notification.date,
                                    notification.time,
                                    iconColor,
                                    notification.id,
                                  ),
                                  if (index < notifications.length - 1)
                                    Center(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 0),
                                        child: Container(
                                          width: 320,
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 0.5,
                                                color: Color(0xFFC4C4C4),
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Center(
                              child: Text(
                                'More',
                                style: TextStyle(
                                  color: Color(0xFF0047BB),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.0),
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              const BoxShadow(
                color: Color(0x0A111111),
                blurRadius: 25,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(),
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
            color: Color(0xFF828282),
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
  ) {
    return Container(
      width: 320,
      height: 70,
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor == const Color(0xFF0047BB)
                  ? const Color(0xFFE6EEFF) // Light blue for blue icon
                  : const Color(0xFFFFF1E9), // Light orange for orange icon
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_outlined,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  policyNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 16 / 12, // line-height: 18px
                    letterSpacing: 0,
                    color: Color(0xFF828282),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 16 / 14, // line-height: 21px
                    letterSpacing: 0,
                    color: iconColor == const Color(0xFF0047BB)
                        ? const Color(0xFF414648)
                        : const Color(0xFFC74E10),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$location | $date | $time',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    height: 16 / 12, // line-height: 18px
                    letterSpacing: 0,
                    color: Color(0xFF414648),
                  ),
                ),
              ],
            ),
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return GestureDetector(
                onTap: () => provider.markAsRead(notificationId),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: notification.isBlue
            ? const Color(0xFFE6F0FF)
            : const Color(0xFFFFF4E6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.isBlue
                    ? const Color(0xFF0047BB)
                    : const Color(0xFFFF6B00),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  notification.isBlue
                      ? Icons.notifications
                      : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.policyNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notification.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// import '../data/services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  // By the moment we are not using the notification service
  // final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get notificationCount => _notifications.length;

  // Método para obtener las notificaciones desde la API
  Future<void> fetchNotifications(String customerId) async {
    debugPrint(
      'NotificationProvider - Iniciando fetchNotifications para customerId: $customerId',
    );

    if (customerId.isEmpty) {
      debugPrint(
        'NotificationProvider - ADVERTENCIA: customerId inválido: $customerId',
      );
      _errorMessage = null;
      _notifications = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint(
        'NotificationProvider - Llamando al servicio para obtener notificaciones',
      );
      // Enviamos un customerId valido y de ejemplo
      _notifications = [];
      debugPrint(
        'NotificationProvider - Notificaciones obtenidas: ${_notifications.length}',
      );

      if (_notifications.isNotEmpty) {
        debugPrint(
          'NotificationProvider - Primera notificación: ID=${_notifications.first.id}, Título=${_notifications.first.title}',
        );
      } else {
        debugPrint('NotificationProvider - No se encontraron notificaciones');
      }
    } catch (e) {
      _errorMessage = null;
      debugPrint(
        'NotificationProvider - Error al obtener notificaciones: $_errorMessage',
      );

      // Usar datos de ejemplo en caso de error
      debugPrint(
        'NotificationProvider - Usando datos de ejemplo como fallback',
      );
      _notifications = [];
      debugPrint(
        'NotificationProvider - Datos de ejemplo cargados: ${_notifications.length} notificaciones',
      );
    } finally {
      _isLoading = false;
      debugPrint(
        'NotificationProvider - Finalizando fetchNotifications, notificando a los listeners',
      );
      notifyListeners();
    }
  }

  // Método para marcar una notificación como leída (simulado)
  void markAsRead(String notificationId) {
    debugPrint(
      'NotificationProvider - Marcando como leída la notificación: $notificationId',
    );

    // Verificar si la notificación existe antes de eliminarla
    final notificationIndex = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );

    if (notificationIndex == -1) {
      debugPrint(
        'NotificationProvider - No se encontró la notificación con ID: $notificationId',
      );
      return;
    }

    // Aquí se implementaría la lógica para marcar como leída en la API
    // Por ahora, solo eliminamos la notificación de la lista local
    final previousCount = _notifications.length;

    // Crear una nueva lista sin la notificación que queremos eliminar
    final updatedNotifications = List<NotificationModel>.from(_notifications);
    updatedNotifications.removeAt(notificationIndex);

    // Actualizar la lista de notificaciones
    _notifications = updatedNotifications;

    debugPrint(
      'NotificationProvider - Notificaciones restantes: ${_notifications.length} (eliminadas: ${previousCount - _notifications.length})',
    );

    // Notificar a los listeners después de actualizar la lista
    notifyListeners();
  }
}

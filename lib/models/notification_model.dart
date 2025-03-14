import 'package:flutter/foundation.dart';

class NotificationModel {
  final String id;
  final String policyNumber;
  final String title;
  final String location;
  final String date;
  final String time;
  final bool isBlue; // true para azul, false para naranja

  NotificationModel({
    required this.id,
    required this.policyNumber,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.isBlue,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    debugPrint('NotificationModel - Procesando JSON: $json');
    
    // Extraer fecha y hora de la fecha completa si está disponible
    String date = '';
    String time = '';
    
    if (json.containsKey('created_at') && json['created_at'] != null) {
      debugPrint('NotificationModel - Procesando created_at: ${json['created_at']}');
      try {
        final String createdAt = json['created_at'];
        // Formato esperado: "2025-10-25 16:44:00"
        final parts = createdAt.split(' ');
        if (parts.length >= 2) {
          final dateParts = parts[0].split('-');
          final timeParts = parts[1].split(':');
          
          if (dateParts.length >= 3 && timeParts.length >= 2) {
            final year = int.tryParse(dateParts[0]) ?? 2025;
            final month = int.tryParse(dateParts[1]) ?? 1;
            final day = int.tryParse(dateParts[2]) ?? 1;
            final hour = int.tryParse(timeParts[0]) ?? 0;
            final minute = int.tryParse(timeParts[1]) ?? 0;
            
            date = '$day ${_getMonthName(month)}, $year';
            time = '$hour:${minute.toString().padLeft(2, '0')}${hour >= 12 ? 'pm' : 'am'}';
            debugPrint('NotificationModel - Fecha parseada: $date, Hora: $time');
          }
        }
      } catch (e) {
        debugPrint('NotificationModel - Error al parsear fecha: $e');
        date = json['date'] ?? '';
        time = json['time'] ?? '';
      }
    } else if (json.containsKey('timestamp') && json['timestamp'] != null) {
      debugPrint('NotificationModel - Procesando timestamp: ${json['timestamp']}');
      try {
        final DateTime dateTime = DateTime.parse(json['timestamp']);
        date = '${dateTime.day} ${_getMonthName(dateTime.month)}, ${dateTime.year}';
        time = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}${dateTime.hour >= 12 ? 'pm' : 'am'}';
        debugPrint('NotificationModel - Fecha parseada: $date, Hora: $time');
      } catch (e) {
        debugPrint('NotificationModel - Error al parsear fecha: $e');
        date = json['date'] ?? '';
        time = json['time'] ?? '';
      }
    } else {
      debugPrint('NotificationModel - No se encontró fecha en el JSON');
      date = json['date'] ?? '';
      time = json['time'] ?? '';
    }

    // Mapear campos del API a nuestro modelo
    String id = '';
    if (json.containsKey('notification_id')) {
      id = json['notification_id']?.toString() ?? '';
      debugPrint('NotificationModel - Usando notification_id: $id');
    } else if (json.containsKey('id')) {
      id = json['id']?.toString() ?? '';
      debugPrint('NotificationModel - Usando id: $id');
    } else {
      id = DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint('NotificationModel - No se encontró ID, generando uno: $id');
    }
    
    String policyNumber = '';
    if (json.containsKey('notification_custom_id')) {
      policyNumber = json['notification_custom_id'] ?? '';
      debugPrint('NotificationModel - Usando notification_custom_id: $policyNumber');
    } else if (json.containsKey('policy_number')) {
      policyNumber = json['policy_number'] ?? '';
      debugPrint('NotificationModel - Usando policy_number: $policyNumber');
    } else if (json.containsKey('policy_id')) {
      policyNumber = json['policy_id']?.toString() ?? '';
      debugPrint('NotificationModel - Usando policy_id: $policyNumber');
    } else {
      policyNumber = 'N/A';
      debugPrint('NotificationModel - No se encontró número de póliza');
    }
    
    String title = '';
    if (json.containsKey('subject')) {
      title = json['subject'] ?? '';
      debugPrint('NotificationModel - Usando subject: $title');
    } else if (json.containsKey('title')) {
      title = json['title'] ?? '';
      debugPrint('NotificationModel - Usando title: $title');
    } else if (json.containsKey('message')) {
      title = json['message'] ?? '';
      debugPrint('NotificationModel - Usando message: $title');
    } else {
      title = 'Notification';
      debugPrint('NotificationModel - No se encontró título');
    }
    
    // Construir la ubicación a partir de ciudad y estado
    String location = '';
    if (json.containsKey('city') && json['city'] != null) {
      location = json['city'];
      if (json.containsKey('state_abbreviation') && json['state_abbreviation'] != null) {
        location += ' ${json['state_abbreviation']}';
      } else if (json.containsKey('state') && json['state'] != null) {
        location += ' ${json['state']}';
      }
      debugPrint('NotificationModel - Ubicación construida: $location');
    } else if (json.containsKey('location')) {
      location = json['location'] ?? '';
      debugPrint('NotificationModel - Usando location: $location');
    } else {
      location = 'Unknown';
      debugPrint('NotificationModel - No se encontró ubicación');
    }
    
    // Determinar el color basado en el tipo de notificación
    bool isBlue = true; // Por defecto, usar azul
    if (json.containsKey('notification_type_id')) {
      // Basado en el tipo de notificación
      isBlue = json['notification_type_id'] == 2; // Asumimos que tipo 2 es azul, otros son naranja
      debugPrint('NotificationModel - Color basado en notification_type_id: $isBlue');
    } else if (json.containsKey('type')) {
      isBlue = json['type'] == 'blue' || json['type'] == 'info';
      debugPrint('NotificationModel - Color basado en type: $isBlue');
    } else if (json.containsKey('priority')) {
      isBlue = json['priority'] == 'low';
      debugPrint('NotificationModel - Color basado en priority: $isBlue');
    } else {
      debugPrint('NotificationModel - No se encontró información de color, usando azul por defecto');
    }
    
    debugPrint('NotificationModel - Creando notificación: ID=$id, Policy=$policyNumber, Title=$title, Location=$location, IsBlue=$isBlue');

    return NotificationModel(
      id: id,
      policyNumber: policyNumber,
      title: title,
      location: location,
      date: date,
      time: time,
      isBlue: isBlue,
    );
  }

  // Método auxiliar para convertir número de mes a nombre
  static String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  // Método para crear notificaciones de ejemplo para pruebas
  static List<NotificationModel> getDummyNotifications() {
    return [
      NotificationModel(
        id: '1',
        policyNumber: 'LA0029030117',
        title: 'Your Policy is active',
        location: 'San Diego Ca.',
        date: '25 Oct, 2024',
        time: '16:44pm',
        isBlue: true,
      ),
      NotificationModel(
        id: '2',
        policyNumber: 'LA0029030117',
        title: 'Your Policy is active',
        location: 'Los Angeles Ca.',
        date: '29 Sep, 2024',
        time: '16:44pm',
        isBlue: false,
      ),
      NotificationModel(
        id: '3',
        policyNumber: 'LA0029030117',
        title: 'Payment Received',
        location: 'San Francisco Ca.',
        date: '15 Oct, 2024',
        time: '10:30am',
        isBlue: true,
      ),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

/// Widget con estado para manejar la animación de eliminación de notificaciones
class NotificationItemContent extends StatefulWidget {
  final String policyNumber;
  final String title;
  final String location;
  final String date;
  final String time;
  final Color iconColor;
  final String notificationId;
  final bool isBlue;
  
  const NotificationItemContent({
    Key? key,
    required this.policyNumber,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.iconColor,
    required this.notificationId,
    required this.isBlue,
  }) : super(key: key);
  
  @override
  NotificationItemContentState createState() => NotificationItemContentState();
}

class NotificationItemContentState extends State<NotificationItemContent> {
  bool isDeleting = false;
  double progressValue = 0.0;
  
  // Función para iniciar la animación de eliminación
  void startDeleteAnimation() {
    setState(() {
      isDeleting = true;
    });
    
    // Animar el progreso de 0 a 1 durante 3 segundos
    const animationDuration = Duration(seconds: 3);
    final startTime = DateTime.now();
    
    // Función para actualizar el progreso
    void updateProgress() {
      if (!mounted) return; // Verificar si el widget aún está montado
      
      final elapsedTime = DateTime.now().difference(startTime);
      final newProgressValue = elapsedTime.inMilliseconds / animationDuration.inMilliseconds;
      
      if (newProgressValue >= 1.0) {
        // Animación completa, eliminar la notificación
        Provider.of<NotificationProvider>(context, listen: false)
            .markAsRead(widget.notificationId);
      } else {
        // Actualizar el progreso y programar la siguiente actualización
        setState(() {
          progressValue = newProgressValue;
        });
        Future.delayed(const Duration(milliseconds: 16), updateProgress);
      }
    }
    
    // Iniciar la actualización del progreso
    updateProgress();
  }
      
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Contenido principal
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Círculo de color con icono (similar al estilo de ElegantNotification)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.isBlue
                          ? const Color(0xFFE6EEFF)
                          : const Color(0xFFFFF1E9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.chat_outlined,
                        color: widget.iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Contenido principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Número de póliza
                        Text(
                          widget.policyNumber,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 16 / 12,
                            letterSpacing: 0,
                            color: Color(0xFF828282),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Título
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 16 / 14,
                            letterSpacing: 0,
                            color: widget.isBlue
                                ? const Color(0xFF414648)
                                : const Color(0xFFC74E10),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Detalles (ubicación, fecha, hora)
                        Text(
                          '${widget.location} | ${widget.date} | ${widget.time}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            height: 16 / 12,
                            letterSpacing: 0,
                            color: Color(0xFF414648),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón para marcar como leída
                  GestureDetector(
                    onTap: isDeleting ? null : startDeleteAnimation,
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
                  ),
                ],
              ),
            ),
            
            // Indicador de progreso (visible solo durante la eliminación)
            if (isDeleting)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isBlue ? const Color(0xFF0047BB) : const Color(0xFFC74E10),
                  ),
                  minHeight: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: require_trailing_commas

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class IdCardPrinter {
  /// Captura un widget como imagen
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // Increased pixelRatio for higher quality image capture
      final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      debugPrint('Error al capturar la imagen: $e');
    }
    return null;
  }

  /// Genera un PDF a partir de una imagen
  static Future<Uint8List> generatePdf(Map<String, String> translations,
      Uint8List imageBytes, User user, PolicyModel policy,
      {required BuildContext context}) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    final textScale = MediaQuery.of(context).textScaler;

    // Calculate optimal size for the ID card image
    // Using a larger portion of the A4 page width (500-600px is about 70-80% of A4 width)
    final cardWidth = textScale.scale(1) > 1.5 ? 1000.0 : 600.0;
    // Calculate height to maintain aspect ratio (original was 350x220 = 1.59:1)
    final cardHeight = cardWidth / 1.59;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  translations['pdfTitle'] ?? 'Freeway Insurance ID Card',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 30),
                // Larger image size for better visibility
                pw.Image(image, width: cardWidth, height: cardHeight),
                pw.SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Imprime la tarjeta de ID
  static Future<void> printIdCard(
    BuildContext context,
    GlobalKey key,
    User user,
    PolicyModel policy,
    Function(bool) onComplete,
  ) async {
    try {
      // Capturar la imagen de la tarjeta
      final imageBytes = await captureWidget(key);
      if (imageBytes == null) {
        throw Exception('No se pudo capturar la imagen de la tarjeta');
      }
      if (!context.mounted) return;
      // Obtener las traducciones necesarias
      final translations = {
        'pdfTitle': context.translate('idCard.pdfTitle'),
      };

      // Generar el PDF
      final pdfBytes = await generatePdf(translations, imageBytes, user, policy,
          context: context);

      // Mostrar el diálogo de impresión
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Freeway_ID_Card_${policy.policyNumber}',
        // Personalizar opciones según la plataforma
        dynamicLayout: true,
        usePrinterSettings: true,
      );

      onComplete(true);
    } catch (e) {
      debugPrint('Error al imprimir: $e');
      onComplete(false);
    }
  }

  /// Guarda la tarjeta de ID como PDF o imagen según el formato solicitado
  static Future<void> saveIdCard(
    BuildContext context,
    GlobalKey key,
    User user,
    PolicyModel policy,
    Function(bool) onComplete,
    {bool asImage = false}
  ) async {
    try {
      if (asImage) {
        // Guardar como imagen
        await saveIdCardAsImage(context, key, policy, onComplete);
      } else {
        // Guardar como PDF (comportamiento original)
        // Capturar la imagen de la tarjeta
        final imageBytes = await captureWidget(key);
        if (imageBytes == null) {
          throw Exception('No se pudo capturar la imagen de la tarjeta');
        }
        if (!context.mounted) return;

        // Obtener las traducciones necesarias
        final translations = {
          'pdfTitle': context.translate('idCard.pdfTitle'),
        };

        // Generar el PDF
        final pdfBytes = await generatePdf(translations, imageBytes, user, policy,
            context: context);

        // Guardar el PDF
        final result = await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'Freeway_ID_Card_${policy.policyNumber}.pdf',
        );

        onComplete(result);
      }
    } catch (e) {
      debugPrint('Error al guardar: $e');
      onComplete(false);
    }
  }

  /// Guarda la tarjeta de ID como imagen
  static Future<void> saveIdCardAsImage(
    BuildContext context,
    GlobalKey key,
    PolicyModel policy,
    Function(bool) onComplete,
  ) async {
    try {
      // Capturar la imagen de la tarjeta
      final imageBytes = await captureWidget(key);
      if (imageBytes == null) {
        throw Exception('No se pudo capturar la imagen de la tarjeta');
      }
      if (!context.mounted) return;

      // Usar la biblioteca printing para compartir la imagen
      // Aunque la biblioteca está diseñada para PDFs, podemos usarla para compartir cualquier tipo de bytes
      // El sistema operativo determinará cómo manejar el archivo basado en su extensión
      final result = await Printing.sharePdf(
        bytes: imageBytes,
        filename: 'Freeway_ID_Card_${policy.policyNumber}.png',
      );

      onComplete(result);
    } catch (e) {
      debugPrint('Error al guardar imagen: $e');
      onComplete(false);
    }
  }
}

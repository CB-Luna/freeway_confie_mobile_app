import 'package:flutter/material.dart';

class AppTheme {
  // Método para obtener colores según el tema
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3B82F6) // Azul más claro para modo oscuro
        : const Color(0xFF0047CC); // Azul original para modo claro
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E5D9B) // Azul más oscuro para modo oscuro
        : const Color(0xFF0A557A); // Color original para modo claro
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF131826) // Azul muy oscuro para modo oscuro
        : const Color(0xFFf3f3f9); // Color original para modo claro
  }

  static Color getBackgroundHeaderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF38455D) // Azul muy oscuro para modo oscuro
        : const Color(0xFF0047CC); // Azul original para modo claro
  }

  static Color getTextGreyColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFABB2BF) // Gris más claro para modo oscuro
        : const Color(0xFF6B7280); // Color original para modo claro
  }

  static Color getDetailsGreyColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFABB2BF) // Gris más claro para modo oscuro
        : const Color(0xFF6B7280); // Color original para modo claro
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF38455D) // Azul oscuro para tarjetas en modo oscuro
        : Colors.white; // Blanco para tarjetas en modo claro
  }

  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF0A4DA2); // Color azul para iconos en modo claro
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3B82F6)
            .withValues(alpha: 0.5) // Azul con opacidad para modo oscuro
        : Colors.grey; // Gris para modo claro
  }

  static Color getBrightnessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue.withAlpha(51)
        : Colors.grey.withAlpha(26);
  }

  static Color getIconToogleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.yellow[600]!
        : Colors.blue[900]!;
  }

  static Color getTitleTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getIndicatorCurrentIndexCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3B82F6)
        : const Color(0xFF0047BB);
  }

  static Color getIndicatorIndexCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black.withAlpha(13);
  }

  static Color getBlueColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3B82F6) // Azul más claro para modo oscuro
        : const Color(0xFF0047CC); // Azul original para modo claro
  }

  static Color getOrangeColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFf8A454)
        : const Color(0xFFC84C14);
  }

  static Color getGreenColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF68A424)
        : const Color(0xFF78BE00);
  }

  static Color getRedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red
        : Colors.redAccent;
  }

  static Color getYellowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.yellow
        : Colors.yellowAccent;
  }

  static Color getBackgroundGreenColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green[50]!
        : Colors.green[100]!;
  }

  static Color getBackgroundBlueColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue[50]!
        : Colors.blue[100]!;
  }

  static Color getBackgroundOrangeColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange[50]!
        : Colors.orange[100]!;
  }

  static Color getBackgroundRedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red[50]!
        : Colors.red[100]!;
  }

  static Color getBorderRedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.withAlpha(200)
        : Colors.red.withAlpha(50);
  }

  static Color getSubtitleTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey
        : const Color(0xFF414648);
  }

  static Color getBoxShadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0x0FFFFFFF)
        : const Color(0x0F000000);
  }

  static Color getBodyTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF414648)
        : const Color(0xFF6B7280);
  }

  static String getFreewayLogoType(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'assets/auth/freeway_logo_white.png'
        : 'assets/auth/freeway_logo.png';
  }

  // Colores constantes para compatibilidad con código existente
  static const Color primaryColor = Color(0xFF0047CC);
  static const Color secondaryColor = Color(0xFF0A557A);
  static const Color tertiaryColor = Color(0xFFC84C14);
  static const Color backgroundColor = Color(0xFFf3f3f9);
  static const Color backgroundGreenColor = Color(0xFFF7FFF2);
  static const Color backgroundBlueColor = Color(0xFFEFF6FF);
  static const Color backgroundOrangeColor = Color(0xFFFFF0DF);
  static const Color textGreyColor = Color(0xFF6B7280);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;

  // Text Styles dinámicos
  static TextStyle getTitleStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 22,
      height: 1.0,
      letterSpacing: 0,
      color: getPrimaryColor(context),
    );
  }

  static TextStyle getButtonTextStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 22 / 18,
      letterSpacing: 0,
      color: white,
    );
  }

  static TextStyle getLinkTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: getPrimaryColor(context),
    );
  }

  static TextStyle getGreyTextStyle(BuildContext context) {
    return TextStyle(
      color: getTextGreyColor(context),
      fontSize: 14,
    );
  }

  // Text Styles constantes para compatibilidad con código existente
  static const TextStyle titleStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 1.0,
    letterSpacing: 0,
    color: primaryColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 22 / 18,
    letterSpacing: 0,
    color: white,
  );

  static const TextStyle linkTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: primaryColor,
  );

  static const TextStyle greyTextStyle = TextStyle(
    color: textGreyColor,
    fontSize: 14,
  );

  // Input Decoration dinámico
  static InputDecoration getInputDecoration(
    BuildContext context, {
    required String labelText,
  }) {
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: getBorderColor(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: getBorderColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: getPrimaryColor(context)),
      ),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF162544) // Color oscuro para el fondo del input
          : white,
    );
  }

  // Input Decoration constante para compatibilidad con código existente
  static InputDecoration inputDecoration(BuildContext context,
      // ignore: require_trailing_commas
      {required String labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: getTitleTextColor(context)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: getDetailsGreyColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: getPrimaryColor(context)),
      ),
      filled: true,
      fillColor: AppTheme.getCardColor(context),
      errorMaxLines: 3, // Permitir hasta 3 líneas para mensajes de error
      errorStyle: TextStyle(
        color: Colors.red[700],
        fontSize: 12.0,
        height: 1.2, // Espaciado de línea más compacto
      ),
      helperMaxLines: 3, // Permitir hasta 3 líneas para mensajes de ayuda
      helperStyle: TextStyle(
        color: getTextGreyColor(context),
        fontSize: 11.0,
        height: 1.2, // Espaciado de línea más compacto
      ),
    );
  }

  // Button Style dinámico
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: getPrimaryColor(context),
      foregroundColor: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
      minimumSize: const Size(double.infinity, 50),
    );
  }

  // Button Style constante para compatibilidad con código existente
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.getPrimaryColor(context),
      foregroundColor: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
      minimumSize: const Size(double.infinity, 50),
    );
  }
}

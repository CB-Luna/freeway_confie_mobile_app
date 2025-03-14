import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

/// Widget that displays a logout button for the profile screen
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          debugPrint(
              'ProfileLogoutButton - Button pressed, showing confirmation modal',);
          _showLogoutConfirmation(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de salida
            Icon(
              Icons.logout,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            // Texto de salida
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a modern confirmation modal before logging out
  void _showLogoutConfirmation(BuildContext context) {
    debugPrint('ProfileLogoutButton - Showing logout confirmation modal');

    // Show the modern modal bottom sheet
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withAlpha(128), // 0.5 opacity converted to alpha
      builder: (BuildContext modalContext) {
        return Material(
          color: Colors.transparent,
          child: Container(
            height: 340, // Aumentado de 320 a 340 para evitar el overflow
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar at the top
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Content with animation
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          24.0, 12.0, 24.0, 24.0,), // Ajustado el padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Warning icon with animation
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withAlpha(
                                  26,), // 0.1 opacity converted to alpha
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Color(0xFF4CAF50),
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Message
                          const Text(
                            'Are You sure want to Log Out?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Buttons
                          Row(
                            children: [
                              // Cancel button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    debugPrint(
                                        'ProfileLogoutButton - Cancel button pressed',);
                                    Navigator.of(modalContext).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.grey[700],
                                    side: BorderSide(color: Colors.grey[300]!),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12,), // Reducido de 14 a 12
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Logout button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    debugPrint(
                                        'ProfileLogoutButton - Log out button pressed',);
                                    // Close the modal first
                                    Navigator.of(modalContext).pop();

                                    // Execute logout
                                    _logout(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12,), // Reducido de 14 a 12
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Log Out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Executes the logout process
  void _logout(BuildContext context) {
    try {
      debugPrint('ProfileLogoutButton - Starting logout process');

      // Get the provider and clear authentication state
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.logout();

      debugPrint('ProfileLogoutButton - Authentication state cleared');

      // Navigate directly to the login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      debugPrint('Error executing logout from ProfileLogoutButton: $e');

      // Show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There was a problem logging out. Please try again.'),
          backgroundColor: Colors.green,
        ),
      );

      // Alternative navigation attempt
      try {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      } catch (navError) {
        debugPrint('Error in alternative navigation: $navError');
      }
    }
  }
}

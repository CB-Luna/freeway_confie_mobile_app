import 'package:flutter/material.dart';

import '../../utils/menu/circle_nav_bar.dart';

class RequestCallPage extends StatefulWidget {
  const RequestCallPage({super.key});

  @override
  State<RequestCallPage> createState() => _RequestCallPageState();
}

class _RequestCallPageState extends State<RequestCallPage> {
  int _selectedIndex = 0;

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Insurance
        Navigator.pushReplacementNamed(context, '/id_card');
        break;
      case 2: // Rewards
        Navigator.pushReplacementNamed(context, '/submit_claim');
        break;
      case 3: // Location
        // TODO: Implementar navegación a la página de ubicación
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0047BB),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Título
              const Center(
                child: Text(
                  'Help',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Contenedor blanco principal
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Have questions or need assistance?\nWe're here to help!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF414648),
                            fontSize: 16,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Image.asset(
                          'assets/home/icons/contactagent.png',
                          width: 227.12,
                          height: 120,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Customer Service',
                        style: TextStyle(
                          color: Color(0xFF414648),
                          fontSize: 16,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Aquí irá la lógica para llamar al servicio al cliente
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0047BB),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_in_talk,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Call (888) 443-4662',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Insurance Quotes & Service',
                        style: TextStyle(
                          color: Color(0xFF414648),
                          fontSize: 16,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Aquí irá la lógica para llamar a cotizaciones
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008DB9),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_in_talk,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Call (877) 753-7823',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: CircleNavBar(
              selectedPos: _selectedIndex,
              onTap: _handleNavigation,
              tabItems: [
                TabData(Icons.home_outlined, 'Home'),
                TabData(Icons.verified_user_outlined, 'Insurance'),
                TabData(Icons.card_giftcard_outlined, 'Rewards'),
                TabData(Icons.location_on_outlined, 'Location'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

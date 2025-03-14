import 'package:flutter/material.dart';
import 'package:freeway_app/models/car_info.dart';
import 'package:freeway_app/pages/home_page.dart';
import 'package:freeway_app/utils/menu/circle_nav_bar.dart';

import 'auto_insurance_page.dart';
import 'car_selection_card.dart';
import 'options_cover_page.dart';

class CarSelectionPage extends StatefulWidget {
  const CarSelectionPage({super.key});

  @override
  State<CarSelectionPage> createState() => _CarSelectionPageState();
}

class _CarSelectionPageState extends State<CarSelectionPage> {
  String? selectedVin;
  int _selectedNavIndex = 1;

  void _handleCarSelection(String vin) {
    setState(() {
      // Si el VIN seleccionado es el mismo que ya está seleccionado,
      // volvemos al estado por defecto (ningún carro seleccionado)
      if (selectedVin == vin) {
        selectedVin = null; // Esto desactiva Continue y activa Add New Car
      } else {
        selectedVin = vin;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Aseguramos que empezamos sin selección
    selectedVin = null;
  }

  final List<TabData> _navItems = [
    TabData(Icons.home_outlined, 'Home'),
    TabData(Icons.verified_user_outlined, '+Add Insurance'),
    TabData(Icons.location_on_outlined, 'Location'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCFF),
      bottomNavigationBar: Transform.translate(
        offset: const Offset(0, -8),
        child: CircleNavBar(
          tabItems: _navItems,
          selectedPos: _selectedNavIndex,
          onTap: (index) {
            setState(() {
              _selectedNavIndex = index;
            });
            if (index == 0) {
              // Home
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            }
          },
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FCFF),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF0046B9),
                  size: 20,
                ),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF0046B9),
                    fontSize: 16,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        leadingWidth: 100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/products/vehiclepng/4.0x/auto.png',
                    width: 40,
                    height: 40,
                    color: const Color(0xFF0046B9),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Let's get started",
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0046B9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Select the car',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0046B9),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'you will use for this quote',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CarSelectionCard(
                car: const CarInfo(
                  year: '2024',
                  make: 'Ford',
                  model: 'Mustang',
                  vin: 'FTG1234NJ',
                ),
                isSelected: selectedVin == 'FTG1234NJ',
                onSelect: () => _handleCarSelection('FTG1234NJ'),
                onEdit: () {
                  // Implementar edición
                },
                onRemove: () {
                  // Implementar eliminación
                },
              ),
              const SizedBox(height: 8),
              CarSelectionCard(
                car: const CarInfo(
                  year: '2020',
                  make: 'Toyota',
                  model: 'TACOMA',
                  vin: 'TOYOTA123',
                ),
                isSelected: selectedVin == 'TOYOTA123',
                onSelect: () => _handleCarSelection('TOYOTA123'),
                onEdit: () {
                  // Implementar edición
                },
                onRemove: () {
                  // Implementar eliminación
                },
              ),
              const SizedBox(height: 16),
              // Botón Add New Car
              Center(
                child: SizedBox(
                  width: 248,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: selectedVin == null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AutoInsurancePage(
                                  initialMenuIndex: 1,
                                ), // Mantener +Add Insurance seleccionado
                              ),
                            );
                          }
                        : null, // Desactivar cuando hay un carro seleccionado
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedVin == null
                          ? const Color(
                              0xFFF76707,
                            ) // Naranja cuando no hay selección
                          : Colors.grey[200], // Gris cuando hay selección
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                      disabledBackgroundColor: Colors.grey[200],
                      disabledForegroundColor: Colors.grey,
                    ),
                    child: Text(
                      'Add New Car',
                      style: TextStyle(
                        color: selectedVin == null ? Colors.white : Colors.grey,
                        fontSize: 16,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w700, // Bold
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Botón Continue
              Center(
                child: SizedBox(
                  width: 248,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: selectedVin != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OptionsCoverPage(),
                              ),
                            );
                          }
                        : null, // Desactivar cuando no hay carro seleccionado
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF76707),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                      disabledBackgroundColor: Colors
                          .grey[300], // Color de fondo cuando está desactivado
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: selectedVin != null ? Colors.white : Colors.grey,
                        fontSize: 16,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w700, // Bold
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

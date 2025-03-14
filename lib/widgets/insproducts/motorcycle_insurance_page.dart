import 'package:flutter/material.dart';
import '../../utils/menu/circle_nav_bar.dart';
import 'policy_header_section.dart';

class MotorcycleInsurancePage extends StatefulWidget {
  const MotorcycleInsurancePage({super.key});

  @override
  State<MotorcycleInsurancePage> createState() =>
      _MotorcycleInsurancePageState();
}

class _MotorcycleInsurancePageState extends State<MotorcycleInsurancePage> {
  _MotorcycleInsurancePageState();

  int _selectedIndex = 0;

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // My Products
        Navigator.pushNamed(context, '/home');
        break;
      case 1: // + Add Insurance
        Navigator.pushNamed(context, '/add-insurance');
        break;
      case 2: // Location
        Navigator.pushNamed(context, '/location');
        break;
    }
  }

  String? driverLicenseStatus;
  String? yearsOfExperience;
  String? motorcycleYear;
  bool? validLicense;
  bool? requiresSR22;
  bool? completedTraining;

  Map<String, String> _personalDetails = {
    'Name': 'John Espinoza',
    'Email': 'jespinoza@gmail.com',
    'Phone': '123-456-7890',
    'Address': 'Los Angeles CA 90010',
  };

  @override
  Widget build(BuildContext context) {
    final List<TabData> tabs = [
      TabData(Icons.home_outlined, 'My Products'),
      TabData(Icons.verified_user_outlined, '+ Add Insurance'),
      TabData(Icons.location_on_outlined, 'Location'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5FCFF),
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
          padding: const EdgeInsets.fromLTRB(15, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/products/vehiclepng/4.0x/motorcycle.png',
                      width: 40,
                      height: 40,
                      color: const Color(0xFF0046B9),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Center(
                    child: Text(
                      'Motorcycle Insurance',
                      style: TextStyle(
                        color: Color(0xFF0046B9),
                        fontSize: 20,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PolicyHeaderSection(
                title: 'Personal Details',
                fields: _personalDetails,
                onFieldsChanged: (newFields) {
                  setState(() {
                    _personalDetails = newFields;
                  });
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Motorcycle Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0046B9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMotorcycleDetails(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: CircleNavBar(
          tabItems: tabs,
          selectedPos: _selectedIndex,
          onTap: (index) => _handleNavigation(index),
        ),
      ),
    );
  }

  Widget _buildMotorcycleDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Driver's license status",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: driverLicenseStatus,
                    decoration: const InputDecoration(
                      hintText: 'Select',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items:
                        ['Valid', 'Suspended', 'Expired'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        driverLicenseStatus = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Years of experience',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: yearsOfExperience,
                    decoration: const InputDecoration(
                      hintText: 'Select',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: ['0-1', '1-3', '3-5', '5+'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        yearsOfExperience = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildYesNoQuestion(
          'Valid Motorcycle license/endorsement?',
          validLicense,
          (value) => setState(() => validLicense = value),
        ),
        const SizedBox(height: 8),
        _buildYesNoQuestion(
          'Does driver require an SR-22 filing?',
          requiresSR22,
          (value) => setState(() => requiresSR22 = value),
        ),
        const SizedBox(height: 8),
        _buildYesNoQuestion(
          'Has driver completed a driver training or improvement course in the last 3 years?',
          completedTraining,
          (value) => setState(() => completedTraining = value),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Motorcycle Year',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: motorcycleYear,
              decoration: const InputDecoration(
                hintText: 'Select',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: List.generate(
                      11, (index) => (DateTime.now().year - index).toString(),)
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  motorcycleYear = newValue;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYesNoQuestion(
    String question,
    bool? value,
    void Function(bool?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF0046B9),
              ),
              const Text('Yes'),
              const SizedBox(width: 8),
              Radio<bool>(
                value: false,
                groupValue: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF0046B9),
              ),
              const Text('No'),
            ],
          ),
        ],
      ),
    );
  }
}

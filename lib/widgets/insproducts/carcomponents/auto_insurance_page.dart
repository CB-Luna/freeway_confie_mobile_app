import 'package:flutter/material.dart';
// Remove this import
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:freeway_app/utils/menu/circle_nav_bar.dart';
import 'package:freeway_app/widgets/insproducts/policy_header_section.dart';

class AutoInsurancePage extends StatefulWidget {
  final int initialMenuIndex;

  const AutoInsurancePage({
    super.key,
    this.initialMenuIndex = 1, // Por defecto selecciona +Add Insurance
  });

  @override
  State<AutoInsurancePage> createState() => _AutoInsurancePageState();
}

class _AutoInsurancePageState extends State<AutoInsurancePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialMenuIndex;
  }

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
          padding: const EdgeInsets.fromLTRB(15, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/products/vehiclepng/4.0x/auto.png',
                      width: 40,
                      height: 40,
                      color: const Color(0xFF0046B9),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Center(
                    child: Text(
                      'Auto Insurance',
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
              const SizedBox(height: 24),
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
                      'Auto Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0046B9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
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
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: driverLicenseStatus,
                                decoration: const InputDecoration(
                                  hintText: 'Select',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12,),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'valid', child: Text('Valid'),),
                                  DropdownMenuItem(
                                      value: 'expired', child: Text('Expired'),),
                                  DropdownMenuItem(
                                      value: 'suspended',
                                      child: Text('Suspended'),),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    driverLicenseStatus = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Years of driving experience',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: yearsOfExperience,
                                decoration: const InputDecoration(
                                  hintText: 'Select',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12,),
                                ),
                                items: List.generate(30, (index) {
                                  return DropdownMenuItem(
                                    value: (index + 1).toString(),
                                    child: Text(
                                        '${index + 1} ${index == 0 ? 'year' : 'years'}',),
                                  );
                                }),
                                onChanged: (value) {
                                  setState(() {
                                    yearsOfExperience = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Valid Auto license/endorsement?',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: validLicense,
                          onChanged: (value) {
                            setState(() {
                              validLicense = value;
                            });
                          },
                          activeColor: const Color(0xFF0046B9),
                        ),
                        const Text('Yes'),
                        const SizedBox(width: 24),
                        Radio<bool>(
                          value: false,
                          groupValue: validLicense,
                          onChanged: (value) {
                            setState(() {
                              validLicense = value;
                            });
                          },
                          activeColor: const Color(0xFF0046B9),
                        ),
                        const Text('No'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Does driver require an SR-22 filing?',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: requiresSR22,
                          onChanged: (value) {
                            setState(() {
                              requiresSR22 = value;
                            });
                          },
                          activeColor: const Color(0xFF0046B9),
                        ),
                        const Text('Yes'),
                        const SizedBox(width: 24),
                        Radio<bool>(
                          value: false,
                          groupValue: requiresSR22,
                          onChanged: (value) {
                            setState(() {
                              requiresSR22 = value;
                            });
                          },
                          activeColor: const Color(0xFF0046B9),
                        ),
                        const Text('No'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Has driver completed a driver training or improvement course in the last 3 years?',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: completedTraining,
                          onChanged: (value) {
                            setState(() {
                              completedTraining = value;
                            });
                          },
                          activeColor: const Color(0xFF0046B9),
                        ),
                        const Text('Yes'),
                        const SizedBox(width: 24),
                        Radio<bool>(
                          value: false,
                          groupValue: completedTraining,
                          onChanged: (value) {
                            setState(() {
                              completedTraining = value;
                            });
                          },
                          activeColor: const Color(0xFF0046B9),
                        ),
                        const Text('No'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: motorcycleYear,
                      decoration: const InputDecoration(
                        labelText: 'Auto Year',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: List.generate(30, (index) {
                        final year = DateTime.now().year - index;
                        return DropdownMenuItem(
                          value: year.toString(),
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          motorcycleYear = value;
                        });
                      },
                    ),
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
}

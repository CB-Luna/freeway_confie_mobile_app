import 'package:flutter/material.dart';
import 'package:freeway_app/utils/menu/circle_nav_bar.dart';

class IdCardPage extends StatefulWidget {
  const IdCardPage({super.key});

  @override
  State<IdCardPage> createState() => _IdCardPageState();
}

class _IdCardPageState extends State<IdCardPage> {
  int _selectedIndex = -1;

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // My Products
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Add Insurance
        // TODO: Navigate to Add Insurance
        break;
      case 2: // Location
        // TODO: Navigate to Location
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0047BB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047BB),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        leadingWidth: 56,
        title: const Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ID Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              child: Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF5FCFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 3),
              blurRadius: 8,
              spreadRadius: -1,
              color: Color(0x0D323247), // 0D is 13% opacity
            ),
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 1,
              spreadRadius: 0,
              color: Color(0x3D0C1A4B), // 3D is 24% opacity
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 30,
                    left: 70,
                    child: Image.asset(
                      'assets/home/idcardicons/add_apple_wallet.png',
                      width: 146,
                      height: 45,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 50,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download_outlined,
                              color: Color(0xFF0047BB),),
                          onPressed: () {
                            // TODO: Implement download functionality
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.print_outlined,
                              color: Color(0xFF0047BB),),
                          onPressed: () {
                            // TODO: Implement print functionality
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 95,
                    left: (MediaQuery.of(context).size.width - 309) / 2,
                    child: Container(
                      width: 309,
                      height: 394,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/home/idcardicons/card_id.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top:
                        504, // 95 (card top) + 394 (card height) + 15 (spacing)
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'This is not proof of coverage (Legal to provide final text)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CircleNavBar(
              selectedPos: _selectedIndex,
              onTap: _handleNavigation,
              tabItems: [
                TabData(Icons.home_outlined, 'My Products'),
                TabData(Icons.verified_user_outlined, '+ Add Insurance'),
                TabData(Icons.location_on_outlined, 'Location'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

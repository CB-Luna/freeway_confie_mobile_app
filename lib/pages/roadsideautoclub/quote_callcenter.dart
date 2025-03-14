import 'package:flutter/material.dart';
import 'package:freeway_app/utils/menu/circle_nav_bar.dart';

class QuoteCallcenter extends StatefulWidget {
  final String phoneNumber;
  final String insuranceType;
  final VoidCallback? onBackPressed;

  const QuoteCallcenter({
    required this.insuranceType, super.key,
    this.phoneNumber = '123-456-7890',
    this.onBackPressed,
  });

  @override
  State<QuoteCallcenter> createState() => _QuoteCallcenterState();
}

class _QuoteCallcenterState extends State<QuoteCallcenter> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FCFF),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Título con ícono de auto
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/products/vehiclepng/4.0x/auto.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Auto Insurance',
                    style: TextStyle(
                      color: Color(0xFF0046B9),
                      fontSize: 20,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Representante imagen
                      Center(
                        child: Image.asset(
                          'assets/home/banners/insurance4.0x/contactcenter.png',
                          width: 227,
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Texto informativo
                      const Text(
                        "Here's what happens next:",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Información de contacto
                      const Text(
                        'A representative will be contacting you shortly at this number:',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Open Sans',
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Número de teléfono
                      _isEditing
                          ? _buildPhoneEditField()
                          : Text(
                              _phoneController.text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                      const SizedBox(height: 24),

                      // Pregunta de confirmación
                      const Text(
                        'Is this correct?',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Instrucción para editar
                      const Text(
                        'If not please provide the correct phone number.',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Open Sans',
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Botón de editar
                      _buildEditButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: CircleNavBar(
          tabItems: [
            TabData(Icons.home_outlined, 'My Products'),
            TabData(Icons.verified_user_outlined, '+Add Insurance'),
            TabData(Icons.location_on_outlined, 'Location'),
          ],
          selectedPos: 1,
          onTap: (index) {
            if (index == 0) {
              // Home button
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home', (route) => false);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPhoneEditField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        hintText: 'Enter phone number',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(
        fontSize: 16,
        fontFamily: 'Open Sans',
      ),
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          if (_isEditing) {
            // Guardar cambios
            _isEditing = false;
          } else {
            // Entrar en modo edición
            _isEditing = true;
          }
        });
      },
      icon: Icon(
        _isEditing ? Icons.check : Icons.edit,
        color: Colors.white,
        size: 18,
      ),
      label: Text(
        _isEditing ? 'Save' : 'Edit phone number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

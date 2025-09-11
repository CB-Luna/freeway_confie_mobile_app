import 'package:acceptance_app/locatordevice/locator_device_module.dart';
import 'package:acceptance_app/pages/home_page.dart';
import 'package:acceptance_app/utils/app_localizations_extension.dart';
import 'package:acceptance_app/utils/menu/circle_nav_bar.dart';
import 'package:acceptance_app/widgets/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuoteCallcenter extends StatefulWidget {
  final String phoneNumber;
  final String insuranceType;
  final VoidCallback? onBackPressed;

  const QuoteCallcenter({
    required this.insuranceType,
    super.key,
    this.phoneNumber = '123-456-7890',
    this.onBackPressed,
  });

  @override
  State<QuoteCallcenter> createState() => _QuoteCallcenterState();
}

class _QuoteCallcenterState extends State<QuoteCallcenter> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isEditing = false;
  int _selectedIndex = 1; // Inicializado en 1 para 'Add Insurance'

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
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  color: AppTheme.getIconColor(context),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Positioned(
              left: 0,
              child: Text(
                context.translate('quoteCallcenter.back'),
                style: TextStyle(
                  color: AppTheme.getIconColor(context),
                  fontSize: 18,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        leadingWidth: 56,
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
                  Text(
                    context.translate('quoteCallcenter.autoInsurance'),
                    style: TextStyle(
                      color: AppTheme.getPrimaryColor(context),
                      fontSize: 20,
                      fontFamily: 'Lato',
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
                      Text(
                        context.translate('quoteCallcenter.whatsNext'),
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTitleTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Información de contacto
                      Text(
                        context.translate('quoteCallcenter.representative'),
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Lato',
                          color: AppTheme.getTitleTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Número de teléfono
                      _isEditing
                          ? _buildPhoneEditField()
                          : Text(
                              _phoneController.text,
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getSubtitleTextColor(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                      const SizedBox(height: 24),

                      // Pregunta de confirmación
                      Text(
                        context.translate('quoteCallcenter.isCorrect'),
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTitleTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Instrucción para editar
                      Text(
                        context.translate('quoteCallcenter.provideCorrect'),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lato',
                          color: AppTheme.getSubtitleTextColor(context),
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
      bottomNavigationBar: CircleNavBar(
        selectedPos: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0: // My Products
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 2: // Location
              LocatorDeviceModule.navigateToLocationView(context);
              break;
          }
        },
        tabItems: [
          TabData(
            Icons.home_outlined,
            context.translate('home.navigation.myProducts'),
          ),
          TabData(
            Icons.verified_user_outlined,
            context.translate('home.navigation.addInsurance'),
          ),
          TabData(
            Icons.location_on_outlined,
            context.translate('home.navigation.location'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneEditField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: context.translate('quoteCallcenter.enterPhoneNumber'),
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(
        fontSize: 16,
        fontFamily: 'Lato',
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
        color: AppTheme.white,
        size: 18,
      ),
      label: Text(
        _isEditing
            ? context.translate('quoteCallcenter.save')
            : context.translate('quoteCallcenter.editPhoneNumber'),
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 14,
          fontFamily: 'Lato',
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.getGreenColor(context),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

enum SearchType {
  policyNumber,
  phoneNumber,
}

class PaymentSearchDialog extends StatefulWidget {
  final String? initialZipCode;
  final Function(String, SearchType) onContinue;

  const PaymentSearchDialog({
    required this.onContinue,
    super.key,
    this.initialZipCode,
  });

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    String? initialZipCode,
  }) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final initialSize = keyboardHeight > 0 ? 0.6 : 0.5;

        return DraggableScrollableSheet(
          initialChildSize: initialSize,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return PaymentSearchDialog(
              initialZipCode: initialZipCode,
              onContinue: (zipCode, searchType) {
                FocusScope.of(context).unfocus();
                Navigator.pop(context, {
                  'zipCode': zipCode,
                  'searchType': searchType,
                });
              },
            );
          },
        );
      },
    );
  }

  @override
  State<PaymentSearchDialog> createState() => _PaymentSearchDialogState();
}

class _PaymentSearchDialogState extends State<PaymentSearchDialog> {
  late TextEditingController _zipCodeController;
  bool _isZipCodeValid = false;
  SearchType _selectedSearchType = SearchType.policyNumber;

  @override
  void initState() {
    super.initState();
    _zipCodeController =
        TextEditingController(text: widget.initialZipCode ?? '');
    _validateZipCode(_zipCodeController.text);
    _zipCodeController.addListener(() {
      _validateZipCode(_zipCodeController.text);
    });
  }

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }

  void _validateZipCode(String value) {
    setState(() {
      _isZipCodeValid = value.length == 5 && RegExp(r'^\d{5}$').hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.0,
            20.0,
            20.0,
            isKeyboardVisible ? keyboardHeight + 20.0 : 20.0,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de arrastre
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.getDetailsGreyColor(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Título
                Text(
                  context.translate('payment.search.title'),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTitleTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Subtítulo
                Text(
                  context.translate('payment.search.subtitle'),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 14,
                    color: AppTheme.getSubtitleTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Opciones de búsqueda
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.getDetailsGreyColor(context),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Opción de búsqueda por número de póliza
                      RadioListTile<SearchType>(
                        title: Text(
                          context.translate('payment.search.byPolicyNumber'),
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getTitleTextColor(context),
                          ),
                        ),
                        value: SearchType.policyNumber,
                        groupValue: _selectedSearchType,
                        activeColor: AppTheme.getPrimaryColor(context),
                        onChanged: (SearchType? value) {
                          if (value != null) {
                            setState(() {
                              _selectedSearchType = value;
                            });
                          }
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppTheme.getDetailsGreyColor(context),
                      ),
                      // Opción de búsqueda por número de teléfono
                      RadioListTile<SearchType>(
                        title: Text(
                          context.translate('payment.search.byPhoneNumber'),
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getTitleTextColor(context),
                          ),
                        ),
                        value: SearchType.phoneNumber,
                        groupValue: _selectedSearchType,
                        activeColor: AppTheme.getPrimaryColor(context),
                        onChanged: (SearchType? value) {
                          if (value != null) {
                            setState(() {
                              _selectedSearchType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Campo de entrada de ZipCode
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _zipCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: InputDecoration(
                      labelText:
                          context.translate('payment.search.zipCodeHint'),
                      border: InputBorder.none,
                      counterText: '',
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          color: AppTheme.getDetailsGreyColor(context),
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(height: isKeyboardVisible ? 40 : 30),

                // Botón de continuar
                ElevatedButton(
                  onPressed: _isZipCodeValid
                      ? () => widget.onContinue(
                            _zipCodeController.text,
                            _selectedSearchType,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getPrimaryColor(context),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: AppTheme.getPrimaryColor(context)
                        .withValues(alpha: 0.5),
                  ),
                  child: Text(
                    context.translate('payment.search.continueButton'),
                    style: const TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                ),

                SizedBox(height: isKeyboardVisible ? 20 : 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

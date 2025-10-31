import 'package:acceptance_app/utils/app_localizations_extension.dart';
import 'package:acceptance_app/utils/responsive_font_sizes.dart';
import 'package:acceptance_app/widgets/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TwoFactorDialog extends StatefulWidget {
  final Function(String) onCodeSubmitted;

  const TwoFactorDialog({
    required this.onCodeSubmitted,
    super.key,
  });

  static Future<String?> show({
    required BuildContext context,
  }) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? code;
        return TwoFactorDialog(
          onCodeSubmitted: (submittedCode) {
            code = submittedCode;
            Navigator.pop(context, code);
          },
        );
      },
    );
  }

  @override
  State<TwoFactorDialog> createState() => _TwoFactorDialogState();
}

class _TwoFactorDialogState extends State<TwoFactorDialog> {
  final _codeController = TextEditingController();
  bool _isCodeValid = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() {
      _validateCode(_codeController.text);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _validateCode(String value) {
    // Validar que el código tenga 6 dígitos
    setState(() {
      _isCodeValid = value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Column(
        children: [
          Icon(
            Icons.security,
            size: 48,
            color: AppTheme.getPrimaryColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            context.translate('auth.twoFactorTitle'),
            style: TextStyle(
              fontSize: responsiveFontSizes.titleMedium(context),
              fontWeight: FontWeight.bold,
              color: AppTheme.getTitleTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.translate('auth.twoFactorMessage'),
            style: TextStyle(
              fontSize: responsiveFontSizes.bodyMedium(context),
              color: AppTheme.getSubtitleTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsiveFontSizes.titleLarge(context),
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: '000000',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.getDetailsGreyColor(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.getPrimaryColor(context),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.getDetailsGreyColor(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.translate('auth.twoFactorHint'),
            style: TextStyle(
              fontSize: responsiveFontSizes.bodySmall(context),
              color: AppTheme.getTextGreyColor(context),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text(
            context.translate('common.cancel'),
            style: TextStyle(
              fontSize: responsiveFontSizes.bodyMedium(context),
              color: AppTheme.getTextGreyColor(context),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isCodeValid
              ? () => widget.onCodeSubmitted(_codeController.text)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isCodeValid ? AppTheme.getPrimaryColor(context) : Colors.grey,
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            context.translate('auth.verify'),
            style: TextStyle(
              fontSize: responsiveFontSizes.bodyMedium(context),
              fontWeight: FontWeight.bold,
              color: _isCodeValid ? AppTheme.white : Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

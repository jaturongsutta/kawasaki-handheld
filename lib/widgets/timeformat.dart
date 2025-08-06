import 'package:flutter/services.dart';

class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';

    if (digitsOnly.length >= 3) {
      formatted =
          '${digitsOnly.substring(0, 2)}:${digitsOnly.substring(2, digitsOnly.length.clamp(3, 4))}';
    } else if (digitsOnly.length >= 1) {
      formatted = digitsOnly;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

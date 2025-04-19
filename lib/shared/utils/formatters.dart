import 'package:flutter/services.dart';

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length > 11) return oldValue;

    if (digitsOnly.length == 11 && digitsOnly[2] != '9') {
      return oldValue;
    }

    final finalValue = StringBuffer();
    var substrIndex = 0;

    if (digitsOnly.isNotEmpty) {
      finalValue.write('(');
    }

    if (digitsOnly.length >= 3) {
      finalValue.write('${digitsOnly.substring(0, substrIndex = 2)}) ');
    }

    if (digitsOnly.length == 11) {
      if (digitsOnly.length >= 8) {
        finalValue.write('${digitsOnly.substring(2, substrIndex = 7)}-');
      }
    } else {
      if (digitsOnly.length >= 7) {
        finalValue.write('${digitsOnly.substring(2, substrIndex = 6)}-');
      }
    }

    if (digitsOnly.length > substrIndex) {
      finalValue.write(digitsOnly.substring(substrIndex));
    }

    final formattedText = finalValue.toString();

    // Clamp cursor to the valid range
    final cursorPosition = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: cursorPosition.clamp(0, formattedText.length),
      ),
    );
  }
}

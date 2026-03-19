import 'package:intl/intl.dart';

extension CleanString on String {
  String clean() {
    final withNoAccents = _removeDiacritics(this);
    return withNoAccents.toUpperCase();
  }

  String _removeDiacritics(String str) {
    const withDiacritics = 'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ';
    const withoutDiacritics = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

    return str.split('').map((char) {
      final index = withDiacritics.indexOf(char);
      return index != -1 ? withoutDiacritics[index] : char;
    }).join();
  }
}

extension PhoneNumberFormatter on String {
  String formatAsPhoneNumber() {
    final digitsOnly = replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length == 10) {
      // Format: (XXX) XXX-XXXX
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    }
    if (digitsOnly.length == 11) {
      // Format: (XX) XXXXX-XXXX
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
    }
    return this;
  }
}

extension StringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;
}

extension DateExtension on DateTime? {
  String get toStringFixed {
    if (this == null) {
      return '';
    }

    final format = DateFormat('dd/MM/yyyy');
    return format.format(this!);
  }
}

extension CurrencyStringExtension on String {
  String get toCurrencyFixed {
    return replaceAll('.', '').replaceAll(',', '.');
  }
}

extension DoubleExtension on double? {
  String get toCurrencyFixed {
    if (this == null) {
      return '0,00';
    }
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(this!);
  }
}

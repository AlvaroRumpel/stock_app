abstract interface class Validation {
  final String message;

  Validation({required this.message});

  String? validate(String? value);
}

class Required extends Validation {
  Required({super.message = 'Campo obrigatório'});

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return message;
    }

    return null;
  }
}

class Email extends Validation {
  Email({super.message = 'E-mail inválido'});

  @override
  String? validate(String? value) {
    if (value != null &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return message;
    }

    return null;
  }
}

class Password extends Validation {
  Password({super.message = 'Senha inválida'});

  @override
  String? validate(String? value) {
    if (value == null) {
      return message;
    }

    // Verifica se a senha tem pelo menos 8 caracteres
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }

    // Verifica a presença de pelo menos uma letra minúscula
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra minúscula.';
    }

    // Verifica a presença de pelo menos uma letra maiúscula
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula.';
    }

    // Verifica a presença de pelo menos um dígito
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'A senha deve conter pelo menos um dígito.';
    }

    // Verifica a presença de pelo menos um caractere especial
    if (!RegExp(r'(?=.*[^\da-zA-Z])').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial.';
    }

    return null;
  }
}

class Custom extends Validation {
  Custom({required this.validation}) : super(message: '');

  String? Function(String?) validation;

  @override
  String? validate(String? value) {
    return validation(value);
  }
}

extension Validate on List<Validation> {
  String? validate(String? value) {
    var errors = <String?>[];
    for (var validation in this) {
      errors.add(validation.validate(value));
    }

    return errors.firstWhere((element) => element != null, orElse: () => null);
  }
}

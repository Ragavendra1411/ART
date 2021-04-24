
abstract class Validator {
  bool isValid(String value);
}

class NonEmptyStringValidator implements Validator {
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class EmailValidator implements Validator {
  @override
  bool isValid(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

}

class FieldValidators {
  final Validator emailValidator = EmailValidator();
  final String errorTextEmail = 'Invalid email';

  final Validator stringValidator = NonEmptyStringValidator();
  final String errorTextString = 'Text can\'t be empty';
}
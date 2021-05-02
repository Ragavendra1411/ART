import 'package:share_market/app_commons/constants.dart';
import 'package:share_market/app/services/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SMTextField extends StatefulWidget with FieldValidators {
  final BuildContext context;
  final FocusNode nextFocusNode;
  final FocusNode currentFocusNode;
  final String title;
  final TextEditingController controller;
  final String formDataMapKey;
  final bool keyboardTypeDone;
  final bool isEmailField;
  final bool isNumberKeyboard;
  final bool isMandatoryField;
  final Map<String, dynamic> formData;
  final int maxLines;
  final bool isPaddingNeeded;
  final bool defaultTextFieldWidth;

  SMTextField({
    @required this.context,
    @required this.nextFocusNode,
    @required this.currentFocusNode,
    @required this.title,
    @required this.controller,
    @required this.formDataMapKey,
    @required this.keyboardTypeDone,
    @required this.isEmailField,
    @required this.isNumberKeyboard,
    @required this.isMandatoryField,
    @required this.formData,
    @required this.maxLines,
    @required this.isPaddingNeeded,
    @required this.defaultTextFieldWidth,
  });
  @override
  _SMTextFieldState createState() => _SMTextFieldState(
        context: context,
        nextFocusNode: nextFocusNode,
        currentFocusNode: currentFocusNode,
        title: title,
        controller: controller,
        formDataMapKey: formDataMapKey,
        keyboardTypeDone: keyboardTypeDone,
        isEmailField: isEmailField,
        isNumberKeyboard: isNumberKeyboard,
        isMandatoryField: isMandatoryField,
        formData: formData,
        maxLines: maxLines,
        isPaddingNeeded: isPaddingNeeded,
    defaultTextFieldWidth: defaultTextFieldWidth,
      );
}

class _SMTextFieldState extends State<SMTextField> {
  final BuildContext context;
  final FocusNode nextFocusNode;
  final FocusNode currentFocusNode;
  final String title;
  final TextEditingController controller;
  final String formDataMapKey;
  final bool keyboardTypeDone;
  final bool isEmailField;
  final bool isNumberKeyboard;
  final bool isMandatoryField;
  final Map<String, dynamic> formData;
  final int maxLines;
  final bool isPaddingNeeded;
  final bool defaultTextFieldWidth;

  _SMTextFieldState({
    @required this.context,
    @required this.nextFocusNode,
    @required this.currentFocusNode,
    @required this.title,
    @required this.controller,
    @required this.formDataMapKey,
    @required this.keyboardTypeDone,
    @required this.isEmailField,
    @required this.isNumberKeyboard,
    @required this.isMandatoryField,
    @required this.formData,
    @required this.maxLines,
    @required this.isPaddingNeeded,
    @required this.defaultTextFieldWidth,
  });

  /// Method to bring the focus to a given node
  void _fieldFocusChange(FocusNode nextNode) {
    FocusScope.of(context).requestFocus(nextNode);
  }
   bool _passwordVisible = true;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 5.0),
      width: defaultTextFieldWidth?SM_FIELD_WIDTH:double.infinity,
      child: Theme(
        data: new ThemeData(
          primaryColor: SM_ORANGE,
          hintColor: SM_BORDER_GREY,
          fontFamily: 'OpenSans',
        ),
        child: TextFormField(
          ///Giving different keyboard for different fields
          keyboardType: isNumberKeyboard ? TextInputType.phone : null,
          maxLines: maxLines,
          focusNode: currentFocusNode,
          style: TextStyle(
            color: SM_BLACK,
          ),
          cursorColor: cursorColour,
          controller: controller,
          inputFormatters: title == 'Project Value' || title == 'Revenue'
              ? [
            new FilteringTextInputFormatter.allow(
                RegExp("[\$0-9KkMmBbTt,.]")),
          ]:null,
          maxLength: title == null ? 20000:null,
          ///Changing focus
          onEditingComplete: () => keyboardTypeDone
              ? FocusScope.of(context).unfocus()
              : _fieldFocusChange(nextFocusNode),
              obscureText: title == "Password"?_obscureText:false,
          decoration: new InputDecoration(
            alignLabelWithHint: true,
            contentPadding:
                isPaddingNeeded ? null : EdgeInsets.fromLTRB(10.0, title == null? 25:0, 5.0, 0.0),
            labelText: title,
            labelStyle: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w300,
            ),
            fillColor: Colors.transparent,
            filled: true,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: SM_ORANGE,
            )),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: SM_ORANGE,
            )),
            
            suffixIcon: title=="Password"?
                   IconButton(
                      icon: Icon(
                        /// Based on passwordVisible state choose the icon
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: SM_GREY,
                      ),
                      onPressed: () {
                        /// Toggle the state of passwordVisible variable
                        setState(() {
                          _obscureText = !_obscureText;
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    )
                  : null,
          ),
          textInputAction:
              keyboardTypeDone ? TextInputAction.done : TextInputAction.next,
          onChanged: (value) {
            setState(() {
              if (formData != null) {
                formData[formDataMapKey] = value;
              }
            });
          },
          validator: (value) {
            ///For mandatory fields
            if (isMandatoryField) {
              if (value.isEmpty) {
                return "$title field cannot be empty";
              } else {
                return null;
              }
            }

            ///For Email fields
            if (isEmailField) {
              if (widget.emailValidator.isValid(value) || controller.text.isEmpty) {
                return null;
              } else {
                return widget.errorTextEmail;
              }
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }
}

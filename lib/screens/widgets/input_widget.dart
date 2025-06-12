import 'package:flutter/material.dart';
import 'package:p_chat/global_content/app_color.dart';
import 'package:p_chat/screens/widgets/text_widget.dart';

class TextInputPassword extends StatefulWidget {
  final TextEditingController textInput;
  final String hintText;
  final Color inputColor, borderColor;
  final TextInputType textType;
  final VoidCallback onPress;
  final bool isVisible;
  final Icon icon;
  final FocusNode fieldFocusNode;
  final String? Function(String?)? validate;

  const TextInputPassword({
    super.key,
    required this.textInput,
    required this.hintText,
    required this.inputColor,
    required this.borderColor,
    required this.textType,
    required this.onPress,
    required this.isVisible,
    required this.icon,
    required this.fieldFocusNode,
    this.validate,
  });

  @override
  _TextInputPasswordState createState() => _TextInputPasswordState();
}

class _TextInputPasswordState extends State<TextInputPassword> {
  @override
  Widget build(BuildContext context) {
    var textStyle = AppText.textStyle(FontWeight.w400,
        fontSize: FontSize.font14, color: AppColor.colorBlack);
    var hintTextStyle = AppText.textStyle(FontWeight.w400,
        fontSize: FontSize.font14, color: AppColor.colorBlack);
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: widget.textInput,
        keyboardType: widget.textType,
        style: textStyle,
        focusNode: widget.fieldFocusNode,
        obscureText: widget.isVisible,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: hintTextStyle,
          suffixIcon: IconButton(
            icon: widget.icon,
            color: AppColor.colorLightGray,
            onPressed: widget.onPress,
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColor.colorLightGray, width: 1.2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColor.colorLightGray, width: 1.2)),
        ),
        validator: widget.validate,
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  final TextEditingController textInput;
  final String hintText;
  final Color inputColor, borderColor;
  final TextInputType textType;
  final String? Function(String?)? validate;
  final bool enabled;

  const TextInput({
    super.key,
    required this.textInput,
    required this.hintText,
    required this.inputColor,
    required this.borderColor,
    required this.textType,
    required this.validate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    var textStyle = AppText.textStyle(FontWeight.w400,
        fontSize: FontSize.font14, color: AppColor.colorBlack);
    var hintTextStyle = AppText.textStyle(FontWeight.w400,
        fontSize: FontSize.font14, color: AppColor.colorLightGray);

    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: textInput,
        focusNode: FocusNode(),
        keyboardType: textType,
        style: textStyle,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintTextStyle,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColor.colorLightGray, width: 1.2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColor.colorLightGray, width: 1.2)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: AppColor.colorLightGray.withOpacity(0.5), width: 1.2)),
        ),
        validator: validate,
      ),
    );
  }
}

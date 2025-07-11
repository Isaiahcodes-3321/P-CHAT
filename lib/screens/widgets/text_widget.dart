import 'package:flutter/material.dart';

class FontSize {
  static double font50 = 55;
  static double font38 = 38;
  static double font20 = 20;
  static double font18 = 18;
  static double font16 = 16;
  static double font14 = 14;
  static double font12 = 12.5;
}

class AppText {
  static String familyFont = 'Inter-VariableFont_opsz,wght.ttf';

  static Text boldText(String text, FontWeight fontWeight,
      {double? fontSize,
      Color color = const Color.fromARGB(255, 12, 12, 12),
      int maxLine = 1}) {
    return Text(
      text,
      maxLines: maxLine,
      style: TextStyle(
        color: color,
        fontFamily: familyFont,
        fontWeight: fontWeight,
        fontSize: fontSize ?? FontSize.font20,
      ),
    );
  }

  static Text mediumText(String text, FontWeight fontWeight,
      {double? fontSize, Color color = const Color.fromARGB(255, 12, 12, 12)}) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: familyFont,
        fontWeight: fontWeight,
        fontSize: fontSize ?? FontSize.font16,
      ),
    );
  }

  static TextStyle textStyle(FontWeight fontWeight,
      {double? fontSize, Color color = const Color.fromARGB(255, 12, 12, 12)}) {
    return TextStyle(
      color: color,
      fontFamily: familyFont,
      fontWeight: fontWeight,
      fontSize: fontSize ?? FontSize.font16,
    );
  }
}

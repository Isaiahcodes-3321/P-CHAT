import 'package:flutter/material.dart';

Widget materialButton({
  required Widget widget,
  required Color buttonBkColor,
  required VoidCallback onPres,
  double borderRadiusSize = 15.0,
  double? width,
  double? height,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: MaterialButton(
      onPressed: onPres,
      color: buttonBkColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusSize),
      ),
      child: Center(child: widget),
    ),
  );
}

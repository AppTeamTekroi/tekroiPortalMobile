import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonBS extends StatelessWidget {
  final String title;
  final String? buttonText;
  final double? height;
  final double? width;
  final double? padding;
  final double? separatePrefixIcon;
  final double? separateSuffixIcon;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;
  final VoidCallback? onPressed;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final double? prefixIconSize;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final double? suffixIconSize;
  const ButtonBS({
    Key? key,
    required this.title,
    this.buttonText,
    this.height,
    this.width,
    this.padding,
    this.separatePrefixIcon,
    this.separateSuffixIcon,
    this.fontSize,
    this.fontWeight,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.onPressed,
    this.borderRadius = 0,
    this.prefixIcon,
    this.prefixIconColor,
    this.prefixIconSize,
    this.suffixIcon,
    this.suffixIconColor,
    this.suffixIconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        padding: EdgeInsets.all(padding??0),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor ?? Colors.transparent)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              prefixIcon,
              size: prefixIconSize,
              color: prefixIconColor,
            ),
            SizedBox(
              width: separatePrefixIcon,
            ),
            //suffix icons

            Text(
              title,
              style: TextStyle(color: textColor, fontSize: fontSize, fontWeight: fontWeight),
            ),
            SizedBox(
              width: separateSuffixIcon,
            ),
            //suffix icons

            Icon(
              suffixIcon,
              size: suffixIconSize,
              color: suffixIconColor,
            )
          ],
        ),
      ),
    );
  }
}




//custom button
class CustomButton extends StatelessWidget {
  final String title;
  final Widget? buttonText;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onPressed;
  EdgeInsetsGeometry? innerPadding;

  CustomButton({
    Key? key,
    required this.title,
    this.buttonText,
    this.height,
    this.width,
    this.backgroundColor,
    this.onPressed,
    this.borderRadius = 0,
    this.innerPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: innerPadding ?? const EdgeInsets.all(0),
                child: buttonText),
          ],
        ),
      ),
    );
  }

}


class Commonbuttons {

static Widget getGradinetButton
(
String title,double height, double width, {Color color = Colors.blue} ) {
return Container(
padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
margin: EdgeInsets.only(top: 10),
width: width,
height: height,
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [color, color],
begin: Alignment.bottomLeft,
end: Alignment.topRight,
),
//color: Color(0xffFF701C),
borderRadius: BorderRadius.all(Radius.circular(20)),
),
child: Center(
child: Text(
title,
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
),
),
);
}



}
// ignore_for_file: file_names, prefer_const_constructors

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:dmit/integrations/utils/common.dart';
import 'package:android/main.dart';

import 'AppColors.dart';
import 'AppConstant.dart';

// import 'clusteringGoogleMaps/lat_lang_geohash.dart';

Widget text(
    String text, {
      var fontSize = textSizeLargeMedium,
      Color? textColor,
      var fontFamily,
      var isCentered = false,
      var maxLine = 1,
      var latterSpacing = 0.5,
      bool textAllCaps = false,
      var isLongText = false,
      bool lineThrough = false,
    }) {
  return Text(
    textAllCaps ? text.toUpperCase() : text,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontFamily: fontFamily ?? null,
      fontSize: fontSize,
      color: textColor,
      height: 1.5,
      letterSpacing: latterSpacing,
      decoration:
      lineThrough ? TextDecoration.lineThrough : TextDecoration.none,
    ),
  );
}

BoxDecoration boxDecoration(
    {double radius = 2,
      Color color = Colors.transparent,
      Color? bgColor,
      var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow
        ? defaultBoxShadow(
      shadowColor: shadowColorGlobal,
      blurRadius: 0.5,
    )
        : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

void changeStatusColor(Color color) async {
  setStatusBarColor(color);
  /*try {
    await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground(color));
  } on Exception catch (e) {
    print(e);
  }*/
}

// Widget commonCacheImageWidget(String url, double height,
//     {double? width, BoxFit? fit}) {
//   if (url.validate().startsWith('http')) {
//     if (isMobile) {
//       return CachedNetworkImage(
//         placeholder: placeholderWidgetFn(),
//         imageUrl: '$url',
//         height: height,
//         width: width,
//         fit: fit,
//       );
//     } else {
//       return Image.network(url, height: height, width: width, fit: fit);
//     }
//   } else {
//     return Image.asset(url, height: height, width: width, fit: fit);
//   }
// }

Widget appBarTitleWidget(context, String title, {Color? color}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 60,
    color: color,
    child: Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: W_500,
              fontFamily: fontRegular,
              color: TextColorPrimary,
              fontSize: textSizeNormal,
            ),
            maxLines: 1,
          ),
        ),
      ],
    ),
  );
}

Widget appBar(BuildContext context, String title,
    {List<Widget>? actions,
      bool showBack = true,
      Color? color,
      Color? iconColor}) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: color ?? app_Background,
    leading: showBack
        ? IconButton(
      onPressed: () {
        finish(context);
      },
      icon: Icon(Icons.arrow_back, color: iconColor ?? null),
    )
        : null,
    title: appBarTitleWidget(context, title, color: color),
    actions: actions,
    elevation: 0.0,
  );
}

// class ExampleItemWidget extends StatelessWidget {
//   final ListModel tabBarType;
//   final Function onTap;
//   final bool showTrailing;
//
//   ExampleItemWidget(this.tabBarType,
//       {required this.onTap, this.showTrailing = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: appStore.appBarColor,
//       margin: EdgeInsets.fromLTRB(12, 12, 12, 0),
//       elevation: 2.0,
//       shadowColor: Colors.black,
//       child: ListTile(
//         onTap: () => onTap(),
//         title: Text(tabBarType.name, style: boldTextStyle()),
//         trailing: showTrailing
//             ? Icon(Icons.arrow_forward_ios,
//                 size: 15, color: appStore.textPrimaryColor)
//             : null,
//       ),
//     );
//   }
// }

String convertDate(date) {
  try {
    return date != null
        ? DateFormat(dateFormat).format(DateTime.parse(date))
        : '';
  } catch (e) {
    print(e);
    return '';
  }
}

class CustomTheme extends StatelessWidget {
  final Widget child;

  CustomTheme({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: child,
    );
  }
}

Function(BuildContext, String) placeholderWidgetFn() =>
        (_, s) => placeholderWidget();

Widget placeholderWidget() =>
    Image.asset('images/LikeButton/image/grey.jpg', fit: BoxFit.cover);

BoxConstraints dynamicBoxConstraints({double? maxWidth}) {
  return BoxConstraints(maxWidth: maxWidth ?? applicationMaxWidth);
}

double dynamicWidth(BuildContext context) {
  return isMobile ? context.width() : applicationMaxWidth;
}

//-------------------------------------------Form-------------------------------------------------------------------------
// EditText rounded Style

class EditText extends StatefulWidget {
  final String? hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool? isPhone;
  final bool readOnly;
  final void Function(String)? onPressed;
  final void Function()? onTap;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validatefunc;
  final IconData? suffixIcon;
  final Function? suffixIconOnTap;
  const EditText(
      {Key? key, this.hintText, this.prefixIcon, required this.isPassword, this.isPhone, required this.onPressed, this.controller, this.keyboardType=TextInputType.text, required this.validatefunc, this.suffixIcon=null, this.readOnly=false, this.suffixIconOnTap=null, this.onTap})
      : super(key: key);
  @override
  _EditTextState createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  TextEditingController? controller;
  bool _showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: TextFormField(

        keyboardType: widget.keyboardType,
        validator: widget.validatefunc,
        onTap: widget.onTap,
        onChanged: widget.onPressed,
        style:
        TextStyle(fontSize: textSizeLargeMedium, fontFamily: fontRegular),
        obscureText: widget.isPassword && !_showPassword,
        controller: widget.controller,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          suffixIcon: widget.isPassword
              ? GestureDetector(
            onTap: () => setState(() => _showPassword = !_showPassword),
            child: Icon(
                !_showPassword ? Icons.visibility_off : Icons.visibility,
                color: appColorPrimary),
          )
              : GestureDetector(
            onTap: () {
              if(widget.suffixIconOnTap != null) widget.suffixIconOnTap!();
              setState(() => widget.controller!.clear());
            },
            child: Icon(widget.suffixIcon),
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: appColorPrimary,
          ),
          contentPadding: EdgeInsets.symmetric(vertical:18),
          hintText: widget.hintText,
          filled: true,
          fillColor: edit_text_background,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
              const BorderSide(color: edit_text_background, width: 0.0)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: edit_text_background, width: 0.0),
          ),
        ),
      ),
    );
  }
}

// Padding editTextStyle() {
//   return
// }

// EditText
Padding editTextCard(var hintText) {
  return Padding(
    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    child: TextFormField(
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(24, 10, 24, 10),
          hintText: hintText),
    ),
  );
}

// Login/SignUp HeadingElement
Text formHeading(var label) {
  return Text(label,
      style: TextStyle(
          color: textPrimaryColor, fontSize: 30, fontFamily: 'Bold'),
      textAlign: TextAlign.center);
}

Text formSubHeadingForm(var label) {
  return Text(label,
      style: TextStyle(
          color: textSecondaryColor, fontSize: 20, fontFamily: 'Bold'),
      textAlign: TextAlign.center);
}

Widget shadowButton(String name, void Function()? function) {
  return MaterialButton(
    height: 40,
    minWidth: double.infinity,
    child: text(name,
        fontSize: textSizeMedium,
        textColor: whiteColor,
        fontFamily: fontMedium),
    textColor: whiteColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    color: appColorPrimary,
    onPressed: function,
  );
}

Widget toolBarTitle(var title, {textColor = appColorPrimary}) {
  return text(title,
      fontSize: textSizeNormal, fontFamily: fontBold, textColor: textColor);
}

class Catagory extends StatefulWidget {
  final String name;
  final String image;
  final bool? isURL;
  final void Function()? onPress;

  const Catagory({Key? key, required this.name, required this.image,this.isURL, this.onPress}): super(key: key);
  @override
  _CatagoryState createState() => _CatagoryState();
}

class _CatagoryState extends State<Catagory> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double h = size.height;
    double w = size.width;
    return Container(
        width: w/4,
        height: h*0.15,
        // padding: EdgeInsets.symmetric(horizontal: 20),
        // margin: EdgeInsets.only(),
        decoration: boxDecoration(
            bgColor: appColorPrimary.withOpacity(0.2), radius: spacing_standard),
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisSize: MainAxisSize.min,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     Image.asset(
        //       widget.image,
        //       width: 100 * 0.4,
        //       height: 100 * 0.4,
        //       color: appColorPrimary,
        //     ),
        //     SizedBox(height: 10),
        //     Text(
        //       widget.name,
        //       textAlign: TextAlign.center,
        //       style: TextStyle(),
        //     ),
        //   ],
        // ),
        child: TextButton(
          onPressed: widget.onPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.isURL != null ?
              Image(image: NetworkImage(widget.image),width: w*0.2, height: h*0.046,)
              // Image.network(
              //   widget.image,
              //   width: w*0.2,
              //   height: h*0.052,
              // )
                  :
              Image.asset(
                widget.image,
                width: w*0.2,
                height: h*0.046,
                color: appColorPrimary,
              ),
              SizedBox(height: 10),
              Flexible(
                child: Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                ),
              ),
            ],
          ),
        )
    );
  }
}
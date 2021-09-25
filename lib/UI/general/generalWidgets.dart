import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

buildDefaultAppBar(ThemeData theme, double width, bool goBack, String title,
    BuildContext context, GlobalKey<ScaffoldState> _drawerKey) {
  return AppBar(
    automaticallyImplyLeading: false,
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 15),
        child: InkWell(
          onTap: () {
            _drawerKey.currentState.openEndDrawer();
          },
          child: Icon(
            Icons.menu,
            color: theme.canvasColor,
            size: 30,
          ),
        ),
      )
    ],
    backgroundColor: theme.primaryColor,
    centerTitle: true,
    leading: goBack
        ? InkWell(
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: theme.canvasColor,
              size: 28,
            ),
          )
        : SizedBox(),
    title: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: theme.canvasColor, fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}

buildDefaultAppBarWithoutDrawer(ThemeData theme, double width, bool goBack,
    String title, BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: theme.primaryColor,
    centerTitle: true,
    leading: InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      child: Icon(
        Icons.arrow_back_ios,
        color: theme.canvasColor,
        size: 28,
      ),
    ),
    title: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: theme.canvasColor, fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

buildLoadingDialog(
  BuildContext context,
  ThemeData theme,
) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: theme.accentColor.withOpacity(0.5),
      builder: (context) {
        return SpinKitRipple(
          color: theme.canvasColor,
          size: 100,
        );
      });
}

buildInternetErrorToast(
  BuildContext context,
  ThemeData theme,
) {
  return Fluttertoast.showToast(
      msg: "Please check your internet connection and try again.",
      fontSize: 16,
      backgroundColor: theme.accentColor,
      textColor: theme.canvasColor,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT);
}

buildErrorToast(BuildContext context, ThemeData theme, String errMsg) {
  return Fluttertoast.showToast(
      msg: errMsg,
      fontSize: 16,
      backgroundColor: theme.accentColor,
      textColor: theme.canvasColor,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG);
}

buildNavigationMethod(BuildContext context, Widget page, bool removeUntilRoot) {
  removeUntilRoot
      ? Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => page,
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: Duration(milliseconds: 1000),
          ),
          (Route<dynamic> route) => false)
      : Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => page,
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: Duration(milliseconds: 1000),
          ),
        );
}

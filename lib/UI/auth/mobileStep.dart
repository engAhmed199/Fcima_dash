import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/UI/auth/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/UI/general/generalWidgets.dart';
import 'package:dashboard/fbAPI/sharedApi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileStep extends StatefulWidget {
  @override
  _MobileStepState createState() => _MobileStepState();
}

class _MobileStepState extends State<MobileStep> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");

  Future<List> checkIfUserFound() async {
    Map userDoc;
    String docId;

    try {
      await usersCollection
          .where("email", isEqualTo: email.text.trim())
          .get()
          .then((QuerySnapshot querySnapshot) {
        Navigator.of(context, rootNavigator: true).pop();

        querySnapshot.docs.length == 0
            ? buildErrorToast(
                context, Theme.of(context), "  This email is not exist ")
            : checkPassword(querySnapshot.docs[0].data());
        docId = querySnapshot.docs[0].id;
      });
    } catch (err) {
      print(err);
      userDoc = null;
    }
    return [userDoc, docId];
  }

  checkPassword(Map userData) {
    if (userData["password"] == password.text.trim()) {
      enterAppAgainAsUser(userData, context, Theme.of(context));
    } else {
      buildErrorToast(
          context, Theme.of(context), 'This password is not correct');
    }
  }

  enterAppAgainAsUser(Map user, BuildContext context, ThemeData theme) async {
    await FirebaseAuth.instance.signInAnonymously().then((value) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      sharedPreferences.setString("userType", user["type"]);
      buildErrorToast(context, theme, " Sign In is successfully ");
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => Splash(),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: Duration(milliseconds: 1000),
          ),
          (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      drawerScrimColor: Colors.transparent,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            " Sign In",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.canvasColor.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        height: height,
        width: width,
        color: theme.primaryColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: width / 6),
                child: Container(
                  height: 50,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        width: 1, color: theme.canvasColor.withOpacity(0.8)),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: email,
                      maxLines: 1,
                      style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email,
                          color: theme.canvasColor,
                          size: 30,
                        ),
                        // hintText: "البريد الإلكتروني",
                        hintText: 'E-mail',
                        hintStyle: TextStyle(
                            color: theme.canvasColor.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.only(top: 15, right: 10, left: 10),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 20, horizontal: width / 6),
                child: Container(
                  height: 50,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        width: 1, color: theme.canvasColor.withOpacity(0.8)),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: password,
                      maxLines: 1,
                      style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.security,
                          color: theme.canvasColor,
                          size: 30,
                        ),
                        hintText: "Password",
                        hintStyle: TextStyle(
                            color: theme.canvasColor.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.only(top: 15, right: 10, left: 10),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: InkWell(
                  onTap: () {
                    if (email.text.trim().isNotEmpty &&
                        password.text.trim().isNotEmpty) {
                      buildLoadingDialog(context, theme);
                      isThereInternet().then((value) {
                        if (value) {
                          checkIfUserFound();
                        } else {
                          Navigator.of(context, rootNavigator: true).pop();
                          buildInternetErrorToast(context, theme);
                        }
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: theme.accentColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 1,
                            color: theme.canvasColor.withOpacity(0.5))),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      child: Text(
                        " Login",
                        style: TextStyle(
                            color: theme.canvasColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

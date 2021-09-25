import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/UI/auth/splash.dart';
import 'package:dashboard/UI/inside/addFilm.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; //animation log in
import 'package:shared_preferences/shared_preferences.dart'; //to save data el firebase
import 'package:dashboard/UI/general/generalWidgets.dart';
import 'package:dashboard/fbAPI/sharedApi.dart';

import 'filmsDetails.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool drawer = false;
  bool loading = true;
  CollectionReference filmsCollection =
      FirebaseFirestore.instance.collection("films");
  String userType;
  String userDocId;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  List timelineFilms = [];
  QueryDocumentSnapshot lastTimeLinePost;
  ScrollController _scrollControllerToDetectbottom = new ScrollController();

  Future getUserType() async {
    //save el data el user 3mlha 3la el app 3la elmobile
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userType = sharedPreferences.getString("userType");
    });
  }

  Future<List<QueryDocumentSnapshot>> getFilmsDocs() async {
    List<QueryDocumentSnapshot> timelineFilms;
    try {
      QuerySnapshot querySnapshot = await filmsCollection.get();
      timelineFilms = querySnapshot.docs;
      print(querySnapshot.docs.length);
    } catch (err) {}
    return timelineFilms;
  }

  @override
  void initState() {
    super.initState();
    getUserType();
    isThereInternet().then((value) {
      if (value) {
        getFilms();
      } else {
        buildInternetErrorToast(context, Theme.of(context));
      }
    });
  }

  getFilms() {
    getFilmsDocs().then((List<QueryDocumentSnapshot> allFilmsDocsSnapshot) {
      if (!mounted) return null;
      setState(() {
        if (allFilmsDocsSnapshot != null) {
          timelineFilms = allFilmsDocsSnapshot.map((e) => e.data()).toList();
        }
        loading = false;
      });
    });
  }

  deleteFilmAsk(ThemeData theme, Map film) {
    showDialog(
        context: context,
        barrierDismissible: true, //
        builder: (context) {
          return AlertDialog(
            backgroundColor: theme.accentColor,
            content: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Are you sure delete this movie?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                    onTap: () {
                      deleteTheFilm(theme, film);
                    },
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          );
        });
  }

  deleteTheFilm(ThemeData theme, Map film) {
    Navigator.of(context, rootNavigator: true).pop();
    isThereInternet().then((value) async {
      if (value) {
        try {
          buildLoadingDialog(context, theme);
          await filmsCollection.doc(film["uid"]).delete().then((value) {
            Navigator.of(context, rootNavigator: true).pop();

            if (!mounted) return null;
            setState(() {
              timelineFilms.remove(film);
            });
            buildErrorToast(
                context, theme, " The movis has been successfully deleted.");
          });
        } catch (e) {
          buildErrorToast(context, theme, "An error occurred , try again.");
        }
      } else {
        buildInternetErrorToast(context, theme);
      }
    });
  }

  logOutAsk(ThemeData theme) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            backgroundColor: theme.accentColor,
            content: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Do you really want to log out ?",
                style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                    onTap: () {
                      logOutConfirmed(theme);
                    },
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          );
        });
  }

  logOutConfirmed(ThemeData theme) {
    Navigator.of(context, rootNavigator: true).pop();
    isThereInternet().then((value) {
      if (value) {
        try {
          FirebaseAuth.instance.signOut().then((value) async {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            sharedPreferences.clear();
            buildErrorToast(context, theme, "Log out is done");

            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => Splash(),
                  transitionsBuilder: (c, anim, a2, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: Duration(milliseconds: 1000),
                ),
                (Route<dynamic> route) => false);
          });
        } catch (e) {}
      } else {
        buildInternetErrorToast(context, theme);
      }
    });
  }

  buildAppBar(ThemeData theme, double width, bool goBack, String title,
      BuildContext context, GlobalKey<ScaffoldState> _drawerKey) {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: InkWell(
            onTap: () {
              logOutAsk(theme);
            },
            child: Icon(
              Icons.logout,
              color: theme.canvasColor,
              size: 30,
            ),
          ),
        )
      ],
      backgroundColor: theme.primaryColor,
      centerTitle: true,
      leading: userType != "admin"
          ? SizedBox()
          : InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (c, a1, a2) => AddFilm(),
                    transitionsBuilder: (c, anim, a2, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 1000),
                  ),
                ).then((value) {
                  if (value != null) {
                    if (!mounted) return null;
                    setState(() {
                      timelineFilms.insert(0, value);
                    });
                  }
                });
              },
              child: Icon(
                Icons.add_box,
                color: theme.canvasColor,
                size: 30,
              ),
            ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: theme.canvasColor,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: buildAppBar(theme, width, false, "Cinema", context, _drawerKey),
      body: Container(
        height: height,
        width: width,
        color: theme.primaryColor,
        child: SingleChildScrollView(
          controller: _scrollControllerToDetectbottom,
          physics: ScrollPhysics(parent: ScrollPhysics()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              loading
                  ? Center(
                      child: SpinKitRipple(
                        color: theme.canvasColor,
                        size: 80,
                      ),
                    )
                  : timelineFilms.length == 0
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "No movies have been added here yet.",
                              style: TextStyle(
                                  color: theme.canvasColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: timelineFilms.length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(parent: ScrollPhysics()),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              Map timelinePost = timelineFilms[index];

                              return InkWell(
                                  onTap: () {
                                    buildNavigationMethod(
                                        context,
                                        FilmDetails(
                                          filmMap: timelinePost,
                                        ),
                                        false);
                                  },
                                  onLongPress: () {
                                    if (userType == "admin") {
                                      deleteFilmAsk(theme, timelinePost);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: width,
                                          height: height / 1.5,
                                          decoration: BoxDecoration(
                                              color: theme.primaryColor,
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "${timelinePost["image"]}"),
                                                  fit: BoxFit.cover),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 1,
                                                    color: Colors.red,
                                                    spreadRadius: 1,
                                                    offset: Offset(0, 0))
                                              ]),
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Padding(
                                              padding: EdgeInsets.all(20),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: theme.primaryColor,
                                                ),
                                                child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Text(
                                                      "${timelinePost["title"]}",
                                                      style: TextStyle(
                                                          color:
                                                              theme.canvasColor,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

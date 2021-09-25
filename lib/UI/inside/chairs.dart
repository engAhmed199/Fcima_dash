import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:dashboard/UI/general/generalWidgets.dart';

class Chairs extends StatefulWidget {
  final Map filmMap;
  final String userType;

  const Chairs({Key key, this.filmMap, this.userType});
  @override
  _ChairsState createState() => _ChairsState();
}

class _ChairsState extends State<Chairs> {
  List chosenChairs = [];
  List chosenChairsInDatabase = [];

  @override
  void initState() {
    super.initState();
    getChairs();
  }

  getChairs() async {
    await filmsCollection
        .doc(widget.filmMap["uid"])
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      setState(() {
        chosenChairsInDatabase = documentSnapshot.data()["chairs"] != null
            ? documentSnapshot.data()["chairs"]
            : [];
      });
    });
  }

  CollectionReference filmsCollection =
      FirebaseFirestore.instance.collection("films");

  buildAppBar(ThemeData theme, double width, bool goBack, String title,
      BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.primaryColor,
      centerTitle: true,
      actions: [
        chosenChairs.length == 0
            ? SizedBox()
            : InkWell(
                onTap: () async {
                  setState(() {
                    chosenChairsInDatabase.addAll(chosenChairs);
                  });

                  buildLoadingDialog(context, theme);
                  await filmsCollection
                      .doc(widget.filmMap["uid"])
                      .update({"chairs": chosenChairsInDatabase}).then((value) {
                    Navigator.of(context, rootNavigator: true).pop();
                    setState(() {
                      chosenChairs = [];
                    });
                    buildErrorToast(
                        context, theme, "Reservation was successful");
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.check_box,
                    color: theme.canvasColor,
                    size: 35,
                  ),
                ),
              )
      ],
      leading: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.arrow_back_ios,
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
      appBar: buildAppBar(
          theme, width, false, "${widget.filmMap["title"]}", context),
      body: Container(
        height: height,
        width: width,
        color: theme.primaryColor,
        child: SingleChildScrollView(
          physics: ScrollPhysics(parent: ScrollPhysics()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(width / 20),
                child: GridView.builder(
                    itemCount: 47,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: ScrollPhysics(parent: ScrollPhysics()),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1, crossAxisCount: 6),
                    itemBuilder: (context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          onTap: () {
                            if (widget.userType == "user" &&
                                chosenChairsInDatabase.indexOf("S $index") ==
                                    -1) {
                              setState(() {
                                chosenChairs.indexOf("S $index") == -1
                                    ? chosenChairs.add("S $index")
                                    : chosenChairs.remove("S $index");
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: chosenChairsInDatabase
                                            .indexOf("S $index") ==
                                        -1
                                    ? chosenChairs.indexOf("S $index") == -1
                                        ? theme.primaryColor
                                        : Colors.red
                                    : Colors.amberAccent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    width: 1, color: theme.canvasColor)),
                            child: Center(
                              child: Text(
                                "S $index",
                                style: TextStyle(
                                    color: theme.canvasColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              widget.userType != "admin"
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.all(40),
                      child: InkWell(
                        onTap: () async {
                          buildLoadingDialog(context, theme);
                          await filmsCollection
                              .doc(widget.filmMap["uid"])
                              .update({"chairs": []}).then((value) {
                            Navigator.of(context, rootNavigator: true).pop();
                            setState(() {
                              chosenChairs = [];
                              chosenChairsInDatabase = [];
                            });
                          });
                        },
                        child: Container(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Text(
                                "Cancellation of all reservations",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.red, width: 1)),
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

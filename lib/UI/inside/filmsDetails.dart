import 'dart:async';
import 'package:dashboard/UI/inside/chairs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashboard/UI/general/generalWidgets.dart';
import 'package:dashboard/UI/general/heroImage.dart';

class FilmDetails extends StatefulWidget {
  final Map filmMap;

  const FilmDetails({Key key, this.filmMap});
  @override
  _FilmDetailsState createState() => _FilmDetailsState();
}

class _FilmDetailsState extends State<FilmDetails> {
  String userType;

  Future getUserType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userType = sharedPreferences.getString("userType");
    });
  }

  @override
  void initState() {
    super.initState();
    getUserType();
  }

  buildAppBar(ThemeData theme, double width, bool goBack, String title,
      BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.primaryColor,
      centerTitle: true,
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
        theme,
        width,
        false,
        "${widget.filmMap["title"]}",
        context,
      ),
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
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HeroImage([widget.filmMap["image"]], "tag")));
                },
                child: Image.network(
                  widget.filmMap["image"],
                  width: width,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              ListTile(
                title: Text(
                  "${widget.filmMap["description"]}",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      color: theme.canvasColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              ListTile(
                trailing: Text("${widget.filmMap["time"]}",
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                        color: theme.canvasColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left),
                title: Text(
                  "Time Movie :  ",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.canvasColor.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              userType == "admin"
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.all(40),
                      child: InkWell(
                        onTap: () {
                          buildNavigationMethod(
                              context,
                              Chairs(
                                  filmMap: widget.filmMap, userType: userType),
                              false);
                        },
                        child: Container(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Text(
                                "Book Now",
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
              userType != "admin"
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.all(40),
                      child: InkWell(
                        onTap: () {
                          buildNavigationMethod(
                              context,
                              Chairs(
                                  filmMap: widget.filmMap, userType: userType),
                              false);
                        },
                        child: Container(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Text(
                                "Show reserved Places",
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

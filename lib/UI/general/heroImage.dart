import 'package:flutter/material.dart';

class HeroImage extends StatefulWidget {
  final List imageUrlList;
  final String tag;

  const HeroImage(this.imageUrlList, this.tag);

  @override
  _HeroImageState createState() => _HeroImageState();
}

class _HeroImageState extends State<HeroImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Hero(
              tag: widget.tag,
              child: ListView.builder(
                itemCount: widget.imageUrlList.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: ScrollPhysics(parent: ScrollPhysics()),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      child: widget.imageUrlList[0] is String
                          ? Image.network(widget.imageUrlList[index])
                          : Image.file(widget.imageUrlList[index]),
                      padding: EdgeInsets.symmetric(horizontal: 0.0),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  shape: BoxShape.circle),
              child: Center(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Theme.of(context).canvasColor,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

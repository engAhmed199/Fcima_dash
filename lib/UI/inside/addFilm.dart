import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/UI/general/generalMethods.dart';
import 'package:dashboard/UI/general/generalWidgets.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';

class AddFilm extends StatefulWidget {
  @override
  _AddFilmState createState() => _AddFilmState();
}

class _AddFilmState extends State<AddFilm> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController time = TextEditingController();
  File postImage;

  double progressUploading = 0.0;
  bool uploading = false;
  CollectionReference filmsCollection =
      FirebaseFirestore.instance.collection("films");
  buildAppBar(
      ThemeData theme, double width, String titleAppBar, BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.primaryColor,
      centerTitle: true,
      actions: [
        InkWell(
          onTap: () {
            if (postImage != null &&
                title.text.trim().isNotEmpty &&
                description.text.trim().isNotEmpty &&
                time.text.trim().isNotEmpty) {
              uploadFileToStorage(context, postImage);
            }
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
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: theme.canvasColor,
          size: 30,
        ),
      ),
      title: Text(
        titleAppBar,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: theme.canvasColor,
            fontSize: 14,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Future uploadFileToStorage(BuildContext context, File file) async {
    String downloadUrlVideoImage;
    String downloadUrlVideoImagePath;

    String fileName = file.path;
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(file);

    uploadTask.snapshotEvents.listen((event) {
      if (!mounted) return null;
      setState(() {
        uploading = true;
        progressUploading = (event.bytesTransferred.toDouble() /
            event.totalBytes.toDouble() *
            100);
      });
    });

    await uploadTask.then((TaskSnapshot taskSnapshot) async {
      if (!mounted) return null;
      setState(() {
        uploading = false;
        progressUploading = 0.0;
      });
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      String filePath = taskSnapshot.ref.fullPath;
      addPostDoc(downloadUrl, filePath, downloadUrlVideoImage,
          downloadUrlVideoImagePath);
    }).catchError((Object err) {
      buildErrorToast(context, Theme.of(context), "حدث خطا ما , حاول مرة أخري");
    });
  }

  addPostDoc(String downloadUrl, String filePath, String downloadUrlVideoImage,
      String downloadUrlVideoImagePath) async {
    buildLoadingDialog(context, Theme.of(context));
    await filmsCollection.add({
      "title": title.text.trim(),
      "time": time.text.trim(),
      "description": description.text.trim(),
      "image": downloadUrl,
    }).then((DocumentReference documentReference) async {
      await documentReference
          .update({"uid": documentReference.id}).then((value) async {
        await documentReference.get().then((DocumentSnapshot documentSnapshot) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true)
              .pop(documentSnapshot.data());
        });
      }).catchError((Object err) {
        buildErrorToast(
            context, Theme.of(context), "An error occurred , try again.");
      });
    }).catchError((Object err) {
      buildErrorToast(
          context, Theme.of(context), "An error occurred , try again.");
    });
  }

  buildFilesRow(double width, ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.accentColor),
          child: ListTile(
            trailing: Icon(
              icon,
              color: theme.canvasColor,
              size: 30,
            ),
            title: Text(
              title,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          )),
    );
  }

  buildIcon(IconData icon) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }

  Future chooseImagePickingSource(
      ThemeData theme, BuildContext context, String imageOrVideo) async {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
              backgroundColor: theme.accentColor,
              content: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        completeSteps(imageOrVideo, "camera");
                      },
                      child: buildIcon(Icons.camera_alt),
                    ),
                    InkWell(
                      onTap: () {
                        completeSteps(imageOrVideo, "gallery");
                      },
                      child: buildIcon(Icons.image),
                    ),
                  ],
                ),
              ));
        });
  }

  completeSteps(imageOrVideo, cameraOrGallery) {
    openCameraOrGallery(context, imageOrVideo, cameraOrGallery)
        .then((file) async {
      if (file != null && imageOrVideo == "image") {
        cropImage(File(file.path), context);
      }
    });
  }

  cropImage(File imageFile, BuildContext context) async {
    imageFile.length().then((int size) async {
      await ImageCropper.cropImage(
          sourcePath: imageFile.path,
          compressFormat: ImageCompressFormat.png,
          compressQuality: size > 10000000
              ? 30
              : size > 4000000
                  ? 50
                  : size > 3000000 ? 65 : size > 2000000 ? 75 : 85,
          maxHeight: 1280,
          maxWidth: 720,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarColor: Theme.of(context).accentColor,
              toolbarWidgetColor: Theme.of(context).canvasColor,
              initAspectRatio: CropAspectRatioPreset.original,
              cropFrameColor: Theme.of(context).accentColor,
              activeControlsWidgetColor: Theme.of(context).accentColor,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          )).then((file) {
        setState(() {
          postImage = file;
        });
      });
    });
  }

  buildPostImage(double width, double height, File image, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                if (!mounted) return null;
                setState(() {
                  postImage = null;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: theme.accentColor),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.close,
                    size: 30,
                    color: theme.canvasColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        constraints:
            BoxConstraints(minHeight: height / 4, maxHeight: height / 2),
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(image: FileImage(image), fit: BoxFit.cover)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: buildAppBar(theme, width, "Add new movie", context),
      body: Container(
        height: height,
        width: width,
        color: theme.primaryColor,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: ScrollPhysics(parent: ScrollPhysics()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: width,
                      constraints: BoxConstraints(
                        minHeight: 50,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.accentColor,
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextField(
                          textAlign: TextAlign.start,
                          controller: title,
                          cursorColor: theme.canvasColor,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.canvasColor,
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
                              hintText: "Title....",
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: theme.canvasColor.withOpacity(0.8),
                              )),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: width,
                      constraints: BoxConstraints(
                        minHeight: 50,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.accentColor,
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextField(
                          textAlign: TextAlign.start,
                          controller: description,
                          cursorColor: theme.canvasColor,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.canvasColor,
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
                              hintText: "Description....",
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: theme.canvasColor.withOpacity(0.8),
                              )),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: width,
                      constraints: BoxConstraints(
                        minHeight: 50,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.accentColor,
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextField(
                          textAlign: TextAlign.start,
                          controller: time,
                          cursorColor: theme.canvasColor,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.canvasColor,
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
                              hintText: "Time Movie....",
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: theme.canvasColor.withOpacity(0.8),
                              )),
                        ),
                      ),
                    ),
                  ),
                  postImage != null
                      ? buildPostImage(width, height, postImage, theme)
                      : SizedBox(),
                  postImage != null
                      ? SizedBox()
                      : InkWell(
                          onTap: () {
                            chooseImagePickingSource(theme, context, "image");
                          },
                          child: buildFilesRow(
                              width, theme, "Add Image....", Icons.add_a_photo),
                        ),
                ],
              ),
            ),
            !uploading
                ? SizedBox()
                : Container(
                    height: height,
                    width: width,
                    color: theme.primaryColor.withOpacity(0.6),
                    child: Center(
                      child: CircularPercentIndicator(
                        radius: 70.0,
                        lineWidth: 5.0,
                        percent: (progressUploading / 100),
                        backgroundColor: theme.accentColor,
                        center: new Text(
                          "${progressUploading.toStringAsFixed(2)} %",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: theme.canvasColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        progressColor: theme.canvasColor,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

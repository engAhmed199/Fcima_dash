import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

final picker = ImagePicker();

Future openCameraOrGallery(
    BuildContext context, String imageOrVideo, String source) async {
  Navigator.of(context, rootNavigator: true).pop();
  bool permissionStatus = source == "camera"
      ? await Permission.camera.status.isGranted
      : await Permission.storage.status.isGranted;

  PickedFile pickedImage;
  if (permissionStatus) {
    pickedImage = imageOrVideo == "image"
        ? await picker.getImage(
            source:
                source == "camera" ? ImageSource.camera : ImageSource.gallery)
        : await picker.getVideo(
            source:
                source == "camera" ? ImageSource.camera : ImageSource.gallery);

    return pickedImage;
  } else {
    PermissionStatus permissionStatus = source == "camera"
        ? await Permission.camera.request()
        : await Permission.storage.request();

    if (permissionStatus.isGranted) {
      pickedImage = imageOrVideo == "image"
          ? await picker.getImage(
              source:
                  source == "camera" ? ImageSource.camera : ImageSource.gallery)
          : await picker.getVideo(
              source: source == "camera"
                  ? ImageSource.camera
                  : ImageSource.gallery);
      return pickedImage;
    }
  }
  return null;
}

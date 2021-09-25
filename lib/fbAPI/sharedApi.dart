import 'dart:io';

Future<bool> isThereInternet() async {
  try {
    List connection = await InternetAddress.lookup("google.com");
    if (connection.isNotEmpty && connection[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (e) {
    return false;
  }
}

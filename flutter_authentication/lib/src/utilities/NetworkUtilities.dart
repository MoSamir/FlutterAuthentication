import 'dart:io';
class NetworkUtilities {
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup("google.com")
          .timeout(Duration(seconds: 5), onTimeout: () {
        throw SocketException('');
      });
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}

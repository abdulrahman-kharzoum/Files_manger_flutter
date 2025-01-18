import 'package:http/http.dart' as http;

Future<bool> hasNetwork() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } catch (e) {
    // Handle errors like timeout or lack of connection
    return false;
  }
}

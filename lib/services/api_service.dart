import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://192.168.1.10/case_stud'; // change IP if needed

  static Future<List<dynamic>> fetchResidents() async {
    final url = Uri.parse('$baseUrl/residents/get.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        return result['data'];
      } else {
        throw Exception('API returned error: ${result['message']}');
      }
    } else {
      throw Exception('Failed to fetch data. Code: ${response.statusCode}');
    }
  }
}

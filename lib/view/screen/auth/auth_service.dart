import 'dart:convert';
import 'dart:developer';
import 'package:driver_taxi/utils/url.dart';
import 'package:driver_taxi/view/screen/auth/login.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Uri loginUrl = Uri.parse('${Url.url}api/login');

  static Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final Uri url = Uri.parse('${Url.url}api/profile');
    String token = await _getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data')) {
          return data;
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please check your token.');
      } else {
        log('Error status code: ${response.statusCode}');
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (error) {
      log('Error fetching user data: $error');
      throw Exception('Failed to load user data. Please try again later.');
    }
  }

static Future<void> logout() async {
  log('Logout function called'); 
  
  final String apiUrl = '${Url.url}api/logout';
  String token = await _getToken();

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    log('Logout API Response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Get.offAll(() => LoginScreen1()); // الانتقال إلى شاشة تسجيل الدخول
      Get.snackbar('', 'تم تسجيل الخروج بنجاح');
    } else {
      log('Logout failed: ${response.statusCode}');
      log('Response body: ${response.body}');
      throw Exception('Failed to log out: ${response.statusCode}');
    }
  } catch (error) {
    log('Error during logout: $error');
    throw Exception('Failed to log out: $error');
  }
}

}

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<Map<String, String?>> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? name = prefs.getString('name');
    String? email = prefs.getString('email');
    String? chat_id = prefs.getString('chat_id');
    String? customer_id = prefs.getString('customer_id');
    String? id = prefs.getString('Id');
    String? token = prefs.getString('token');

    return {
      'name': name,
      'email': email,
      'token': token,
      'chat_id': chat_id,
      'customer_id': customer_id,
      'id': id,
    };
  }
}

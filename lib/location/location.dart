import 'dart:developer';

import 'package:driver_taxi/utils/url.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:driver_taxi/view/screen/mainscreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static Timer? _locationTimer;

  static void startSendingLocationPeriodically() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      sendLocationToDatabase();
    });
  }

  static void stopSendingLocation() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  static Future<void> sendLocationToDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('Id');
    var token = prefs.getString('token');
    String apiUrl = '${Url.url}api/get-taxi-location/$userId';

    try {
      PermissionStatus status = await Permission.location.request();
      if (status == PermissionStatus.denied) {
        log('إذن الوصول إلى الموقع مرفوض من قبل المستخدم.');
        return;
      } else if (status == PermissionStatus.permanentlyDenied) {
        log('إذن الوصول إلى الموقع مرفوض بشكل دائم.');
        await openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Map<String, dynamic> payload = {
        'lat': position.latitude,
        'long': position.longitude,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        log('تم إرسال بيانات الموقع بنجاح.');
      } else {
        print(response.body);
        log('فشل في إرسال بيانات الموقع. الرمز الحالة: ${response.statusCode}');
      }
    } catch (e) {
      log('حدث خطأ أثناء إرسال بيانات الموقع: $e');
    }
  }

  // دالة لإنهاء إرسال الموقع وإرسال البيانات النهائية
  static Future<void> EndsendLocationToDataBase(double kilometers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var request_id = prefs.getString('request_id');
    var token = prefs.getString('token');
    String apiUrl = '${Url.url}api/movements/mark-completed/$request_id';

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Map<String, dynamic> payload = {
        'distance': kilometers,
        'end_latitude': double.parse(position.latitude.toString()),
        'end_longitude': double.parse(position.longitude.toString()),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        log('تم إرسال بيانات الموقع بنجاح.');
        stopSendingLocation();
        log('تم ايقاف الارسال ');
        Get.off(() => const MainScreen());
      } else {
        log('فشل في إرسال بيانات الموقع. الرمز الحالة: ${response.statusCode}');
        log('فشل في إرسال بيانات الموقع. الرمز الحالة: ${response.body}');
      }
    } catch (e) {
      log('حدث خطأ أثناء إرسال بيانات الموقع: $e');
    }
  }
}

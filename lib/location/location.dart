import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:driver_taxi/utils/url.dart';
import 'package:driver_taxi/view/screen/mainscreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static Timer? _locationTimer;

  /// بدء إرسال الموقع بشكل دوري كل 5 ثوانٍ
  static void startSendingLocationPeriodically() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      sendLocationToDatabase();
    });
  }

  /// إيقاف إرسال الموقع
  static void stopSendingLocation() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  /// إرسال الموقع الحالي إلى قاعدة البيانات
  static Future<void> sendLocationToDatabase() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('Id');
      var token = prefs.getString('token');
      String apiUrl = '${Url.url}api/get-taxi-location/$userId';

      // طلب إذن الوصول إلى الموقع
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
        headers: _buildHeaders(token),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        log('تم إرسال بيانات الموقع بنجاح.');
      } else {
        log('فشل في إرسال بيانات الموقع. الرمز الحالة: ${response.statusCode}');
        log('تفاصيل الخطأ: ${response.body}');
      }
    } catch (e) {
      log('حدث خطأ أثناء إرسال بيانات الموقع: $e');
    }
  }

  /// إنهاء إرسال الموقع وإرسال البيانات النهائية إلى قاعدة البيانات
  static Future<void> EndsendLocationToDataBase(
    double kilometers,
    double additional,
    String coin,
    String notes,
    String reason,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var requestId = prefs.getString('request_id');
      var token = prefs.getString('token');
      String apiUrl = '${Url.url}api/movements/mark-completed/$requestId';

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Map<String, dynamic> payload = {
        'distance': kilometers,
        'end_latitude': position.latitude,
        'end_longitude': position.longitude,
        'notes': notes,
        'additional_amount': additional,
        'reason': reason,
        'coin': coin,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: _buildHeaders(token),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        log('تم إرسال بيانات الموقع بنجاح.');
        stopSendingLocation();
        log('تم إيقاف إرسال الموقع.');
        Get.off(() => const MainScreen());
      } else {
        log('فشل في إرسال بيانات الموقع. الرمز الحالة: ${response.statusCode}');
        log('تفاصيل الخطأ: ${response.body}');
      }
    } catch (e) {
      log('حدث خطأ أثناء إرسال بيانات الموقع: $e');
    }
  }

  /// إنشاء ترويسات الطلب HTTP
  static Map<String, String> _buildHeaders(String? token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:driver_taxi/components/custom_botton.dart';
import 'package:driver_taxi/components/custom_loading_button.dart';
import 'package:driver_taxi/location/location.dart';
import 'package:driver_taxi/utils/app_colors.dart';
import 'package:driver_taxi/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  bool _isOnDuty = true;
  double _price = 0.0;
  final TextEditingController _kilometersController = TextEditingController();

  @override
  void dispose() {
    _kilometersController.dispose();
    super.dispose();
  }

  // إرسال حالة الطلب إلى الخادم
  Future<void> sendStatusToDataBase(bool isOnDuty) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var requestId = prefs.getString('request_id');
    var token = prefs.getString('token');

    if (requestId == null || token == null) {
      log('Error: request_id or token is null');
      return;
    }

    final Map<String, dynamic> data = {
      'state': isOnDuty ? 1 : 0,
    };

    try {
      final response = await http.post(
        Uri.parse('${Url.url}api/movements/found-customer/$requestId'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Status sent successfully');
        // إظهار رسالة نجاح أو تنقل إلى صفحة أخرى
      } else {
        log('Failed to send status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error sending status: $e');
    }
  }

  // تحديث السعر بناءً على الكيلومترات المدخلة
  void _updatePrice(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var typeMov = prefs.getString('typeMov');
    bool isInternalRequest = typeMov != 'طلب خارجي';

    log('typeMov: $typeMov');
    log('isInternalRequest: $isInternalRequest');
    log('price from prefs: ${prefs.getDouble('price')}');
    log('Input value: $value');

    double kilometers = double.tryParse(value) ?? 0.0;
    log('Parsed kilometers: $kilometers');

    setState(() {
      if (isInternalRequest) {
        _price = prefs.getDouble('price') ?? 1.0;
      } else {
        double price = prefs.getDouble('price') ?? 1.0;
        _price = kilometers * price;
      }
      log('Updated price: $_price');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'صفحة الطلب',
        ),
        backgroundColor: AppColors.BackgroundColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.blue1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // أزرار حالة الطلب
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusButton(
                  text: 'تم العثور على الزبون',
                  isSelected: _isOnDuty,
                  onPressed: () {
                    setState(() => _isOnDuty = true);
                    sendStatusToDataBase(_isOnDuty);
                  },
                ),
                _buildStatusButton(
                  text: 'لم يتم العثور على الزبون',
                  isSelected: !_isOnDuty,
                  onPressed: () {
                    setState(() => _isOnDuty = false);
                    sendStatusToDataBase(_isOnDuty);
                  },
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // عرض السعر
            CustomButton(
              width: 295.h,
              height: 35.h,
              onPressed: () {},
              background_color1: AppColors.white,
              background_color2: AppColors.white,
              border_color: AppColors.grey,
              text: 'السعر: $_price',
              textColor: AppColors.BackgroundColor,
            ),
            const SizedBox(height: 20),
            // حقل إدخال الكيلومترات
            TextField(
              controller: _kilometersController,
              decoration: InputDecoration(
                hintText: '  كيلومترات',
                suffixIcon: const Icon(
                  Icons.directions_car,
                  color: ui.Color.fromARGB(95, 0, 0, 0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: _updatePrice,
            ),
            const Spacer(),
            // زر إنهاء الرحلة
            LoadingButtonWidget(
              onPressed: () {
                double kilometers =
                    double.tryParse(_kilometersController.text) ?? 1.0;
                LocationService.EndsendLocationToDataBase(kilometers);
                _kilometersController.clear();
              },
              text: 'قم بانهاء الرحلة',
            ),
          ],
        ),
      ),
    );
  }

  // بناء زر حالة الطلب
  Widget _buildStatusButton({
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return LoadingButtonWidget(
      width: 150.w,
      height: 35.h,
      onPressed: onPressed,
      borderColor: isSelected ? AppColors.blue2 : AppColors.grey,
      backgroundColor1: isSelected ? AppColors.blue1 : AppColors.white,
      backgroundColor2: isSelected ? AppColors.blue2 : AppColors.white,
      textColor: isSelected ? AppColors.white : AppColors.BackgroundColor,
      fontSize: 12,
      text: text,
    );
  }
}

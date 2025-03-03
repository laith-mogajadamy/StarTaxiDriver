import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;
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
  final Map<String, String> currencyMap = {
    'السوري': 'SYP',
    'التركي': 'TL',
    'الدولار': 'USD',
  };

  String? selectedCurrency;
  String? selectedCurrencyValue;
  bool _isOnDuty = true;
  double _price = 0.0;
  final TextEditingController _kilometersController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _additionalController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // مفتاح لإدارة الفورم

  @override
  void dispose() {
    _kilometersController.dispose();
    _reasonController.dispose();
    _additionalController.dispose();
    _notesController.dispose();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                TextFormField(
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الكيلومترات';
                    }
                    if (double.tryParse(value) == null) {
                      return 'يرجى إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _additionalController,
                  decoration: InputDecoration(
                    hintText: 'المبلغ المالي',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال المبلغ المالي';
                    }
                    if (double.tryParse(value) == null) {
                      return 'يرجى إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'نوع العملة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  value: selectedCurrency,
                  items: currencyMap.keys.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCurrency = newValue;
                      selectedCurrencyValue = currencyMap[newValue];
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى اختيار العملة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    hintText: 'السبب',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال السبب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'ملاحظات',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الملاحظات';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                // const Spacer(),
                LoadingButtonWidget(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      double kilometers =
                          double.tryParse(_kilometersController.text) ?? 1.0;
                      double additional =
                          double.tryParse(_additionalController.text.trim()) ??
                              0.0;
                      String coin = selectedCurrencyValue ?? 'SYP';
                      String reason = _reasonController.text.trim();
                      String notes = _notesController.text.trim();

                      LocationService.EndsendLocationToDataBase(
                        kilometers,
                        additional,
                        coin,
                        reason,
                        notes,
                      );

                      _kilometersController.clear();
                      _reasonController.clear();
                      _additionalController.clear();
                      _notesController.clear();
                    }
                  },
                  text: 'قم بانهاء الرحلة',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

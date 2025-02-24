import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:driver_taxi/components/custom_password_field.dart';
import 'package:driver_taxi/components/customTextField.dart';
import 'package:driver_taxi/components/custom_loading_button.dart';
import 'package:driver_taxi/components/custom_snackbar.dart';
import 'package:driver_taxi/components/custom_text.dart';
import 'package:driver_taxi/utils/app_colors.dart';
import 'package:driver_taxi/utils/url.dart';
import 'package:driver_taxi/view/screen/mainscreen.dart';

class LoginScreen1 extends StatefulWidget {
  @override
  State<LoginScreen1> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen1> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> loginUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? devicetoken = prefs.getString('device_token');
    final Map<String, dynamic> data = {
      'email': emailController.text,
      'password': passwordController.text,
      'device_token': devicetoken ?? '',
    };
    final Uri url = Uri.parse('${Url.url}api/login');
    try {
      final response = await http.post(
        url,
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      log(response.body);
      log('${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String token = responseData['data']['token'];
        final String id = responseData['data']['user']['id'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        prefs.setString('Id', id);
        prefs.setString('token', token);

        CustomSnackbar.show(context, 'تم  تسجيل الدخول بنجاح'.tr);
        Get.off(const MainScreen());
      } else {
        _handleErrorResponse(response.statusCode);
      }
    } catch (error) {
      log('حدث خطأ : $error');
    }
  }

  void _handleErrorResponse(int statusCode) {
    String message;
    switch (statusCode) {
      case 422:
        message =
            'هناك خطأ بالبيانات الرجاء التحقق من البريد الإلكتروني وكلمة المرور'
                .tr;
        break;
      case 403:
        message = 'هذا السائق لا يمتلك تاكسي'.tr;
        break;
      default:
        message = 'حدث خطأ غير متوقع'.tr;
    }
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo_star_taxi.png",
                    height: 300,
                  ),
                  const CustomText(
                    text: 'صفحة تسجيل الدخول',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    alignment: Alignment.center,
                    color: AppColors.textColor,
                  ),
                  SizedBox(height: 30.h),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'ادخل البريد الالكتروني'.tr,
                    iconData: Icons.email,
                    iconColor: AppColors.iconColor,
                    validator: _emailValidator,
                  ),
                  SizedBox(height: 20.h),
                  CustomPasswordField(
                    controller: passwordController,
                    validator: _passwordValidator,
                  ),
                  SizedBox(height: 15.h),
                  LoadingButtonWidget(
                    text: 'تسجيل الدخول',
                    width: 300,
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        loginUser();
                      }
                    },
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني الخاص بك';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال عنوان بريد إلكتروني صالح';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور الخاصة بك';
    }
    if (value.length < 6) {
      return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
    }
    return null;
  }
}

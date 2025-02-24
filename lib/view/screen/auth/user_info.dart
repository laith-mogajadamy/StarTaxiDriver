import 'dart:convert';
import 'dart:developer';

import 'package:driver_taxi/components/custom_text.dart';
import 'package:driver_taxi/utils/app_colors.dart';
import 'package:driver_taxi/utils/url.dart';
import 'package:driver_taxi/view/screen/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.BackgroundColor,
        title: const Text(
          'ملفي الشخصي',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.blue1),
        ),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: AuthService.getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final userData = snapshot.data?['data'];
              if (userData == null || userData is! Map<String, dynamic>) {
                return const Text('Unexpected response format');
              }

              log(jsonEncode(userData)); // تصحيح تسجيل البيانات

              return Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: SizedBox(
                            width: size.width / 1.8,
                            height: size.height / 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                userData['avatar'] != null &&
                                        userData['avatar'].isNotEmpty
                                    ? '${Url.url}${userData['avatar']}'
                                    : 'assets/images/logo_star_taxi.png',
                                height: 110.h,
                                width: 120.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/car1.png',
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const CustomText(
                          text: 'الاسم الكامل',
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(height: 3.h),
                        TextFormField(
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              color: Colors.black,
                            ),
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            filled: true,
                            fillColor: AppColors.textField_color,
                          ),
                          initialValue: userData['name'] ?? 'غير متوفر',
                          readOnly: true,
                        ),
                        const SizedBox(height: 20),
                        const CustomText(
                          text: 'رقم الجوال',
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(height: 3.h),
                        TextFormField(
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              color: Colors.black,
                            ),
                            prefixIcon: const Icon(Icons.phone),
                            filled: true,
                            fillColor: AppColors.textField_color,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          initialValue: userData['phone_number'] ?? 'غير متوفر',
                          readOnly: true,
                        ),
                        const SizedBox(height: 20),
                        const CustomText(
                          text: 'البريد الإلكتروني',
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(height: 3.h),
                        TextFormField(
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: AppColors.textField_color,
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          initialValue: userData['email'] ?? 'غير متوفر',
                          readOnly: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

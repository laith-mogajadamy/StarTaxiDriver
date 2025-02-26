import 'package:driver_taxi/components/custom_text.dart';
import 'package:driver_taxi/utils/app_colors.dart';
import 'package:driver_taxi/utils/url.dart';
import 'package:driver_taxi/view/screen/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.BackgroundColor,
        title: const Text(
          'ملفي الشخصي',
          style: TextStyle(color: Colors.black),
        ),
        leading: BackButton(),
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
                            child: ClipOval(
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
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const CustomText(
                          text: 'الاسم الكامل',
                          alignment: Alignment.centerRight,
                          color: AppColors.textColor,
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
                          color: AppColors.textColor,
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
                          color: AppColors.textColor,
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

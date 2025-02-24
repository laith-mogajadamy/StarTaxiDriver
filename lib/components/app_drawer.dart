import 'dart:developer';

import 'package:driver_taxi/components/custom_alert_dialog.dart';
import 'package:driver_taxi/utils/app_colors.dart';
import 'package:driver_taxi/view/screen/auth/auth_service.dart';
import 'package:driver_taxi/view/screen/auth/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: [
                Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo_star_taxi.png'),
                      fit: BoxFit.scaleDown,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.blue1),
            title: const Text(
              'ملفي الشخصي',
              style: TextStyle(
                color: AppColors.blue1,
                fontSize: 18,
              ),
            ),
            tileColor: Colors.grey[100],
            onTap: () {
              Get.to(UserInfoPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.blue1),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(
                color: AppColors.blue1,
                fontSize: 18,
              ),
            ),
            tileColor: Colors.grey[100],
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomAlertDialog(
                    title: 'تسجيل الخروج'.tr,
                    message: 'هل انت متأكد انك تريد تسجيل الخروج'.tr,
                    cancelButtonText: 'إلغاء'.tr,
                    confirmButtonText: 'نعم, الخروج'.tr,
                    onCancel: () {
                      Get.back();
                    },
                    onConfirm: () async {
                      try {
                        await AuthService.logout();
                        Get.back(); // إغلاق نافذة الحوار بعد تسجيل الخروج
                      } catch (error) {
                        Get.snackbar('خطأ', "Error during logout: $error");
                        log("Error during logout: $error");
                      }
                    },
                    icon: Icons.logout,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:developer';

import 'package:driver_taxi/utils/url.dart';
// import 'package:driver_taxi/view/screen/auth/UserPreference.dart';
import 'dart:async';
import 'dart:convert';
import 'package:driver_taxi/components/app_drawer.dart';
import 'package:driver_taxi/components/custom_loading_button.dart';
import 'package:driver_taxi/components/custom_text.dart';
// import 'package:driver_taxi/location/location.dart';
import 'package:driver_taxi/utils/app_colors.dart';
import 'package:driver_taxi/view/screen/orders_main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isOnDuty = true;
  // late Timer _reconnectTimer;
  // bool _isConnected = false;
  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();
  // GoogleMapController? gms;
  // List<Marker> markers = [];
  // CameraPosition cameraPosition = const CameraPosition(
  //   target: LatLng(33.504307, 36.304141),
  //   zoom: 10.4746,
  // );

  // late WebSocketChannel _channel;
  // bool _isSnackbarVisible = false;
  // String? id;
  // String? _token;
  // String? _customer_id;
  // String? _chat_id;

  // @override
  // void initState() {
  //   super.initState();
  //   loadUserData();
  //   getCurrentLocation();
  // }

  // Future<void> loadUserData() async {
  //   Map<String, String?> userInfo = await UserPreferences.getUserInfo();
  //   setState(() {
  //     id = userInfo['id'];
  //     _token = userInfo['token'];
  //     // _chat_id = userInfo['chat_id'];
  //     // _customer_id = userInfo['customer_id'];
  //     if (id != null && _token != null) {
  //       // _connectToWebSocket(); الجديد
  //       // _connectToWebSocket2();
  //     } else {
  //       log('Failed to load user data: id or token is null');
  //     }
  //   });
  // }
  // Future<void> getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     log('Location services are disabled.');
  //     return;
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.whileInUse ||
  //       permission == LocationPermission.always) {
  //     Position position = await Geolocator.getCurrentPosition();

  //     markers.add(Marker(
  //       markerId: const MarkerId("current_location"),
  //       position: LatLng(position.latitude, position.longitude),
  //       infoWindow: const InfoWindow(title: 'موقعك الحالي'),
  //     ));

  //     gms?.animateCamera(CameraUpdate.newLatLng(
  //         LatLng(position.latitude, position.longitude)));

  //     setState(() {});
  //   }
  // }

  // void sendLocation() async {
  //   await LocationService.sendLocationToDatabase();
  //   log('تم إرسال الموقع.');
  // }

  Future<void> sendStatusToDataBase(int stateParam) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    String apiUrl = '${Url.url}api/drivers/change-state';
    // int stateParam = isOnDuty ? 1 : 0;

    final Map<String, dynamic> data = {
      'state': stateParam,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(data),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        log('تم إرسال البيانات بنجاح.');
      } else {
        log('حدث خطأ: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      log('حدث خطأ أثناء إرسال البيانات: $e');
    }
  }

  // @override
  // void dispose() {
  //   _channel.sink.close();
  //   // _channel2.sink.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.blue1, AppColors.blue2],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          child: AppBar(
            title: const CustomText(
              text: 'الصفحة الرئيسية',
              fontSize: 24,
              color: Colors.white,
              alignment: Alignment.topRight,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                LoadingButtonWidget(
                  width: 140.w,
                  height: 40.h,
                  onPressed: () {
                    Get.to(() => const Notifications());
                  },
                  text: "الطلبات",
                  fontSize: 18,
                  backgroundColor1: AppColors.blue1,
                  backgroundColor2: AppColors.blue2,
                  textColor: Colors.white,
                ),
                LoadingButtonWidget(
                  width: 140.w,
                  height: 40.h,
                  onPressed: () {
                    setState(() {
                      _isOnDuty = !_isOnDuty;
                      sendStatusToDataBase(_isOnDuty ? 0 : 1);
                    });
                  },
                  borderColor: _isOnDuty ? AppColors.blue2 : AppColors.grey,
                  backgroundColor1:
                      _isOnDuty ? AppColors.blue1 : AppColors.white,
                  backgroundColor2:
                      _isOnDuty ? AppColors.blue2 : AppColors.white,
                  textColor:
                      _isOnDuty ? AppColors.white : AppColors.BackgroundColor,
                  fontSize: 18,
                  // lodingColor:
                  //     _isOnDuty ? AppColors.white : AppColors.BackgroundColor,
                  text: _isOnDuty ? 'مستعد للرحلات' : 'انت في استراحة',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            "assets/images/logo_star_taxi.png",
            // height: 300,
          ),
        ],
      ),
    );
  }
}

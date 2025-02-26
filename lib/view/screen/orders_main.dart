import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:driver_taxi/components/custom_botton.dart';
import 'package:driver_taxi/components/custom_text.dart';
import 'package:driver_taxi/utils/app_colors.dart';
import 'package:driver_taxi/location/location.dart';
import 'package:driver_taxi/utils/url.dart';
import 'package:driver_taxi/view/screen/auth/UserPreference.dart';
import 'package:driver_taxi/view/screen/order.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  // String apiUrl = apiPath_addition;
  var data;
  bool isLoading = true;
  GoogleMapController? gms;
  List<Marker> markers = [];
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(33.504307, 36.304141),
    zoom: 10.4746,
  );

  String? id;
  String? _token;
  String? _customer_id;
  String? _chat_id;

  @override
  void initState() {
    super.initState();
    fetchData();
    loadUserData();
  }

  /// تحميل بيانات المستخدم من SharedPreferences
  Future<void> loadUserData() async {
    Map<String, String?> userInfo = await UserPreferences.getUserInfo();
    setState(() {
      id = userInfo['id'];
      _token = userInfo['token'];
      _chat_id = userInfo['chat_id'];
      _customer_id = userInfo['customer_id'];
      if (id != null &&
          _token != null &&
          _customer_id != null &&
          _chat_id != null) {
        log('id: $id');
        log('_token: $_token');
        log('_chat_id: $_chat_id');
        log('_customer_id: $_customer_id');
      } else {
        log('Failed to load user data: id or token is null');
      }
    });
  }

  /// جلب بيانات الطلب من الخادم
  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('Id');
    var token = prefs.getString('token');
    log('User ID: $userId');
    log('Token: $token');

    if (userId == null || token == null) {
      log('Error: userId or token not found in SharedPreferences');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      var response = await http.get(
        Uri.parse('${Url.url}api/movements/driver-request/$userId'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        if (responseBody != null && responseBody.isNotEmpty) {
          setState(() {
            data = responseBody;
          });
          log('Data: $data');

          // حفظ المعلومات في SharedPreferences
          await prefs.setString('request_id', data['request_id']);
          await prefs.setString('chat_id', data['chat_id']);
          await prefs.setString('customer_id', data['customer_id']);
          await prefs.setDouble('price', data['price']?.toDouble() ?? 0.0);
          await prefs.setString('typeMov', data['type']);
          await prefs.setString('is_onKM', data['is_onKM'].toString());

          // التعامل مع الموقع وإضافة الـ Marker
          final double locationLat = data['location_lat'] is double
              ? data['location_lat']
              : double.tryParse(data['location_lat'].toString()) ?? 0.0;
          final double locationLong = data['location_long'] is double
              ? data['location_long']
              : double.tryParse(data['location_long'].toString()) ?? 0.0;

          if (locationLat != 0.0 && locationLong != 0.0) {
            setState(() {
              markers.add(Marker(
                markerId: const MarkerId('customerLocation'),
                position: LatLng(locationLat, locationLong),
                infoWindow: InfoWindow(
                  title: 'Customer Location',
                  snippet: 'Lat: $locationLat, Long: $locationLong',
                ),
              ));

              cameraPosition = CameraPosition(
                target: LatLng(locationLat, locationLong),
                zoom: 14.0,
              );

              if (gms != null) {
                gms!.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition),
                );
              }
            });
          } else {
            log('Error: Invalid location coordinates');
          }
        } else {
          log('Error: No data found');
        }
      } else {
        log('Error in response: ${response.statusCode}');
      }
    } catch (error) {
      log('Error fetching data: $error');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              text: 'طلباتي',
              fontSize: 24,
              color: Colors.white,
              alignment: Alignment.topRight,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue1),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  data != null
                      ? Column(
                          children: [
                            const Text(
                              'تفاصيل الطلب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blue1,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(height: 5.h),
                            Card(
                              color: AppColors.BackgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: const BorderSide(color: AppColors.blue1),
                              ),
                              child: ListTile(
                                title: Text(
                                  "اسم الزبون: ${data['name'].toString()}",
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CustomText(
                                      text:
                                          "موقع الزبون: ${data['customer_address'].toString()}",
                                      alignment: Alignment.centerRight,
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                    CustomText(
                                      text:
                                          "الوجهة المراد الذهاب إليها: ${data['destination_address'].toString()}",
                                      alignment: Alignment.centerRight,
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                    CustomText(
                                      text:
                                          "نوع الرحلة: ${data['type'].toString()}",
                                      alignment: Alignment.centerRight,
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            SizedBox(
                              height: 300.h,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: GoogleMap(
                                  markers: markers.toSet(),
                                  initialCameraPosition: cameraPosition,
                                  mapType: MapType.normal,
                                  onMapCreated: (mapController) {
                                    gms = mapController;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 25.h),
                          ],
                        )
                      : Card(
                          color: AppColors.BackgroundColor,
                          margin: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(color: AppColors.blue2),
                          ),
                          elevation: 5,
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CustomText(
                              text: 'لا يوجد بيانات',
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                  if (data != null)
                    CustomButton(
                      width: 200,
                      onPressed: () {
                        LocationService.startSendingLocationPeriodically();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const Order()),
                        );
                      },
                      text: "ابدأ رحلتك",
                    ),
                    SizedBox(
                      height: 50,
                    )
                ],
              ),
            ),
    );
  }
}

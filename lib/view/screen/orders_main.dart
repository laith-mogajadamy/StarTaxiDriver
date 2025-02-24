// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:driver_taxi/components/custom_botton.dart';
// import 'package:driver_taxi/components/custom_text.dart';
// import 'package:driver_taxi/utils/app_colors.dart';
// import 'package:driver_taxi/utils/global.dart';
// import 'package:driver_taxi/location/location.dart';
// import 'package:driver_taxi/utils/url.dart';
// import 'package:driver_taxi/view/screen/auth/UserPreference.dart';
// import 'package:driver_taxi/view/screen/order.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class Notifications extends StatefulWidget {
//   const Notifications({Key? key}) : super(key: key);
//   @override
//   State<Notifications> createState() => _NotificationsState();
// }

// class _NotificationsState extends State<Notifications> {
//   String apiUrl = apiPath_addition;
//   var data;
//   bool isLoading = true;
//   GoogleMapController? gms;
//   List<Marker> markers = [];
//   CameraPosition cameraPosition = const CameraPosition(
//     target: LatLng(33.504307, 36.304141),
//     zoom: 10.4746,
//   );

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//     loadUserData();
//   }

//   late WebSocketChannel _channel;
//   bool _isSnackbarVisible = false;
//   String? id;
//   String? _token;
//   String? _customer_id;
//   String? _chat_id;
//   int _reconnectAttempts = 0;
//   final int _maxReconnectAttempts = 5;
//   final Duration _reconnectDelay = const Duration(seconds: 5);
//   Future<void> loadUserData() async {
//     Map<String, String?> userInfo = await UserPreferences.getUserInfo();
//     setState(() {
//       id = userInfo['id'];
//       _token = userInfo['token'];
//       _chat_id = userInfo['chat_id'];
//       _customer_id = userInfo['customer_id'];
//       if (id != null &&
//           _token != null &&
//           _customer_id != null &&
//           _customer_id != null) {
//         _connectToWebSocket();
//         // _connectToWebSocket2();
//         log('id:$id');
//         log('_token:$_token');
//         log('_chat_id:$_chat_id');
//         log('_customer_id:$_customer_id');
//       } else {
//         log('Failed to load user data: id or token is null');
//       }
//     });
//   }

//   void _connectToWebSocket() {
//     _reconnectAttempts = 0;
//     _channel = WebSocketChannel.connect(
//       Uri.parse(
//         'ws://10.0.2.2:8080/app/ni31bwqnyb4g9pbkk7sn?protocol=7&client=js&version=4.3.1',
//       ),
//     );

//     _channel.stream.listen(
//       (event) async {
//         log('Received event: $event');

//         // إذا تم تأسيس الاتصال
//         if (event.contains('connection_established')) {
//           final decodedEvent = jsonDecode(event);
//           final decodeData = jsonDecode(decodedEvent['data']);
//           final socketId = decodeData['socket_id'];
//           log('Socket ID 5551: $socketId');

//           // const authUrl = '${Url.url}api/broadcasting/auth';
//           final authResponse = await http.post(
//             Uri.parse('${Url.url}api/broadcasting/auth'),
//             headers: {
//               'Authorization': 'Bearer $_token',
//               'Accept': 'application/json',
//               'Content-Type': 'application/json',
//             },
//             body: jsonEncode(
//               {
//                 'channel_name': 'send-message.${_chat_id}',
//                 'socket_id': socketId
//               },
//             ),
//           );

//           if (authResponse.statusCode == 200) {
//             final authData = jsonDecode(authResponse.body);
//             log('Auth data: $authData');
//             _channel.sink.add(jsonEncode({
//               "event": "pusher:subscribe",
//               "data": {
//                 "channel": "send-message.$_chat_id",
//                 "auth": authData['auth'].toString(),
//               },
//             }));
//           } else {
//             log('Failed to authenticate: ${authResponse.body}');
//           }
//         }

//         // معالجة الأحداث الأخرى
//         try {
//           final decodedEvent = jsonDecode(event);
//           log('Decoded event3231: $decodedEvent');
//           if (decodedEvent is Map<String, dynamic>) {
//             log('Decoded event:212121 $decodedEvent');

//             if (decodedEvent.containsKey('event') &&
//                 decodedEvent['event'] == 'sendMessage') {
//               log('Decoded event:3131313 $decodedEvent');
//               if (mounted) {
//                 setState(() {
//                   final data = jsonDecode(decodedEvent['data']);
//                   log(data);

//                   Get.snackbar(
//                     "",
//                     'sssssssssssssssssss'.tr,
//                     colorText: AppColors.white,
//                   );
//                   // playNotificationSound();
//                 });
//               }
//             }
//           }
//         } catch (e) {
//           log('Error decoding event: $e');
//         }
//       },
//       onError: (error) {
//         log('WebSocket error: $error');
//       },
//       onDone: () {
//         log('WebSocket connection closed');
//         _reconnect();
//       },
//       cancelOnError: true,
//     );
//   }

//   void _reconnect() {
//     if (_reconnectAttempts < _maxReconnectAttempts) {
//       _reconnectAttempts++;
//       log('Attempting to reconnect... ($_reconnectAttempts)');
//       Future.delayed(_reconnectDelay, () {
//         _connectToWebSocket();
//       });
//     } else {
//       log('Max reconnect attempts reached. Giving up.');
//     }
//   }

//   @override
//   void dispose() {
//     _channel.sink.close();
//     // _channel2.sink.close();
//     super.dispose();
//   }

//   Future<void> fetchData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var userId = prefs.getString('Id');
//     var token = prefs.getString('token');
//     log('$userId');
//     log('$token');

//     if (userId == null || token == null) {
//       log('خطأ: لم يتم العثور على userId أو token في SharedPreferences');
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }

//     try {
//       var response = await http.get(
//         Uri.parse('${Url.url}api/movements/driver-request/$userId'),
//         headers: <String, String>{
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       log('Response Status Code: ${response.statusCode}');
//       log('Response Body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseBody = jsonDecode(response.body);

//         // تحقق من وجود المفتاح "data" في الـ responseBody
//         if (responseBody != null && responseBody.isNotEmpty) {
//           setState(() {
//             data = responseBody;
//           });
//           log('Data: $data');

//           // حفظ المعلومات في SharedPreferences
//           await prefs.setString('request_id', data['request_id']);
//           await prefs.setString('chat_id', data['chat_id']);
//           await prefs.setString('customer_id', data['customer_id']);
//           await prefs.setDouble('price', data['price'].toDouble());
//           await prefs.setString('typeMov', data['type']);
//           await prefs.setString('is_onKM', data['is_onKM'].toString());

//           // التعامل مع الموقع وإضافة الـ Marker
//           final double locationLat = data['location_lat'] is double
//               ? data['location_lat']
//               : double.tryParse(data['location_lat'].toString()) ?? 0.0;
//           final double locationLong = data['location_long'] is double
//               ? data['location_long']
//               : double.tryParse(data['location_long'].toString()) ?? 0.0;

//           if (locationLat != 0.0 && locationLong != 0.0) {
//             setState(() {
//               markers.add(Marker(
//                 markerId: const MarkerId('customerLocation'),
//                 position: LatLng(locationLat, locationLong),
//                 infoWindow: InfoWindow(
//                   title: 'Customer Location',
//                   snippet: 'Lat: $locationLat, Long: $locationLong',
//                 ),
//               ));

//               cameraPosition = CameraPosition(
//                 target: LatLng(locationLat, locationLong),
//                 zoom: 14.0,
//               );

//               if (gms != null) {
//                 gms!.animateCamera(
//                   CameraUpdate.newCameraPosition(cameraPosition),
//                 );
//               }
//             });
//           } else {
//             log('خطأ: إحداثيات الموقع غير صالحة');
//           }
//         } else {
//           log('خطأ: البيانات غير موجودة');
//         }
//       } else {
//         log('خطأ في الاستجابة: ${response.statusCode}');
//       }
//     } catch (error) {
//       log('خطأ في جلب البيانات: $error');
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.blue1, AppColors.blue2],
//               begin: Alignment.topLeft,
//               end: Alignment.topRight,
//             ),
//           ),
//           child: AppBar(
//             title: const CustomText(
//               text: 'طلباتي',
//               fontSize: 24,
//               color: Colors.white,
//               alignment: Alignment.topRight,
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             leading: IconButton(
//               onPressed: () {
//                 Get.back();
//               },
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//             ),
//           ),
//         ),
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue1),
//               ),
//             )
//           : Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   data != null
//                       ? Column(
//                           children: [
//                             const Text(
//                               'تفاصيل الطلب',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.blue1,
//                               ),
//                               textDirection: TextDirection.rtl,
//                             ),
//                             SizedBox(height: 5.h),
//                             Card(
//                               color: AppColors.BackgroundColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12.0),
//                                 side: const BorderSide(color: AppColors.blue1),
//                               ),
//                               child: ListTile(
//                                 title: Text(
//                                   "اسم الزبون: ${data['name'].toString()}",
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16.0,
//                                   ),
//                                   // textDirection: TextDirection.rtl,
//                                 ),
//                                 subtitle: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     CustomText(
//                                       text:
//                                           "رقم الزبون: ${data['phone_number'].toString()}",
//                                       alignment: Alignment.centerRight,
//                                       color: Colors.white,
//                                       fontSize: 16.0,
//                                     ),
//                                     CustomText(
//                                       text:
//                                           "موقع الزبون: ${data['customer_address'].toString()}",
//                                       alignment: Alignment.centerRight,
//                                       color: Colors.white,
//                                       fontSize: 16.0,
//                                     ),
//                                     CustomText(
//                                       text:
//                                           "نوع الرحلة: ${data['type'].toString()}",
//                                       alignment: Alignment.centerRight,
//                                       color: Colors.white,
//                                       fontSize: 16.0,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 10.h),
//                             SizedBox(
//                               height: 300.h,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(16.0),
//                                 child: GoogleMap(
//                                   markers: markers.toSet(),
//                                   initialCameraPosition: cameraPosition,
//                                   mapType: MapType.normal,
//                                   onMapCreated: (mapController) {
//                                     gms = mapController;
//                                   },
//                                   onTap: (LatLng latLng) {
//                                     markers.add(
//                                       Marker(
//                                         markerId: const MarkerId("1"),
//                                         position: LatLng(
//                                             latLng.latitude, latLng.longitude),
//                                       ),
//                                     );
//                                     setState(() {});
//                                   },
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 25.h),
//                           ],
//                         )
//                       : Card(
//                           color: AppColors.BackgroundColor,
//                           margin: const EdgeInsets.all(16.0),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0),
//                             side: const BorderSide(color: AppColors.blue2),
//                           ),
//                           elevation: 5,
//                           child: const Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: CustomText(
//                               text: 'لا يوجد بيانات',
//                               alignment: Alignment.center,
//                             ),
//                           ),
//                         ),
//                   if (data != null)
//                     CustomButton(
//                       width: 220.w,
//                       onPressed: () {
//                         LocationService.startSendingLocationPeriodically();
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (c) => const Order()),
//                         );
//                       },
//                       text: "ابدأ رحلتك",
//                     )
//                 ],
//               ),
//             ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:driver_taxi/components/custom_botton.dart';
import 'package:driver_taxi/components/custom_text.dart';
import 'package:driver_taxi/utils/app_colors.dart';
import 'package:driver_taxi/utils/global.dart';
import 'package:driver_taxi/location/location.dart';
import 'package:driver_taxi/utils/url.dart';
import 'package:driver_taxi/view/screen/auth/UserPreference.dart';
import 'package:driver_taxi/view/screen/order.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});
  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String apiUrl = apiPath_addition;
  // ignore: prefer_typing_uninitialized_variables
  var data;
  bool isLoading = true;
  GoogleMapController? gms;
  List<Marker> markers = [];
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(33.504307, 36.304141),
    zoom: 10.4746,
  );

  @override
  void initState() {
    super.initState();
    fetchData();
    loadUserData();
  }

  String? id;
  String? _token;
  String? _customer_id;
  String? _chat_id;

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
        log('id:$id');
        log('_token:$_token');
        log('_chat_id:$_chat_id');
        log('_customer_id:$_customer_id');
      } else {
        log('Failed to load user data: id or token is null');
      }
    });
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('Id');
    var token = prefs.getString('token');
    log('$userId');
    log('$token');

    if (userId == null || token == null) {
      log('خطأ: لم يتم العثور على userId أو token في SharedPreferences');
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
          await prefs.setDouble(
              'price', data['price']?.toDouble() ?? 0.0); 
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
            log('خطأ: إحداثيات الموقع غير صالحة');
          }
        } else {
          log('خطأ: البيانات غير موجودة');
        }
      } else {
        log('خطأ في الاستجابة: ${response.statusCode}');
      }
    } catch (error) {
      log('خطأ في جلب البيانات: $error');
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
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                  // textDirection: TextDirection.rtl,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CustomText(
                                      text:
                                          "رقم الزبون: ${data['phone_number'].toString()}",
                                      alignment: Alignment.centerRight,
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                    CustomText(
                                      text:
                                          "موقع الزبون: ${data['customer_address'].toString()}",
                                      alignment: Alignment.centerRight,
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                    CustomText(
                                      text:
                                          "الوجهة المراد الذهاب إليها : ${data['destination_address'].toString()}",
                                      alignment: Alignment.centerRight,
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                    CustomText(
                                      text:
                                          "نوع الرحلة: ${data['type'].toString()}",
                                      alignment: Alignment.centerRight,
                                      color: Colors.white,
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
                                  onTap: (LatLng latLng) {
                                    markers.add(
                                      Marker(
                                        markerId: const MarkerId("1"),
                                        position: LatLng(
                                            latLng.latitude, latLng.longitude),
                                      ),
                                    );
                                    setState(() {});
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
                      width: 220.w,
                      onPressed: () {
                        LocationService.startSendingLocationPeriodically();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const Order()),
                        );
                      },
                      text: "ابدأ رحلتك",
                    )
                ],
              ),
            ),
    );
  }
}

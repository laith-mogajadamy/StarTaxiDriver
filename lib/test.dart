// import 'dart:convert';

// import 'package:driver_taxi/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class TestRealTime extends StatefulWidget {
//   const TestRealTime({super.key});

//   @override
//   State<TestRealTime> createState() => _TestRealTimeState();
// }

// class _TestRealTimeState extends State<TestRealTime> {
//   late final WebSocketChannel channel;
//   String df = "0";
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the WebSocket channel with the correct Uri
//     channel = WebSocketChannel.connect(
//       Uri.parse('ws://10.0.2.2:8080/ws/btcusdt@trade'),
//     );

//     // Call the method to listen for messages
//     _listenForMessages();
//   }

//   void _listenForMessages() {
//     channel.stream.listen((message) {
//       // Process the incoming message
//       Map Getdata = jsonDecode(message);
//       setState(() {
//         df = Getdata['p'];
//       });
//       // print(Getdata['p']);
//     }, onError: (error) {
//       print('Error: $error');
//     }, onDone: () {
//       print('Connection closed');
//     });
//   }

//   @override
//   void dispose() {
//     // Clean up the channel when the widget is disposed
//     channel.sink.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("data", style: TextStyle(color: AppColors.white)),
//             Text(df, style: TextStyle(color: AppColors.white)),
//           ],
//         ),
//       ),
//     );
//   }
// }

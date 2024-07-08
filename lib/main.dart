import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_arduino/main_page.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

// class DiscoveryPage extends StatefulWidget {
//   /// If true, discovery starts on page start, otherwise user must press action button.
//   final bool start;

//   const DiscoveryPage({this.start = true});

//   @override
//   _DiscoveryPage createState() => new _DiscoveryPage();
// }

// class _DiscoveryPage extends State<DiscoveryPage> {
//   StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
//   List<BluetoothDiscoveryResult> results =
//       List<BluetoothDiscoveryResult>.empty(growable: true);
//   bool isDiscovering = true;

//   _DiscoveryPage();

//   @override
//   void initState() {
//     super.initState();

//     isDiscovering = widget.start;
//     if (isDiscovering) {
//       _startDiscovery();
//     }
//   }

//   void _restartDiscovery() {
//     setState(() {
//       results.clear();
//       isDiscovering = true;
//     });

//     _startDiscovery();
//   }

//   void _startDiscovery() {
//     _streamSubscription =
//         FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
//       setState(() {
//         final existingIndex = results.indexWhere(
//             (element) => element.device.address == r.device.address);
//         if (existingIndex >= 0)
//           results[existingIndex] = r;
//         else
//           results.add(r);
//       });
//     });

//     _streamSubscription!.onDone(() {
//       setState(() {
//         isDiscovering = false;
//       });
//     });
//   }

//   // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

//   @override
//   void dispose() {
//     // Avoid memory leak (`setState` after dispose) and cancel discovery
//     _streamSubscription?.cancel();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: isDiscovering
//             ? const Text('Discovering devices')
//             : const Text('Discovered devices'),
//         actions: <Widget>[
//           isDiscovering
//               ? FittedBox(
//                   child: Container(
//                     margin: const EdgeInsets.all(16.0),
//                     child: const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   ),
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.replay),
//                   onPressed: _restartDiscovery,
//                 )
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: results.length,
//         itemBuilder: (BuildContext context, index) {
//           BluetoothDiscoveryResult result = results[index];
//           final device = result.device;
//           final address = device.address;
//           return BluetoothDeviceListEntry(
//             device: device,
//             rssi: result.rssi,
//             onTap: () {
//               Navigator.of(context).pop(result.device);
//             },
//             onLongPress: () async {
//               try {
//                 bool bonded = false;
//                 if (device.isBonded) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text('Unbonding from ${device.address}...'),
//                   ));
//                   // print('Unbonding from ${device.address}...');
//                   await FlutterBluetoothSerial.instance
//                       .removeDeviceBondWithAddress(address);
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content:
//                         Text('Unbonding from ${device.address} has succed'),
//                   ));
//                   // print('Unbonding from ${device.address} has succed');
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text('Bonding with ${device.address}...'),
//                   ));
//                   // print('Bonding with ${device.address}...');
//                   bonded = (await FlutterBluetoothSerial.instance
//                       .bondDeviceAtAddress(address))!;

//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(
//                         'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.'),
//                   ));
//                   // print(
//                   //     'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.');
//                 }
//                 setState(() {
//                   results[results.indexOf(result)] = BluetoothDiscoveryResult(
//                       device: BluetoothDevice(
//                         name: device.name ?? '',
//                         address: address,
//                         type: device.type,
//                         bondState: bonded
//                             ? BluetoothBondState.bonded
//                             : BluetoothBondState.none,
//                       ),
//                       rssi: result.rssi);
//                 });
//               } catch (ex) {
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Text('Error occured while bonding'),
//                       content: Text("${ex.toString()}"),
//                       actions: <Widget>[
//                         new TextButton(
//                           child: new Text("Close"),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class BluetoothDeviceListEntry extends ListTile {
//   BluetoothDeviceListEntry({
//     required BluetoothDevice device,
//     int? rssi,
//     GestureTapCallback? onTap,
//     GestureLongPressCallback? onLongPress,
//     bool enabled = true,
//   }) : super(
//           onTap: onTap,
//           onLongPress: onLongPress,
//           enabled: enabled,
//           leading: const Icon(
//               Icons.devices), // @TODO . !BluetoothClass! class aware icon
//           title: Text(device.name ?? ""),
//           subtitle: Text(device.address.toString()),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               rssi != null
//                   ? Container(
//                       margin: new EdgeInsets.all(8.0),
//                       child: DefaultTextStyle(
//                         style: _computeTextStyle(rssi),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             Text(rssi.toString()),
//                             const Text('dBm'),
//                           ],
//                         ),
//                       ),
//                     )
//                   : Container(width: 0, height: 0),
//               device.isConnected
//                   ? const Icon(Icons.import_export)
//                   : Container(width: 0, height: 0),
//               device.isBonded
//                   ? const Icon(Icons.link)
//                   : Container(width: 0, height: 0),
//             ],
//           ),
//         );

//   static TextStyle _computeTextStyle(int rssi) {
//     /**/ if (rssi >= -35)
//       return TextStyle(color: Colors.greenAccent[700]);
//     else if (rssi >= -45)
//       return TextStyle(
//           color: Color.lerp(
//               Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
//     else if (rssi >= -55)
//       return TextStyle(
//           color: Color.lerp(
//               Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
//     else if (rssi >= -65)
//       return TextStyle(
//           color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
//     else if (rssi >= -75)
//       return TextStyle(
//           color: Color.lerp(
//               Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
//     else if (rssi >= -85)
//       return TextStyle(
//           color: Color.lerp(
//               Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
//     else
//       /*code symmetry*/
//       return const TextStyle(color: Colors.redAccent);
//   }
// }

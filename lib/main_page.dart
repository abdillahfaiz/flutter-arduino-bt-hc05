import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<BluetoothDevice> devices = [];
  String deviceConnected = '';
  BluetoothConnection? connection;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;

  @override
  void initState() {
    super.initState();
    startDiscovery();
  }

  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();
    connection?.dispose();
    super.dispose();
  }

  void startDiscovery() {
    FlutterBluetoothSerial.instance.getBondedDevices().then((value) {
      setState(() {
        devices = value;
      });
    });

    _discoveryStreamSubscription = FlutterBluetoothSerial.instance
        .startDiscovery()
        .listen((result) {
      setState(() {
        devices.add(result.device);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: startDiscovery,
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () async {
              await FlutterBluetoothSerial.instance.cancelDiscovery();
              _discoveryStreamSubscription?.cancel();
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: FlutterBluetoothSerial.instance.requestEnable(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devices[index].name ?? 'Unknown device'),
                    subtitle: Text(devices[index].address),
                    trailing: deviceConnected == devices[index].name ? const Text('Connected', style: TextStyle(
                    color: Colors.green,
                    ),) : null,
                    onTap: deviceConnected == devices[index].name
                        ? () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 26),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10.0),
                                        Text(
                                          'Connected to $deviceConnected',
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 20.0),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  try {
                                                    connection?.output
                                                        .add(utf8.encode('1' "\r\n"));
                                                    await connection?.output
                                                        .allSent;
                                                  } catch (e) {
                                                    log('Error sending 1: $e');
                                                  }
                                                },
                                                child: const Text('Send 1'),
                                              ),
                                            ),
                                            const SizedBox(width: 20.0),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  try {
                                                    connection?.output
                                                        .add(utf8.encode('0' "\r\n"));
                                                    await connection?.output
                                                        .allSent;
                                                  } catch (e) {
                                                    log('Error sending 0: $e');
                                                  }
                                                },
                                                child: const Text('Send 0'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                connection?.finish();
                                                setState(() {
                                                  deviceConnected = '';
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Disconnect')),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }
                        : () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Connecting to ${devices[index].name}...',
                                ),
                              ),
                            );
                            try {
                              connection = await BluetoothConnection.toAddress(
                                  devices[index].address);
                              if (connection!.isConnected) {
                                setState(() {
                                  deviceConnected = devices[index].name ?? '';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Connected to ${devices[index].name}',
                                    ),
                                  ),
                                );
                              }
                            } catch (exception) {
                              log(exception.toString());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    'Cannot connect, exception occurred: $exception',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Error'),
              );
            }
          }),
    );
  }
}




// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter_arduino/device.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   List<BluetoothDevice> devices = [];
//   String deviceConnected = '';
//   BluetoothConnection? connection;

//   StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;

//   @override
//   void initState() {
//     super.initState();
//     startDiscovery();
//   }

//   void startDiscovery() {
//     FlutterBluetoothSerial.instance.getBondedDevices().then((value) {
//       setState(() {
//         devices = value;
//       });
//     });
//     FlutterBluetoothSerial.instance.startDiscovery().listen(
//       (result) {
//         setState(() {
//           devices.add(result.device);
//         });
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Connection'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: startDiscovery,
//           ),
//           IconButton(
//             icon: const Icon(Icons.stop),
//             onPressed: () async {
//               // await FlutterBluetoothSerial.instance.cancelDiscovery();
//               // _discoveryStreamSubscription?.cancel();
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder(
//           future: FlutterBluetoothSerial.instance.requestEnable(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (snapshot.connectionState == ConnectionState.done) {
//               return ListView.builder(
//                 itemCount: devices.length,
//                 itemBuilder: (context, index) {
//                   return BluetoothDeviceListEntry(
//                     onTap: deviceConnected == devices[index].name
//                         ? () {
//                             showModalBottomSheet(
//                                 context: context,
//                                 showDragHandle: true,
//                                 scrollControlDisabledMaxHeightRatio: 0.3,
//                                 builder: (context) {
//                                   return Container(
//                                     margin: const EdgeInsets.symmetric(
//                                         horizontal: 26),
//                                     width: double.infinity,
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const SizedBox(
//                                           height: 10.0,
//                                         ),
//                                         Text(
//                                           'Connected to $deviceConnected',
//                                           style: const TextStyle(
//                                               fontSize: 22,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                         const SizedBox(
//                                           height: 20.0,
//                                         ),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: ElevatedButton(
//                                                 onPressed: () async {
//                                                   connection?.output.add(utf8.encode('1' "\r\n"));
//                                                   await connection?.output.allSent;
                                                  
//                                                 },
//                                                 child: const Text('Send 1'),
//                                               ),
//                                             ),
//                                             const SizedBox(
//                                               width: 20.0,
//                                             ),
//                                             Expanded(
//                                               child: ElevatedButton(
//                                                 onPressed: () async {
//                                                   connection?.output.add(utf8.encode('0' "\r\n"));
//                                                   await connection?.output.allSent;
//                                                 },
//                                                 child: const Text('Send 0'),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                           height: 10.0,
//                                         ),
//                                         SizedBox(
//                                           width: double.infinity,
//                                           child: ElevatedButton(
//                                               onPressed: () {
//                                                 connection?.finish();
//                                                 setState(() {
//                                                   deviceConnected = '';
//                                                 });
//                                                 Navigator.pop(context);
//                                               },
//                                               child: const Text('Disconnect')),
//                                         )
//                                       ],
//                                     ),
//                                   );
//                                 });
//                           }
//                         : () async {
//                             // Some simplest connection :F
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'Connecting to ${devices[index].name}...',
//                                 ),
//                               ),
//                             );
//                             try {
//                               connection = await BluetoothConnection.toAddress(
//                                   devices[index].address);
//                               if (connection!.isConnected) {
//                                 setState(() {
//                                   deviceConnected = devices[index].name ?? '';
//                                 });
//                               }
//                               // connection.input?.listen((Uint8List data) {
//                               //   ScaffoldMessenger.of(context).showSnackBar(
//                               //     SnackBar(
//                               //       content: Text(
//                               //         'Data incoming: ${ascii.decode(data)}',
//                               //       ),
//                               //     ),
//                               //   );
//                               //   connection.output.add(data); // Sending data

//                               //   if (ascii.decode(data).contains('!')) {
//                               //     connection.finish(); // Closing connection
//                               //     ScaffoldMessenger.of(context).showSnackBar(
//                               //       const SnackBar(
//                               //         content: Text(
//                               //           'Disconnecting by host',
//                               //         ),
//                               //       ),
//                               //     );
//                               //   }
//                               // }).onDone(() {
//                               //   ScaffoldMessenger.of(context).showSnackBar(
//                               //     const SnackBar(
//                               //       content: Text(
//                               //         'Disconnected by remote request',
//                               //       ),
//                               //     ),
//                               //   );
//                               // });
//                             } catch (exception) {
//                               log(exception.toString());
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                  SnackBar(
//                                   backgroundColor: Colors.red,
//                                   content: Text(
//                                     'Cannot connect, exception occured, error : $exception',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                     device: devices[index],
//                     deviceConnected: deviceConnected,
//                   );
//                 },
//               );
//             } else {
//               return const Center(
//                 child: Text('Error'),
//               );
//             }
//           }),
//     );
//   }
// }

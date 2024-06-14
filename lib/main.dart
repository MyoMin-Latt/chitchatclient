import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

void main() {
  runApp(const ClientApp());
}

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Client App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ClientScreen(),
    );
  }
}

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  ClientScreenState createState() => ClientScreenState();
}

class ClientScreenState extends State<ClientScreen> {
  final TextEditingController _controller = TextEditingController();
  late Socket _socket;
  List<String> _messages = [];
  final info = NetworkInfo();
  String? wifiIP;
  bool isConnectToServer = false;

  @override
  void initState() {
    super.initState();
    // _connectToServer();
  }

  getWifiInfo() async {
    wifiIP = await info.getWifiIP();
    // print('Found wifiIP: ${wifiIP}');
    if (wifiIP != null) {
      final subnet = wifiIP!.substring(0, wifiIP!.lastIndexOf("."));
      // print('Found subnet: ${subnet}');
      final stream = NetworkAnalyzer.discover2(subnet, 4040);
      stream.listen((NetworkAddress addr) {
        if (addr.exists) {
          print('exist');
          // print('Found device: ${addr.ip}');
          isConnectToServer = true;
          setState(() {});
          _connectToServer(addr.ip, 4040);
        }
        // else {
        //   if (isConnectToServer) {
        //     isConnectToServer = false;
        //   }
        //   // print('not exist');
        //   // isConnectToServer = false;
        //   // setState(() {});
        // }
      });
    }
    print('isConnectToServer => $isConnectToServer');
    setState(() {});
  }

  void _connectToServer(String ipaddress, int port) async {
    _socket = await Socket.connect(ipaddress, port);
    print('Running at : ${_socket.address.address}, Port : ${_socket.port}');
    // port is different
    // Running at : 192.168.100.9, Port : 38600
    _socket.listen((data) {
      setState(() {
        _messages.add(String.fromCharCodes(data).trim());
      });
    });
  }

  void _disConnectToServer() async {
    _socket.close();
    setState(() {
      isConnectToServer = false;
    });
  }

  void _sendMessage(String message) {
    _socket.write(message);
    setState(() {
      _messages.add('Client: $message');
    });
    _controller.clear();
  }

  @override
  void dispose() {
    _socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Client App'),
            Text(wifiIP ?? "Get IP Address"),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: isConnectToServer ? _disConnectToServer : getWifiInfo,
              icon: isConnectToServer
                  ? const Icon(
                      Icons.stop,
                      color: Colors.red,
                    )
                  : const Icon(
                      Icons.play_arrow,
                      color: Colors.green,
                    )),
          const SizedBox(width: 18),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Send a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() async {
    _socket = await Socket.connect('192.168.100.9', 4040);
    print('Running at : ${_socket.address.address}, Port : ${_socket.port}');
    // port is different
    // Running at : 192.168.100.9, Port : 38600
    _socket.listen((data) {
      setState(() {
        _messages.add(String.fromCharCodes(data).trim());
      });
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
        title: const Text('Client App'),
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

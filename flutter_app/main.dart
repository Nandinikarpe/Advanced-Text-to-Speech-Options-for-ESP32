import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Text to Speech',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  String _status = '';
  bool _isLoading = false;

  // Replace with the IP address of your ESP32
  final String _esp32IpAddress = '192.168.1.100'; 

  Future<void> _sendTextToESP32() async {
    if (_textController.text.isEmpty) {
      setState(() {
        _status = 'Please enter some text';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Sending text to ESP32...';
    });

    try {
      final response = await http.post(
        Uri.parse('http://$_esp32IpAddress/speak'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': _textController.text}),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200) {
          _status = 'Text sent successfully!';
        } else {
          _status = 'Failed to send text. Status code: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Text to Speech'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter text to speak',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendTextToESP32,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Send to ESP32'),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(
                color: _status.contains('Error') || _status.contains('Failed')
                    ? Colors.red
                    : Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Make sure your ESP32 is connected to the same WiFi network',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '2. Enter the text you want to speak in the field above',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '3. Press the "Send to ESP32" button',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '4. The ESP32 will convert the text to speech and play it',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
} 
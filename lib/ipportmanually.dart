import 'dart:io';

import 'package:flutter/material.dart';

class ManualAddPage extends StatefulWidget {
  @override
  _ManualAddPageState createState() => _ManualAddPageState();
}

class _ManualAddPageState extends State<ManualAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final ip = _ipController.text.trim();
      final port = int.parse(_portController.text.trim());

      try {
        final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
        socket.destroy();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully connected to $ip:$port')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to $ip:$port')),
        );
      }
    }
  }


  String? _validateIp(String? value) {
    if (value == null || value.isEmpty) return 'Please enter IP address';
    final regex = RegExp(
        r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$'); // simple IPv4 validation
    if (!regex.hasMatch(value)) return 'Enter a valid IPv4 address';
    return null;
  }

  String? _validatePort(String? value) {
    if (value == null || value.isEmpty) return 'Please enter port number';
    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) return 'Enter valid port (1-65535)';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manual IP & Port',
          style: TextStyle( fontSize: 18 , color: Colors.white), // Set the title text color to white
        ),
        backgroundColor: const Color(0xFF01081C),
        centerTitle: true,
        iconTheme: const IconThemeData( size: 25,  color: Colors.white), // Set the back icon color to white
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ipController,
                cursorColor: const Color(0xFF01081C), // Cursor color
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  labelStyle: const TextStyle(color: Color(0xFF01081C)), // Label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(08), // Rounded corners
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(08),
                    borderSide: const BorderSide(color: Color(0xFF12e19f), width: 1), // Focused border color & width
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: _validateIp,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _portController,
                cursorColor: const Color(0xFF01081C),
                decoration: InputDecoration(
                  labelText: 'Port',
                  labelStyle: const TextStyle(color: Color(0xFF01081C)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(08),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(08),
                    borderSide: const BorderSide(color: Color(0xFF12e19f), width: 1),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: _validatePort,
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01081C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(fontSize: 16, color: Color(0xFF12e19f)),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
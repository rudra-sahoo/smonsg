import 'package:flutter/material.dart';

class EndToEndEncryptionInfo extends StatelessWidget {
  const EndToEndEncryptionInfo({super.key});

  void _showEncryptionInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'End-to-End Encryption',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Your conversations are securely encrypted end-to-end, meaning that only you and the person you are communicating with can read what is sent. Not even the service provider can access your messages.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEncryptionInfo(context),
      child: const Center(
        child: Text(
          'End to End encrypted',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

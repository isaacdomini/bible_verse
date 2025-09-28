import 'package:flutter/material.dart';

class CastScreen extends StatefulWidget {
  const CastScreen({super.key});

  @override
  State<CastScreen> createState() => _CastScreenState();
}

class _CastScreenState extends State<CastScreen> {
  String _currentReference = '';
  String _currentVerse = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_currentReference.isNotEmpty) ...[
              Text(
                _currentReference,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
            if (_currentVerse.isNotEmpty)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      _currentVerse,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              const Text(
                'Waiting for Bible verse...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  void updateVerse(String reference, String verse) {
    setState(() {
      _currentReference = reference;
      _currentVerse = verse;
    });
  }
}
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'bible_service.dart';
import 'cast_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;
  String _currentVerse = '';
  String _currentReference = '';
  bool _isLoading = false;
  String _recognizedText = '';
  
  final BibleService _bibleService = BibleService();
  final CastService _castService = CastService();
  bool _isCasting = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required for voice recognition')),
      );
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (val) => setState(() {}),
      onError: (val) => setState(() {
        _isListening = false;
      }),
    );
    
    setState(() {
      _speechEnabled = available;
    });
  }

  void _startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    await _speech.listen(
      onResult: (val) async {
        setState(() {
          _recognizedText = val.recognizedWords;
        });
        
        // Check if we have a potential Bible verse reference
        if (val.hasConfidenceRating && val.confidence > 0.8) {
          String reference = _extractBibleReference(val.recognizedWords);
          if (reference.isNotEmpty) {
            await _lookupVerse(reference);
            _stopListening();
          }
        }
      },
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  String _extractBibleReference(String text) {
    // Simple regex patterns for common Bible verse formats
    List<String> patterns = [
      r'\b([1-3]?\s*[A-Za-z]+)\s+(\d+):(\d+)\b', // John 3:16, 1 Corinthians 13:4
      r'\b([1-3]?\s*[A-Za-z]+)\s+(\d+)\s+(\d+)\b', // John 3 16
      r'\b([1-3]?\s*[A-Za-z]+)\s+chapter\s+(\d+)\s+verse\s+(\d+)\b', // John chapter 3 verse 16
    ];

    for (String pattern in patterns) {
      RegExp regex = RegExp(pattern, caseSensitive: false);
      Match? match = regex.firstMatch(text);
      if (match != null) {
        String book = match.group(1)?.trim() ?? '';
        String chapter = match.group(2) ?? '';
        String verse = match.group(3) ?? '';
        return '$book $chapter:$verse';
      }
    }
    
    return '';
  }

  Future<void> _lookupVerse(String reference) async {
    setState(() {
      _isLoading = true;
      _currentReference = reference;
    });

    try {
      String verse = await _bibleService.getVerse(reference);
      setState(() {
        _currentVerse = verse;
        _isLoading = false;
      });
      
      // Update cast screen if casting
      if (_isCasting) {
        _castService.updateVerseDisplay(reference, verse);
      }
    } catch (e) {
      setState(() {
        _currentVerse = 'Could not find verse: $reference';
        _isLoading = false;
      });
    }
  }

  void _toggleCast() async {
    if (_isCasting) {
      await _castService.stopCasting();
      setState(() {
        _isCasting = false;
      });
    } else {
      bool success = await _castService.startCasting();
      setState(() {
        _isCasting = success;
      });
      
      if (success && _currentVerse.isNotEmpty) {
        _castService.updateVerseDisplay(_currentReference, _currentVerse);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Bible Verse'),
        actions: [
          IconButton(
            icon: Icon(_isCasting ? Icons.cast_connected : Icons.cast),
            onPressed: _toggleCast,
            tooltip: _isCasting ? 'Stop Casting' : 'Start Casting',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Say a Bible verse reference to see it displayed',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            if (_isListening)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Listening...',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            if (_recognizedText.isNotEmpty && _isListening)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Recognized: $_recognizedText',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_currentVerse.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _currentReference,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _currentVerse,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            if (_isCasting)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cast_connected, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Casting to external display'),
                  ],
                ),
              ),
            if (!_speechEnabled)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Speech recognition not available',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechEnabled
            ? (_isListening ? _stopListening : _startListening)
            : null,
        tooltip: _isListening ? 'Stop Listening' : 'Start Listening',
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
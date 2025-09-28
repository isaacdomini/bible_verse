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
    // Normalize the text for better matching
    String normalizedText = text.toLowerCase().trim();
    
    // Common Bible verse format patterns
    List<String> patterns = [
      r'\b([1-3]?\s*[a-z]+)\s+(\d+):(\d+)(?:-(\d+))?\b', // John 3:16, John 3:16-17
      r'\b([1-3]?\s*[a-z]+)\s+(\d+)\s+(\d+)\b', // John 3 16
      r'\b([1-3]?\s*[a-z]+)\s+chapter\s+(\d+)\s+verse\s+(\d+)\b', // John chapter 3 verse 16
      r'\b([1-3]?\s*[a-z]+)\s+(\d+)\s*[:]\s*(\d+)\b', // Handles spacing around colon
    ];

    for (String pattern in patterns) {
      RegExp regex = RegExp(pattern, caseSensitive: false);
      Match? match = regex.firstMatch(normalizedText);
      if (match != null) {
        String book = _normalizeBookName(match.group(1)?.trim() ?? '');
        String chapter = match.group(2) ?? '';
        String verse = match.group(3) ?? '';
        String endVerse = match.group(4) ?? '';
        
        if (book.isNotEmpty && chapter.isNotEmpty && verse.isNotEmpty) {
          String reference = '$book $chapter:$verse';
          if (endVerse.isNotEmpty) {
            reference += '-$endVerse';
          }
          return reference;
        }
      }
    }
    
    // Try to extract partial references and suggest corrections
    List<String> fallbackPatterns = [
      r'\b([a-z]+)\s+(\d+)\b', // Just book and chapter
      r'\b([1-3]?\s*[a-z]+)\b', // Just book name
    ];
    
    for (String pattern in fallbackPatterns) {
      RegExp regex = RegExp(pattern, caseSensitive: false);
      Match? match = regex.firstMatch(normalizedText);
      if (match != null) {
        String book = _normalizeBookName(match.group(1)?.trim() ?? '');
        if (_isValidBookName(book)) {
          String chapter = match.group(2) ?? '1';
          // Suggest a default verse if only book/chapter provided
          return '$book $chapter:1';
        }
      }
    }
    
    return '';
  }

  String _normalizeBookName(String book) {
    // Handle common variations and abbreviations
    Map<String, String> bookMappings = {
      'john': 'John',
      'romans': 'Romans',
      'philippians': 'Philippians',
      'psalms': 'Psalms',
      'psalm': 'Psalms',
      'jeremiah': 'Jeremiah',
      'corinthians': 'Corinthians',
      '1 corinthians': '1 Corinthians',
      'first corinthians': '1 Corinthians',
      '2 corinthians': '2 Corinthians',
      'second corinthians': '2 Corinthians',
      'matthew': 'Matthew',
      'proverbs': 'Proverbs',
      'isaiah': 'Isaiah',
      'genesis': 'Genesis',
      'exodus': 'Exodus',
      'leviticus': 'Leviticus',
      'numbers': 'Numbers',
      'deuteronomy': 'Deuteronomy',
      'joshua': 'Joshua',
      'judges': 'Judges',
      'ruth': 'Ruth',
      '1 samuel': '1 Samuel',
      '2 samuel': '2 Samuel',
      '1 kings': '1 Kings',
      '2 kings': '2 Kings',
      '1 chronicles': '1 Chronicles',
      '2 chronicles': '2 Chronicles',
      'ezra': 'Ezra',
      'nehemiah': 'Nehemiah',
      'esther': 'Esther',
      'job': 'Job',
      'ecclesiastes': 'Ecclesiastes',
      'song of solomon': 'Song of Solomon',
      'lamentations': 'Lamentations',
      'ezekiel': 'Ezekiel',
      'daniel': 'Daniel',
      'hosea': 'Hosea',
      'joel': 'Joel',
      'amos': 'Amos',
      'obadiah': 'Obadiah',
      'jonah': 'Jonah',
      'micah': 'Micah',
      'nahum': 'Nahum',
      'habakkuk': 'Habakkuk',
      'zephaniah': 'Zephaniah',
      'haggai': 'Haggai',
      'zechariah': 'Zechariah',
      'malachi': 'Malachi',
      'mark': 'Mark',
      'luke': 'Luke',
      'acts': 'Acts',
      'galatians': 'Galatians',
      'ephesians': 'Ephesians',
      'colossians': 'Colossians',
      '1 thessalonians': '1 Thessalonians',
      '2 thessalonians': '2 Thessalonians',
      '1 timothy': '1 Timothy',
      '2 timothy': '2 Timothy',
      'titus': 'Titus',
      'philemon': 'Philemon',
      'hebrews': 'Hebrews',
      'james': 'James',
      '1 peter': '1 Peter',
      '2 peter': '2 Peter',
      '1 john': '1 John',
      '2 john': '2 John',
      '3 john': '3 John',
      'jude': 'Jude',
      'revelation': 'Revelation',
    };

    String normalized = book.toLowerCase().trim();
    return bookMappings[normalized] ?? book;
  }

  bool _isValidBookName(String book) {
    List<String> validBooks = [
      'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 
      'Judges', 'Ruth', '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', 
      '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther', 'Job', 
      'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah', 
      'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 
      'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 
      'Haggai', 'Zechariah', 'Malachi', 'Matthew', 'Mark', 'Luke', 'John', 
      'Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 
      'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', 
      '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 
      'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 
      'Jude', 'Revelation'
    ];
    
    return validBooks.contains(book);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Header instruction
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mic,
                      size: 48,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Say a Bible verse reference to see it displayed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try: "John 3:16", "Romans 8:28", "Psalms 23:1"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Status indicators
              if (_isListening) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Listening...',
                        style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              if (_recognizedText.isNotEmpty && _isListening) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I heard:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _recognizedText,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (_isCasting) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cast_connected, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Casting to external display',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Main content area
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Looking up verse...', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      )
                    : _currentVerse.isNotEmpty 
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                if (_currentReference.isNotEmpty) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _currentReference,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _currentVerse,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      height: 1.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tap the microphone to start',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),

              // Error message for speech not enabled
              if (!_speechEnabled)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(height: 8),
                      Text(
                        'Speech recognition not available',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Please check microphone permissions',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _speechEnabled
            ? (_isListening ? _stopListening : _startListening)
            : null,
        tooltip: _isListening ? 'Stop Listening' : 'Start Listening',
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isListening
              ? const Icon(Icons.mic, key: ValueKey('mic_on'), size: 32)
              : Icon(
                  Icons.mic_none,
                  key: const ValueKey('mic_off'),
                  size: 32,
                  color: _speechEnabled ? null : Colors.grey,
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
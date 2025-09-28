import 'dart:convert';
import 'package:http/http.dart' as http;

class BibleService {
  // Using ESV API as an example - you can switch to other Bible APIs
  static const String _baseUrl = 'https://api.esv.org/v3/passage/text/';
  static const String _apiKey = 'your-api-key-here'; // You need to get this from ESV API
  
  // Fallback: Bible.com API Gateway (free but limited)
  static const String _fallbackUrl = 'https://bible-api.com/';

  Future<String> getVerse(String reference) async {
    try {
      // First try the fallback API which doesn't need authentication
      return await _getVerseFromBibleApi(reference);
    } catch (e) {
      // If that fails, try the hardcoded verses for demo
      return _getHardcodedVerse(reference);
    }
  }

  Future<String> _getVerseFromBibleApi(String reference) async {
    // Clean up the reference for the API
    String cleanReference = reference.replaceAll(' ', '%20');
    
    final url = Uri.parse('$_fallbackUrl$cleanReference');
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['text'] != null) {
        return data['text'].toString().trim();
      }
    }
    
    throw Exception('Verse not found');
  }

  String _getHardcodedVerse(String reference) {
    // Fallback verses for demo purposes
    Map<String, String> hardcodedVerses = {
      'john 3:16': 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
      'romans 8:28': 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.',
      'philippians 4:13': 'I can do all this through him who gives me strength.',
      'psalms 23:1': 'The LORD is my shepherd, I lack nothing.',
      'jeremiah 29:11': 'For I know the plans I have for you," declares the LORD, "plans to prosper you and not to harm you, plans to give you hope and a future.',
      '1 corinthians 13:4': 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud.',
      'matthew 5:16': 'In the same way, let your light shine before others, that they may see your good deeds and glorify your Father in heaven.',
      'proverbs 3:5': 'Trust in the LORD with all your heart and lean not on your own understanding;',
      'isaiah 40:31': 'but those who hope in the LORD will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
      'psalm 46:10': 'Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth.',
    };

    String normalizedRef = reference.toLowerCase().trim();
    
    // Try exact match first
    if (hardcodedVerses.containsKey(normalizedRef)) {
      return hardcodedVerses[normalizedRef]!;
    }

    // Try partial matches
    for (String key in hardcodedVerses.keys) {
      if (key.contains(normalizedRef) || normalizedRef.contains(key)) {
        return hardcodedVerses[key]!;
      }
    }

    // If no match found, return a message
    return 'Sorry, I could not find the verse "$reference". Please try a different reference like "John 3:16" or "Romans 8:28".';
  }

  List<String> getSuggestedVerses() {
    return [
      'John 3:16',
      'Romans 8:28',
      'Philippians 4:13',
      'Psalms 23:1',
      'Jeremiah 29:11',
      '1 Corinthians 13:4',
      'Matthew 5:16',
      'Proverbs 3:5',
      'Isaiah 40:31',
      'Psalm 46:10',
    ];
  }
}
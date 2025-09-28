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
      'genesis 1:1': 'In the beginning God created the heavens and the earth.',
      'matthew 28:19': 'Therefore go and make disciples of all nations, baptizing them in the name of the Father and of the Son and of the Holy Spirit,',
      'acts 1:8': 'But you will receive power when the Holy Spirit comes on you; and you will be my witnesses in Jerusalem, and in all Judea and Samaria, and to the ends of the earth.',
      'romans 3:23': 'for all have sinned and fall short of the glory of God,',
      'romans 6:23': 'For the wages of sin is death, but the gift of God is eternal life in Christ Jesus our Lord.',
      'ephesians 2:8': 'For it is by grace you have been saved, through faith—and this is not from yourselves, it is the gift of God—',
      'hebrews 11:1': 'Now faith is confidence in what we hope for and assurance about what we do not see.',
      '1 john 4:7': 'Dear friends, let us love one another, for love comes from God. Everyone who loves has been born of God and knows God.',
      'revelation 21:4': 'He will wipe every tear from their eyes. There will be no more death or mourning or crying or pain, for the old order of things has passed away.',
      'matthew 6:33': 'But seek first his kingdom and his righteousness, and all these things will be given to you as well.',
      'joshua 1:9': 'Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the LORD your God will be with you wherever you go.',
      'galatians 5:22': 'But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness,',
      '2 timothy 3:16': 'All Scripture is God-breathed and is useful for teaching, rebuking, correcting and training in righteousness,',
      'james 1:2': 'Consider it pure joy, my brothers and sisters, whenever you face trials of many kinds,',
      'proverbs 27:17': 'As iron sharpens iron, so one person sharpens another.',
      'ecclesiastes 3:1': 'There is a time for everything, and a season for every activity under the heavens:',
      'mark 12:31': 'The second is this: Love your neighbor as yourself. There is no commandment greater than these.',
      'luke 6:31': 'Do to others as you would have them do to you.',
      '1 peter 5:7': 'Cast all your anxiety on him because he cares for you.',
      'colossians 3:23': 'Whatever you do, work at it with all your heart, as working for the Lord, not for human masters,',
    };

    String normalizedRef = reference.toLowerCase().trim();
    
    // Try exact match first
    if (hardcodedVerses.containsKey(normalizedRef)) {
      return hardcodedVerses[normalizedRef]!;
    }

    // Try partial matches for book and chapter
    for (String key in hardcodedVerses.keys) {
      if (key.startsWith(normalizedRef.split(' ')[0]) && 
          normalizedRef.contains(key.split(' ')[1].split(':')[0])) {
        return hardcodedVerses[key]!;
      }
    }

    // Try fuzzy matching for common misspellings or variations
    for (String key in hardcodedVerses.keys) {
      if (_isSimilarReference(key, normalizedRef)) {
        return '${hardcodedVerses[key]!}\n\n(Note: Found similar verse "$key" for your request "$reference")';
      }
    }

    // If no match found, provide helpful suggestions
    List<String> suggestions = _getSuggestionsForReference(normalizedRef);
    String suggestionText = suggestions.isNotEmpty 
        ? '\n\nDid you mean: ${suggestions.take(3).join(', ')}?'
        : '\n\nTry references like "John 3:16", "Romans 8:28", or "Psalms 23:1".';
    
    return 'Sorry, I could not find the verse "$reference".$suggestionText';
  }

  bool _isSimilarReference(String stored, String requested) {
    // Simple similarity check based on Levenshtein-like logic
    List<String> storedParts = stored.split(' ');
    List<String> requestedParts = requested.split(' ');
    
    if (storedParts.length < 2 || requestedParts.length < 2) return false;
    
    // Check if book names are similar
    String storedBook = storedParts[0];
    String requestedBook = requestedParts[0];
    
    return _isBookNameSimilar(storedBook, requestedBook);
  }

  bool _isBookNameSimilar(String book1, String book2) {
    // Handle common abbreviations and variations
    Map<String, List<String>> variations = {
      'john': ['jn', 'jo'],
      'romans': ['rom', 'rm'],
      'psalms': ['psalm', 'ps'],
      'matthew': ['matt', 'mt'],
      'philippians': ['phil', 'php'],
      'corinthians': ['cor', 'co'],
      'genesis': ['gen', 'ge'],
      'revelation': ['rev', 're'],
    };
    
    book1 = book1.toLowerCase();
    book2 = book2.toLowerCase();
    
    if (book1 == book2) return true;
    
    for (String key in variations.keys) {
      if ((key == book1 && variations[key]!.contains(book2)) ||
          (key == book2 && variations[key]!.contains(book1))) {
        return true;
      }
    }
    
    return false;
  }

  List<String> _getSuggestionsForReference(String reference) {
    List<String> popular = [
      'John 3:16',
      'Romans 8:28',
      'Philippians 4:13',
      'Psalms 23:1',
      'Jeremiah 29:11',
      'Matthew 5:16',
      '1 Corinthians 13:4',
      'Proverbs 3:5',
      'Isaiah 40:31',
    ];
    
    // If we can extract a book name, suggest verses from that book
    String bookName = reference.split(' ').first;
    return popular.where((verse) => 
        verse.toLowerCase().startsWith(bookName.toLowerCase())).toList();
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
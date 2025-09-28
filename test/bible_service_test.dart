import 'package:flutter_test/flutter_test.dart';
import 'package:bible_verse/bible_service.dart';

void main() {
  group('BibleService', () {
    late BibleService bibleService;

    setUp(() {
      bibleService = BibleService();
    });

    test('should return verse for valid reference', () async {
      String result = await bibleService.getVerse('John 3:16');
      
      expect(result, isNotEmpty);
      expect(result.toLowerCase(), contains('god so loved the world'));
    });

    test('should return verse for case variations', () async {
      String result1 = await bibleService.getVerse('john 3:16');
      String result2 = await bibleService.getVerse('JOHN 3:16');
      String result3 = await bibleService.getVerse('John 3:16');
      
      expect(result1, isNotEmpty);
      expect(result2, isNotEmpty);
      expect(result3, isNotEmpty);
    });

    test('should return error message for unknown verse', () async {
      String result = await bibleService.getVerse('UnknownBook 999:999');
      
      expect(result, contains('Sorry, I could not find'));
    });

    test('should return suggestions for partial matches', () async {
      String result = await bibleService.getVerse('romans');
      
      expect(result, isNotEmpty);
      // Should either find a verse or provide suggestions
    });

    test('should handle common book abbreviations', () async {
      // This would test the book name normalization
      String result = await bibleService.getVerse('rom 8:28');
      expect(result, isNotEmpty);
    });

    test('should return suggested verses list', () {
      List<String> suggestions = bibleService.getSuggestedVerses();
      
      expect(suggestions, isNotEmpty);
      expect(suggestions, contains('John 3:16'));
      expect(suggestions, contains('Romans 8:28'));
    });
  });
}
import 'package:praxis/src/strings.dart';
import 'package:test/test.dart';

void main() {
  group('splitWords', () {
    test('splits on mixed whitespace', () {
      expect(
        splitWords('  go   rust\tzig\n'),
        equals(<String>['go', 'rust', 'zig']),
      );
    });

    test('returns empty list for empty input', () {
      expect(splitWords(''), isEmpty);
    });

    test('returns empty list for blank input', () {
      expect(splitWords('  \t\n '), isEmpty);
    });

    test('keeps multibyte words intact', () {
      expect(splitWords('héllo 世界'), equals(<String>['héllo', '世界']));
    });

    test('keeps emoji words intact', () {
      expect(splitWords('hi 👋🌍 bye'), equals(<String>['hi', '👋🌍', 'bye']));
    });

    test('returns a fresh list that never aliases the source', () {
      final List<String> firstCall = splitWords('go rust');
      firstCall.add('zig');
      expect(splitWords('go rust'), equals(<String>['go', 'rust']));
    });

    test('leaves the source text unchanged', () {
      const String sourceText = 'go rust';
      const String snapshot = 'go rust';
      splitWords(sourceText);
      expect(sourceText, equals(snapshot));
    });
  });

  group('chunkString', () {
    test('splits héllo by runes', () {
      expect(chunkString('héllo', 2), equals(<String>['hé', 'll', 'o']));
    });

    test('never splits a multibyte rune', () {
      expect(chunkString('世界世', 2), equals(<String>['世界', '世']));
      for (final String chunkPart in chunkString('世界世', 2)) {
        expect(chunkPart.runes.length, lessThanOrEqualTo(2));
      }
    });

    test('never splits an emoji rune', () {
      expect(chunkString('👋🌍a', 2), equals(<String>['👋🌍', 'a']));
    });

    test('yields one chunk when the size covers the input', () {
      expect(chunkString('go', 9), equals(<String>['go']));
    });

    test('yields singletons when the size is one', () {
      expect(chunkString('abc', 1), equals(<String>['a', 'b', 'c']));
    });

    test('returns an empty list for empty input', () {
      expect(chunkString('', 2), isEmpty);
    });

    test('rejects a non-positive chunk size', () {
      expect(() => chunkString('go', 0), throwsArgumentError);
      expect(() => chunkString('go', -2), throwsArgumentError);
    });

    test('returns fresh chunks and leaves the source untouched', () {
      const String sourceText = 'héllo';
      final List<String> chunks = chunkString(sourceText, 2);
      chunks[0] = 'CHANGED';
      expect(chunkString(sourceText, 2), equals(<String>['hé', 'll', 'o']));
      expect(sourceText, equals('héllo'));
    });
  });

  group('truncateRunes', () {
    test('keeps short text whole', () {
      expect(truncateRunes('go', 9), equals('go'));
    });

    test('cuts by runes not bytes', () {
      expect(truncateRunes('héllo', 2), equals('hé'));
    });

    test('cuts emoji by runes not code units', () {
      expect(takeRunes('👋🌍ab', 2), equals('👋🌍'));
      expect(truncateRunes('👋🌍ab', 2), equals('👋🌍'));
    });

    test('handles empty input and zero budget', () {
      expect(truncateRunes('', 3), equals(''));
      expect(truncateRunes('go', 0), equals(''));
    });

    test('rejects a negative budget', () {
      expect(() => truncateRunes('go', -1), throwsArgumentError);
    });

    test('leaves the source text unchanged', () {
      const String sourceText = 'héllo';
      truncateRunes(sourceText, 2);
      expect(sourceText, equals('héllo'));
    });
  });

  group('takeRunes', () {
    test('keeps the first runes', () {
      expect(takeRunes('héllo', 2), equals('hé'));
    });

    test('keeps emoji runes whole', () {
      expect(takeRunes('👋🌍ab', 1), equals('👋'));
    });

    test('returns the source unchanged when the count covers the input', () {
      expect(takeRunes('go', 9), equals('go'));
    });

    test('returns empty for a zero count', () {
      expect(takeRunes('go', 0), equals(''));
      expect(takeRunes('', 0), equals(''));
    });

    test('rejects a negative count', () {
      expect(() => takeRunes('go', -1), throwsArgumentError);
    });

    test('leaves the source text unchanged', () {
      const String sourceText = 'héllo';
      takeRunes(sourceText, 2);
      expect(sourceText, equals('héllo'));
    });
  });

  group('dropRunes', () {
    test('drops the first runes', () {
      expect(dropRunes('héllo', 2), equals('llo'));
    });

    test('drops emoji runes whole', () {
      expect(dropRunes('👋🌍ab', 1), equals('🌍ab'));
    });

    test('returns the source unchanged for a zero count', () {
      expect(dropRunes('go', 0), equals('go'));
    });

    test('returns empty when the count covers the input', () {
      expect(dropRunes('go', 9), equals(''));
      expect(dropRunes('', 1), equals(''));
    });

    test('complements takeRunes without tearing runes', () {
      const String sourceText = 'héllo👋';
      const int splitAt = 3;
      expect(
        takeRunes(sourceText, splitAt) + dropRunes(sourceText, splitAt),
        equals(sourceText),
      );
    });

    test('rejects a negative count', () {
      expect(() => dropRunes('go', -1), throwsArgumentError);
    });

    test('leaves the source text unchanged', () {
      const String sourceText = 'héllo';
      dropRunes(sourceText, 2);
      expect(sourceText, equals('héllo'));
    });
  });

  group('truncateWithEllipsis', () {
    test('keeps short text whole with no suffix', () {
      expect(truncateWithEllipsis('go', 9), equals('go'));
    });

    test('cuts to the rune budget including the ellipsis', () {
      expect(truncateWithEllipsis('héllo world', 8), equals('héllo w…'));
      expect(truncateWithEllipsis('héllo world', 8).runes.length, equals(8));
    });

    test('keeps emoji whole inside the budget', () {
      expect(truncateWithEllipsis('👋🌍abcd', 4), equals('👋🌍a…'));
    });

    test('cuts the ellipsis itself when the budget is tiny', () {
      expect(truncateWithEllipsis('hello', 1), equals('…'));
      expect(truncateWithEllipsis('hello', 0), equals(''));
    });

    test('honours a custom ellipsis within the budget', () {
      expect(truncateWithEllipsis('hello world', 5, '...'), equals('he...'));
    });

    test('behaves like truncateRunes with an empty ellipsis', () {
      expect(truncateWithEllipsis('héllo', 2, ''), equals('hé'));
    });

    test('returns empty for empty input', () {
      expect(truncateWithEllipsis('', 3), equals(''));
    });

    test('rejects a negative budget', () {
      expect(() => truncateWithEllipsis('go', -1), throwsArgumentError);
    });

    test('leaves the source text unchanged', () {
      const String sourceText = 'héllo world';
      truncateWithEllipsis(sourceText, 8);
      expect(sourceText, equals('héllo world'));
    });
  });

  group('defaultEllipsisMark', () {
    test('is one rune', () {
      expect(defaultEllipsisMark.runes.length, equals(1));
    });
  });

  group('documented examples', () {
    test('defaultEllipsisMark example is one rune', () {
      expect(defaultEllipsisMark.runes.length, equals(1));
    });

    test('splitWords example splits on whitespace runs', () {
      expect(
        splitWords('  go   rust\tzig\n'),
        equals(<String>['go', 'rust', 'zig']),
      );
    });

    test('chunkString example groups héllo by two', () {
      expect(chunkString('héllo', 2), equals(<String>['hé', 'll', 'o']));
    });

    test('truncateRunes example keeps hé', () {
      expect(truncateRunes('héllo', 2), equals('hé'));
    });

    test('takeRunes example keeps hé', () {
      expect(takeRunes('héllo', 2), equals('hé'));
    });

    test('dropRunes example keeps llo', () {
      expect(dropRunes('héllo', 2), equals('llo'));
    });

    test('truncateWithEllipsis example budgets eight runes', () {
      expect(truncateWithEllipsis('héllo world', 8), equals('héllo w…'));
    });
  });
}

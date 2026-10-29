import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:easy_english/features/word_bank/data/datasources/word_suggestion_service.dart';

class _MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.Request request) onSend;
  _MockHttpClient(this.onSend);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final req = request as http.Request;
    final res = await onSend(req);
    final bytes = res.bodyBytes.isNotEmpty ? res.bodyBytes : res.body.codeUnits;
    return http.StreamedResponse(
      Stream.value(bytes),
      res.statusCode,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        ...res.headers,
      },
    );
  }
}

void main() {
  group('WordSuggestionService 100% Online API Tests', () {
    test('fetches rich suggestions from Datamuse words API with parts of speech and definitions', () async {
      final mockClient = _MockHttpClient((req) async {
        expect(req.url.host, equals('api.datamuse.com'));
        expect(req.url.path, equals('/words'));
        expect(req.url.queryParameters['sp'], equals('resil*'));

        return http.Response(
          jsonEncode([
            {
              'word': 'resilient',
              'score': 24000,
              'tags': ['adj'],
              'defs': [
                'adj\t(of a person) able to recoil or spring back into shape after bending, stretching, or being compressed.'
              ]
            },
            {
              'word': 'resilience',
              'score': 18000,
              'tags': ['n'],
              'defs': [
                'n\tthe capacity to withstand or recover quickly from difficulties; toughness.'
              ]
            }
          ]),
          200,
        );
      });

      final service = WordSuggestionService(httpClient: mockClient);
      service.clearCache();

      final results = await service.getSuggestions('resil');
      expect(results.length, equals(2));
      expect(results[0].word, equals('resilient'));
      expect(results[0].partOfSpeech, equals('adj'));
      expect(results[0].meaningHint, contains('able to recoil'));

      expect(results[1].word, equals('resilience'));
      expect(results[1].partOfSpeech, equals('n'));
      expect(results[1].meaningHint, contains('capacity to withstand'));
    });

    test('falls back to Datamuse sug endpoint when words endpoint returns empty', () async {
      final mockClient = _MockHttpClient((req) async {
        if (req.url.path == '/words') {
          return http.Response('[]', 200);
        }
        if (req.url.path == '/sug') {
          return http.Response(
            jsonEncode([
              {'word': 'serendipity', 'score': 12000},
              {'word': 'serene', 'score': 11000},
            ]),
            200,
          );
        }
        return http.Response('[]', 404);
      });

      final service = WordSuggestionService(httpClient: mockClient);
      service.clearCache();

      final results = await service.getSuggestions('seren');
      expect(results.length, equals(2));
      expect(results[0].word, equals('serendipity'));
      expect(results[1].word, equals('serene'));
    });

    test('falls back to Wiktionary OpenSearch when Datamuse fails', () async {
      final mockClient = _MockHttpClient((req) async {
        if (req.url.host == 'api.datamuse.com') {
          return http.Response('Server Error', 500);
        }
        if (req.url.host == 'en.wiktionary.org') {
          return http.Response(
            jsonEncode([
              'eloq',
              ['eloquent', 'eloquence'],
              ['', ''],
              ['https://en.wiktionary.org/wiki/eloquent', 'https://en.wiktionary.org/wiki/eloquence']
            ]),
            200,
          );
        }
        return http.Response('[]', 404);
      });

      final service = WordSuggestionService(httpClient: mockClient);
      service.clearCache();

      final results = await service.getSuggestions('eloq');
      expect(results.length, equals(2));
      expect(results[0].word, equals('eloquent'));
      expect(results[1].word, equals('eloquence'));
    });

    test('caches queries to prevent duplicate network calls', () async {
      int requestCount = 0;
      final mockClient = _MockHttpClient((req) async {
        requestCount++;
        return http.Response(
          jsonEncode([
            {'word': 'work', 'tags': ['n'], 'defs': ['n\tjob']}
          ]),
          200,
        );
      });

      final service = WordSuggestionService(httpClient: mockClient);
      service.clearCache();

      final firstCall = await service.getSuggestions('wor');
      expect(firstCall.length, equals(1));
      expect(requestCount, equals(1));

      // Second identical call hits in-memory cache
      final secondCall = await service.getSuggestions('wor');
      expect(secondCall.length, equals(1));
      expect(requestCount, equals(1));
    });

    test('returns empty list for blank query without network call', () async {
      int requestCount = 0;
      final mockClient = _MockHttpClient((req) async {
        requestCount++;
        return http.Response('[]', 200);
      });

      final service = WordSuggestionService(httpClient: mockClient);
      final results = await service.getSuggestions('   ');
      expect(results, isEmpty);
      expect(requestCount, equals(0));
    });
  });
}

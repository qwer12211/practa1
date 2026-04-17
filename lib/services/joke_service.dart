import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Практос 7, оценка 3: работа с сетью только через пакет [Dio].
class JokeService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.api-ninjas.com/v1',
      headers: {
        'X-Api-Key': 'dIiIY9nH7cKbclrx440a63yNg1v934iUJ6nztp2T',
      },
    ),
  );

  Future<List<String>> fetchJokes() async {
    try {
      final response = await _dio.get('/dadjokes');
      final List<dynamic> jokes = response.data as List<dynamic>;
      return jokes
          .map((joke) => (joke as Map<String, dynamic>)['joke'] as String)
          .toList();
    } on DioException catch (e) {
      debugPrint('Ошибка API: ${e.message}');
      if (e.response != null) {
        debugPrint('Статус: ${e.response?.statusCode}');
        debugPrint('Тело: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      return [];
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

final service = GetIt.instance;

/// Практос 7, оценка 5: [Dio] из контейнера [GetIt], токен в заголовке задаёт [TokenInterceptor].
class JokeService {
  Future<List<String>> fetchJokes() async {
    try {
      final response = await service<Dio>().get('/dadjokes');

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

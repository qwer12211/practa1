# Методы и фрагменты **после** (оценки 4–5)

**Формулировки из методички:**

- **На «4»:** «Добавить класс **interceptor**, который автоматически добавляет **токен в заголовок**, и использовать **interceptor** от пакета **pretty_dio_logger**.» Плюс по сети по-прежнему **Dio**.
- **На «5»:** всё то же, и дополнительно: «для управления зависимостями использовать пакет **get_it**.»

Этот файл описывает **текущий** вариант проекта: класс `TokenInterceptor` (токен → заголовок `X-Api-Key`), в цепочку `dio.interceptors` добавлен **PrettyDioLogger**, общий **Dio** регистрируется в **get_it**, сервис берёт его через `GetIt.instance<Dio>()`. То есть здесь закрыты требования и к **4**, и к **5** (пятерка = четвёрка + get_it).

Рабочий код — в `lib/`. Сравнение с «тройкой» — в `practos7_metody_DO.md`.

---

## `main.dart` — `main`, `setupService`, `JokeApp.build`

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'interceptors/token_interceptor.dart';
import 'widgets/joke_list.dart';

final getIt = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupService();
  runApp(const JokeApp());
}

void setupService() {
  const apiToken = 'dIiIY9nH7cKbclrx440a63yNg1v934iUJ6nztp2T';

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.api-ninjas.com/v1',
    ),
  );

  dio.interceptors.clear();
  dio.interceptors.add(TokenInterceptor(apiToken));
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
    ),
  );

  getIt.registerLazySingleton<Dio>(() => dio);
}

class JokeApp extends StatelessWidget {
  const JokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dad Jokes',
      home: Scaffold(
        appBar: AppBar(title: const Text('Шутки')),
        body: const SafeArea(child: JokeList()),
      ),
    );
  }
}
```

---

## `token_interceptor.dart` — перехватчик токена

```dart
import 'package:dio/dio.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor(this.token);

  final String token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (token.isNotEmpty) {
      options.headers['X-Api-Key'] = token;
    }
    super.onRequest(options, handler);
  }
}
```

---

## `joke_service.dart` — запрос через Dio из get_it

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

final service = GetIt.instance;

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
```

---

## `joke_list.dart`

Методы экрана те же по смыслу (`_loadJokes`, `_loadMoreJokes`, `_removeOneJoke`, `build`). Отличие только в том, что `JokeService` использует зарегистрированный в **get_it** `Dio`. Файл: `lib/widgets/joke_list.dart`.

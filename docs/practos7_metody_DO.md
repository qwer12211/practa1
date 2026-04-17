# Пример реализации на оценку **3** (только Dio + сеть)

**Из методички:** «Разработать приложение, которое работает с сетью. Для этого использовать пакет **Dio**.»

Ниже — **самодостаточный** пример: один HTTP-клиент **Dio**, запрос к API Ninjas, экран со списком и кнопками (не «две кнопки»).  
**Нет:** класса `Interceptor`, `pretty_dio_logger`, `get_it`. Ключ API задаётся в **`BaseOptions.headers`** (для тройки так допустимо; на 4–5 его выносят в interceptor).

Текущий рабочий проект у тебя собран **на 4–5** — см. `lib/` и `practos7_metody_POSLE.md`. Этот файл — **эталон для отчёта / сравнения**, не обязательно копировать в `lib/` поверх готового кода.

---

## Зависимости (`pubspec.yaml`) — минимум для «3»

Достаточно **Flutter SDK** и **dio** (без `get_it`, без `pretty_dio_logger`):

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.8.0+1
```

---

## `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'widgets/joke_list.dart';

void main() {
  runApp(const JokeApp());
}

class JokeApp extends StatelessWidget {
  const JokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dad Jokes',
      home: Scaffold(
        appBar: AppBar(title: const Text('Шутки от API Ninjas')),
        body: const SafeArea(child: JokeList()),
      ),
    );
  }
}
```

Нет `setupService()`, нет `GetIt`, нет `WidgetsFlutterBinding.ensureInitialized()` — только `runApp` (для простого случая достаточно).

---

## `lib/services/joke_service.dart` — сеть через **Dio**

Один экземпляр `Dio` в сервисе; запрос **`_dio.get('/dadjokes')`**.

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class JokeService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.api-ninjas.com/v1',
      headers: {'X-Api-Key': '<ВАШ_КЛЮЧ>'},
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
```

---

## `lib/widgets/joke_list.dart` — функциональность UI

Тот же смысл, что в проекте: `JokeService()` без контейнера зависимостей — сервис сам создаёт свой `_dio`.

```dart
import 'package:flutter/material.dart';

import '../services/joke_service.dart';

class JokeList extends StatefulWidget {
  const JokeList({super.key});

  @override
  State<JokeList> createState() => _JokeListState();
}

class _JokeListState extends State<JokeList> {
  final JokeService _jokeService = JokeService();

  List<String> _jokes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJokes();
  }

  Future<void> _loadJokes() async {
    setState(() => _isLoading = true);
    try {
      final int count = _jokes.isEmpty ? 1 : _jokes.length;
      final List<String> newJokes = [];
      for (int i = 0; i < count; i++) {
        newJokes.addAll(await _jokeService.fetchJokes());
      }
      setState(() => _jokes = newJokes);
    } catch (e) {
      debugPrint('Ошибка загрузки шуток: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreJokes() async {
    setState(() => _isLoading = true);
    try {
      final jokes = await _jokeService.fetchJokes();
      setState(() => _jokes.addAll(jokes));
    } catch (e) {
      debugPrint('Ошибка загрузки шуток: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeOneJoke() {
    if (_jokes.isEmpty) return;
    setState(() => _jokes.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadJokes,
                icon: const Icon(Icons.refresh),
                label: const Text('Обновить шутки'),
              ),
              ElevatedButton.icon(
                onPressed: (_isLoading || _jokes.isEmpty) ? null : _removeOneJoke,
                icon: const Icon(Icons.remove),
                label: const Text('Удалить 1'),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadMoreJokes,
                icon: const Icon(Icons.add),
                label: const Text('Добавить 1'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _jokes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.mood),
                      title: Text(_jokes[index]),
                      subtitle: const Text('Батя шутит...'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
```

---

## Что говорить на защите для «3»

1. Показать **`pubspec.yaml`** — зависимость **dio**.  
2. Показать **`JokeService`** — **`Dio`**, **`get`**, разбор JSON с API.  
3. Показать приложение — список и несколько действий с данными из сети.

Вариант «после», с **Interceptor**, **PrettyDioLogger** и **get_it** — в **`practos7_metody_POSLE.md`**.

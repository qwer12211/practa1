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
  const apiKey = 'dIiIY9nH7cKbclrx440a63yNg1v934iUJ6nztp2T';

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.api-ninjas.com/v1',
    ),
  );

  dio.interceptors.clear();
  dio.interceptors.add(TokenInterceptor(apiKey));
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
        appBar: AppBar(title: const Text('Шутки от бати')),
        body: const SafeArea(child: JokeList()),
      ),
    );
  }
}

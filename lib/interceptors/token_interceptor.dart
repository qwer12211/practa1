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

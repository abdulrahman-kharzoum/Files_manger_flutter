import 'package:dio/dio.dart';

Dio dio() {
  Dio dio = Dio();
  dio.options.baseUrl = 'http://127.0.0.1:8000/api/';

  // dio.options.baseUrl = 'http://10.0.2.2:8000/api/';
  dio.options.headers['Accept'] = 'application/json';
  // dio.options.headers['Accept-Language'] = isArabic() ? 'ar' : 'en';
  return dio;
}

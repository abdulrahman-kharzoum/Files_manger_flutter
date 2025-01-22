import 'package:dio/dio.dart';

Dio dio() {
  Dio dio = Dio();
  dio.options.baseUrl = 'http://127.0.0.1:8000/api/';

  // dio.options.baseUrl = 'http://10.0.2.2:8000/api/';
  dio.options.headers['Accept'] = 'application/json';
  dio.options.headers['Access-Control-Allow-Origin'] = "*";
  // dio.options.headers['Access-Control-Allow-Credentials'] = true;
  // dio.options.headers['Access-Control-Allow-Headers']= "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale";
  // dio.options.headers['Access-Control-Allow-Methods']= "POST, OPTIONS";

  // dio.options.headers['Accept-Language'] = isArabic() ? 'ar' : 'en';
  return dio;
}

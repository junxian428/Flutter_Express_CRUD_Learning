import 'package:dio/dio.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Dio _dio = Dio();

  Future<Response> get(String path) async {
    try {
      final response = await _dio.get('$baseUrl/$path');
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<Response> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('$baseUrl/$path', data: data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<Response> put(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('$baseUrl/$path', data: data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete('$baseUrl/$path');
      return response;
    } catch (e) {
      throw e;
    }
  }
}

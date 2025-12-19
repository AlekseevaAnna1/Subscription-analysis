import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Для TimeWeb используем относительный путь /api через прокси
  // Для локальной разработки - localhost
  static String get baseUrl {
    if (kIsWeb) {
      // В веб-версии на TimeWeb используем прокси через .htaccess
      return '/api';
    } else {
      // Для мобильных приложений или локальной разработки
      return 'http://127.0.0.1:8000'; // или 'http://10.0.2.2:8000' для Android эмулятора
    }
  }

  Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Добавь другие методы (get, put, delete) если нужно
  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.get(
        url,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
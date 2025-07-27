import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3333';

  static String? _storedToken;

  static Future<String?> get storedToken async {
    if (_storedToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _storedToken = prefs.getString('token');
    }
    return _storedToken;
  }

  static Future<void> setStoredToken(String? token) async {
    _storedToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('token');
    } else {
      await prefs.setString('token', token);
    }
  }

  static Future<void> removeStoredToken() async {
    await setStoredToken(null);
  }

  static Map<String, String> get headersWithAuth {
    return {'Authorization': 'Bearer ${storedToken}'};
  }

  static Future<dynamic> handleResponse(
    Future<http.Response> responseFuture,
  ) async {
    final response = await responseFuture;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  static Future<dynamic> registerUser(String email, String password) async {
    final response = await handleResponse(
      http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    return response;
  }

  static Future<dynamic> loginUser(String email, String password) async {
    final response = await handleResponse(
      http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    await setStoredToken(response['token']);
    return response;
  }

  static Future<dynamic> getUserProfile() async {
    final response = await handleResponse(
      http.get(Uri.parse('$baseUrl/users/me'), headers: headersWithAuth),
    );
    return response;
  }

  static Future<dynamic> getAllNotes() async {
    final response = await handleResponse(
      http.get(Uri.parse('$baseUrl/notes'), headers: headersWithAuth),
    );
    return response;
  }

  static Future<dynamic> createNote(String title, String content) async {
    final response = await handleResponse(
      http.post(
        Uri.parse('$baseUrl/notes'),
        headers: headersWithAuth,
        body: jsonEncode({'title': title, 'content': content}),
      ),
    );
    return response;
  }

  static Future<dynamic> updateNote(
    String id,
    String title,
    String content,
  ) async {
    final response = await handleResponse(
      http.patch(
        Uri.parse('$baseUrl/notes/$id'),
        headers: headersWithAuth,
        body: jsonEncode({'title': title, 'content': content}),
      ),
    );
    return response;
  }

  static Future<dynamic> deleteNote(String id) async {
    final response = await handleResponse(
      http.delete(Uri.parse('$baseUrl/notes/$id'), headers: headersWithAuth),
    );
    return response;
  }

  static Future<dynamic> archiveNote(String id) async {
    final response = await handleResponse(
      http.post(
        Uri.parse('$baseUrl/notes/$id/archive'),
        headers: headersWithAuth,
      ),
    );
    return response;
  }

  static Future<dynamic> searchNote(String query) async {
    final response = await handleResponse(
      http.get(
        Uri.parse('$baseUrl/notes/search?q=$query'),
        headers: headersWithAuth,
      ),
    );
    return response;
  }

  static Future<dynamic> forgotPassword(String email) async {
    final response = await handleResponse(
      http.post(
        Uri.parse('$baseUrl/users/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ),
    );
    return response;
  }
}

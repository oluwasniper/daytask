import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A service class for making API requests to the backend.
/// It handles authentication token management and centralized response handling.
class ApiService {
  // Base URL for the backend API.
  // Using 10.0.2.2 for Android Emulator to connect to localhost on the development machine.
  // The '/api' prefix is crucial to match the NestJS global prefix defined in main.ts.
  static const String _baseUrl = 'http://10.0.2.2:3333/api';

  // In-memory cache for the authentication token.
  static String? _cachedToken;

  /// Retrieves the authentication token, first from memory cache, then from SharedPreferences.
  ///
  /// Returns the token string if available, otherwise null.
  /// This method is private and primarily used internally by ApiService to build headers.
  static Future<String?> _getToken() async {
    if (_cachedToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString('token');
    }
    return _cachedToken;
  }

  /// Stores the authentication token in both memory cache and SharedPreferences.
  ///
  /// If [token] is null, the token will be removed.
  static Future<void> setAuthToken(String? token) async {
    _cachedToken = token; // Update in-memory cache
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('token');
    } else {
      await prefs.setString('token', token);
    }
  }

  /// Removes the authentication token from both memory cache and SharedPreferences.
  static Future<void> clearAuthToken() async {
    await setAuthToken(null);
  }

  /// Generates common HTTP headers, including 'Content-Type' and 'Authorization' if a token is present.
  ///
  /// This method is asynchronous because it needs to await the authentication token.
  /// Returns a Future that resolves to a Map of headers.
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Handles the HTTP response, checking for success status codes.
  ///
  /// Throws an [Exception] if the response status code is not in the 2xx range.
  /// Returns the decoded JSON body on success. Returns null for 204 No Content.
  static Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Handle cases where response body might be empty but status is 204 No Content
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null; // For successful responses with no body (e.g., 204 No Content)
    } else {
      // Attempt to parse backend error message if available
      String errorMessage =
          'API Error: ${response.statusCode} - ${response.reasonPhrase ?? 'Unknown'}';
      try {
        if (response.body.isNotEmpty) {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          } else {
            errorMessage = response.body; // Use raw body if no 'message' field
          }
        }
      } catch (e) {
        // If body is not JSON or cannot be decoded, use the default error message
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  // --- User Authentication Endpoints ---

  /// Registers a new user.
  ///
  /// Returns the response body on success.
  /// Throws an [Exception] on failure.
  static Future<dynamic> registerUser(String email, String password) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/auth/register',
      ), // ✅ FIXED: Changed from /users to /auth/register
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final responseBody = await _handleResponse(response);

    // ✅ FIXED: Handle the token from registration response
    if (responseBody is Map && responseBody.containsKey('accessToken')) {
      await setAuthToken(responseBody['accessToken']);
    }
    return responseBody;
  }

  /// Logs in a user and stores the received authentication token.
  ///
  /// Returns the response body on success.
  /// Throws an [Exception] on failure (e.g., invalid credentials, no token received).
  static Future<dynamic> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/auth/login',
      ), // ✅ FIXED: Changed from /users/login to /auth/login
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final responseBody = await _handleResponse(response);

    // ✅ FIXED: Handle the correct token field name
    if (responseBody is Map && responseBody.containsKey('accessToken')) {
      await setAuthToken(
        responseBody['accessToken'],
      ); // Changed from 'token' to 'accessToken'
    } else {
      throw Exception(
        'Login successful, but no token received from the server.',
      );
    }
    return responseBody;
  }

  /// Fetches the authenticated user's profile.
  ///
  /// Requires an authentication token. Returns the user profile data on success.
  /// Throws an [Exception] on failure (e.g., unauthorized, user not found).
  static Future<dynamic> getUserProfile() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/auth/profile',
      ), // ✅ FIXED: Changed from /users/me to /auth/profile
      headers: headers,
    );
    return _handleResponse(response);
  }

  /// Sends a forgot password request for the given email.
  ///
  /// Returns the response body on success.
  /// Throws an [Exception] on failure.
  static Future<dynamic> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/auth/forgot-password', // ✅ FIXED: Changed from /users/forgot-password to /auth/forgot-password
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  // --- Note Management Endpoints ---
  // These endpoints remain the same as they were already correct

  /// Fetches all notes for the authenticated user.
  ///
  /// Requires an authentication token. Returns a list of notes on success.
  /// Throws an [Exception] on failure.
  static Future<dynamic> getAllNotes() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/note'), // Matches NestJS '/api/note' (singular)
      headers: headers,
    );
    return _handleResponse(response);
  }

  /// Creates a new note for the authenticated user.
  ///
  /// Requires an authentication token. Returns the created note data on success.
  /// Throws an [Exception] on failure.
  static Future<dynamic> createNote(String title, String content) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/note'), // Matches NestJS '/api/note' (singular)
      headers: headers,
      body: jsonEncode({'title': title, 'content': content}),
    );
    return _handleResponse(response);
  }

  /// Updates an existing note for the authenticated user.
  ///
  /// Requires an authentication token. Returns the updated note data on success.
  /// Throws an [Exception] on failure.
  static Future<dynamic> updateNote(
    String id,
    String title,
    String content,
  ) async {
    final headers = await _getAuthHeaders();
    final response = await http.patch(
      Uri.parse(
        '$_baseUrl/note/$id',
      ), // Matches NestJS '/api/note/:id' (singular)
      headers: headers,
      body: jsonEncode({'title': title, 'content': content}),
    );
    return _handleResponse(response);
  }

  /// Deletes a note for the authenticated user.
  ///
  /// Requires an authentication token. Returns null on successful deletion (e.g., 204 No Content).
  /// Throws an [Exception] on failure.
  static Future<dynamic> deleteNote(String id) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/note/$id',
      ), // Matches NestJS '/api/note/:id' (singular)
      headers: headers,
    );
    return _handleResponse(response);
  }

  /// Archives or unarchives a note for the authenticated user.
  ///
  /// Requires an authentication token. Returns the updated note data on success.
  /// Throws an [Exception] on failure.
  static Future<dynamic> archiveNote(String id) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/note/$id/archive',
      ), // Matches NestJS '/api/note/:id/archive' (singular)
      headers: headers,
    );
    return _handleResponse(response);
  }

  /// Searches for notes based on a query for the authenticated user.
  ///
  /// Requires an authentication token. Returns a list of matching notes on success.
  /// Throws an [Exception] on failure.
  static Future<dynamic> searchNote(String query) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/note/search?q=$query',
      ), // Matches NestJS '/api/note/search?q=' (singular)
      headers: headers,
    );
    return _handleResponse(response);
  }
}

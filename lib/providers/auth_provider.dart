import 'package:daytask/models/user.dart';
import 'package:daytask/services/api_service.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // You might not need this import directly in AuthProvider if ApiService handles all http calls

class AuthProvider with ChangeNotifier {
  // baseUrl is used by ApiService, so it should be defined there or passed to it.
  // If ApiService is truly static and self-contained, AuthProvider doesn't need baseUrl.
  // However, if ApiService uses this baseUrl, it should be passed or accessed.
  // For now, let's assume ApiService has its own baseUrl or receives it.
  // If ApiService uses this baseUrl, it should be defined in ApiService.
  // Or, if ApiService needs it, you could pass it to ApiService methods,
  // but your current ApiService.loginUser doesn't seem to take a base URL.

  // Let's keep it here for now if ApiService is designed to consume it,
  // but ideally, ApiService should manage its own base URL.
  // static const String baseUrl = 'http://10.0.2.2:3333'; // Keep if ApiService refers to it

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // Login method
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // --- REMOVE THE REDUNDANT AND INCOMPLETE HTTP CALL HERE ---
      // The line below was causing the issue because it's an isolated http call
      // that wasn't properly configured or wasn't the intended API call.
      // final uri = Uri.parse('$baseUrl/users/login');
      // debugPrint('Flutter attempting to connect to: $uri');
      // final response = await http.post(uri, /* ... */);
      // ---------------------------------------------------------

      // Step 1: Attempt to login and get a token using your dedicated ApiService
      // This is the correct and intended call.
      await ApiService.loginUser(email, password);

      // Step 2: After successful login (token is stored in ApiService),
      // fetch the user's profile to get their data.
      final userResponse = await ApiService.getUserProfile();
      final user = User.fromJson(userResponse);
      _setUser(user);

      _setLoading(false);
      return true;
    } catch (e) {
      // Catch specific errors if ApiService throws them (e.g., AuthException)
      _setError(
        e.toString().contains("AuthException: ")
            ? e.toString().replaceFirst("AuthException: ", "")
            : 'Login failed: ${e.toString()}',
      );
      _setLoading(false);
      return false;
    }
  }

  // Register method (previously called signUp)
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // Register the user. Note: Your API's registerUser might not use 'name'.
      await ApiService.registerUser(email, password);

      // After successful registration, automatically login the user
      final loginSuccess = await login(email, password);
      return loginSuccess;
    } catch (e) {
      _setError(
        e.toString().contains("AuthException: ")
            ? e.toString().replaceFirst("AuthException: ", "")
            : 'Registration failed: ${e.toString()}',
      );
      _setLoading(false);
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);

    try {
      await ApiService.removeStoredToken(); // Clear token from storage
      _setUser(null); // Clear local user data
      _setError(null);
    } catch (e) {
      // Even if something fails during token removal, ensure local state is cleared
      await ApiService.removeStoredToken(); // Double-attempt
      _setUser(null);
      _setError(
        'Error during logout but data cleared locally: ${e.toString()}',
      );
    }

    _setLoading(false);
  }

  // Check if user is already logged in (on app start)
  Future<void> checkAuthStatus() async {
    _setLoading(true); // Indicate loading while checking status
    _setError(null); // Clear any previous errors

    try {
      final token = await ApiService.storedToken;

      if (token != null) {
        // Token exists, try to get user profile to verify token validity
        final userResponse = await ApiService.getUserProfile();
        final user = User.fromJson(userResponse);
        _setUser(user); // Set user if profile fetch is successful
      }
    } catch (e) {
      // If profile fetch fails (e.g., token expired, invalid), clear token
      await ApiService.removeStoredToken();
      _setUser(null); // Ensure user is null
      _setError('Session expired or invalid. Please login again.');
    } finally {
      _setLoading(false); // Always stop loading when done
    }
  }

  // Forgot password method
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.forgotPassword(email);

      // Assuming your ApiService.forgotPassword returns a map like {'success': true, 'message': '...'}
      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to send reset email.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(
        e.toString().contains("AuthException: ")
            ? e.toString().replaceFirst("AuthException: ", "")
            : 'Forgot password failed: ${e.toString()}',
      );
      _setLoading(false);
      return false;
    }
  }

  // Clear error manually from UI
  void clearError() {
    _setError(null);
  }
}

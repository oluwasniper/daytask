import 'package:daytask/models/user.dart';
import 'package:daytask/services/api_service.dart';
import 'package:flutter/material.dart';

/// Provides authentication state and methods for user login, registration, and logout.
class AuthProvider with ChangeNotifier {
  // Private fields to hold authentication state.
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Public getters to access the authentication state.
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  /// Internal helper to set the loading state and notify listeners.
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Internal helper to set an error message and notify listeners.
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  /// Internal helper to set the current authenticated user and notify listeners.
  void _setUser(User? user) {
    if (_user != user) {
      // Only notify if user object truly changes
      _user = user;
      notifyListeners();
    }
  }

  /// Attempts to log in a user with the given [email] and [password].
  ///
  /// On success, fetches the user profile and updates the local state.
  /// Returns true if login is successful, false otherwise.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // Step 1: Attempt to login and get a token using your dedicated ApiService.
      // ApiService.loginUser handles token storage internally.
      await ApiService.loginUser(email, password);

      // Step 2: After successful login (token is stored),
      // fetch the user's profile to get their data and confirm token validity.
      final userResponse = await ApiService.getUserProfile();
      final user = User.fromJson(userResponse);
      _setUser(user); // Update local user state

      return true;
    } catch (e) {
      // Catch any exceptions thrown by ApiService and set the error message.
      _setError(
        'Login failed: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    } finally {
      _setLoading(
        false,
      ); // Always stop loading, regardless of success or failure.
    }
  }

  /// Registers a new user with the given [name], [email], and [password].
  ///
  /// After successful registration, it automatically attempts to log the user in.
  /// Returns true if registration and subsequent login are successful, false otherwise.
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // Register the user. Note: Your API's registerUser might not use 'name'.
      await ApiService.registerUser(email, password);

      // After successful registration, automatically login the user.
      final loginSuccess = await login(email, password);
      return loginSuccess;
    } catch (e) {
      // Catch any exceptions thrown by ApiService and set the error message.
      _setError(
        'Registration failed: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    } finally {
      _setLoading(false); // Always stop loading.
    }
  }

  /// Logs out the current user.
  ///
  /// Clears the authentication token from storage and resets local user data.
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Clear token from storage using the refactored ApiService method.
      await ApiService.clearAuthToken();
      _setUser(null); // Clear local user data
      _setError(null); // Clear any existing errors
    } catch (e) {
      // Even if token removal fails, ensure local state is cleared for security.
      await ApiService.clearAuthToken(); // Attempt to clear again in case of partial failure
      _setUser(null);
      _setError(
        'Error during logout but data cleared locally: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      _setLoading(false); // Always stop loading.
    }
  }

  /// Checks the authentication status on app start.
  ///
  /// Attempts to verify token validity by fetching the user profile.
  /// If successful, sets the user; otherwise, clears any invalid token and user data.
  Future<void> checkAuthStatus() async {
    _setLoading(true); // Indicate loading while checking status
    _setError(null); // Clear any previous errors

    try {
      // Attempt to get user profile. This will fail if no valid token is present
      // or if the token is expired/invalid, and ApiService will throw an Exception.
      final userResponse = await ApiService.getUserProfile();
      final user = User.fromJson(userResponse);
      _setUser(user); // Set user if profile fetch is successful
    } catch (e) {
      // If profile fetch fails (e.g., no token, token expired, invalid), clear token and user.
      await ApiService.clearAuthToken(); // Clear any potentially invalid token
      _setUser(null); // Ensure user is null
      _setError('Session expired or invalid. Please login again.');
    } finally {
      _setLoading(false); // Always stop loading when done.
    }
  }

  /// Sends a forgot password request for the given [email].
  ///
  /// Returns true if the request is successful, false otherwise.
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.forgotPassword(email);

      // Assuming your ApiService.forgotPassword returns a map like {'success': true, 'message': '...'}
      // Adjust this condition based on your actual backend response for success.
      if (response != null && response is Map && response['success'] == true) {
        return true;
      } else {
        _setError(response?['message'] ?? 'Failed to send reset email.');
        return false;
      }
    } catch (e) {
      _setError(
        'Forgot password failed: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    } finally {
      _setLoading(false); // Always stop loading.
    }
  }

  /// Clears any current error message.
  void clearError() {
    _setError(null);
  }
}

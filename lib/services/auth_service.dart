import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_client.dart';
import '../main.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // ─────────────────────────────────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login/', {
        'username': email, // simplejwt expects 'username'; we set username=email at registration
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _apiClient.saveTokens(data['access'], data['refresh']);
        return await fetchAndSetProfile();
      } else {
        final data = jsonDecode(response.body);
        final msg = data['detail'] ?? data['error'] ?? 'Login failed. Check your credentials.';
        throw Exception(msg);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> register(String name, String email, String password,
      {String phone = ''}) async {
    try {
      final response = await _apiClient.post('/auth/register/', {
        'first_name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _apiClient.saveTokens(
          data['tokens']['access'],
          data['tokens']['refresh'],
        );
        final userData = data['user'];
        userNameNotifier.value = userData['first_name'] ?? name;
        userEmailNotifier.value = userData['email'] ?? email;
        isGuestNotifier.value = false;
        return true;
      } else {
        final body = jsonDecode(response.body);
        String errorMsg = 'Registration failed.';
        if (body is Map) {
          if (body.containsKey('email')) {
            errorMsg = (body['email'] as List).join(' ');
          } else if (body.containsKey('password')) {
            errorMsg = (body['password'] as List).join(' ');
          } else if (body.containsKey('non_field_errors')) {
            errorMsg = (body['non_field_errors'] as List).join(' ');
          } else if (body.containsKey('error')) {
            errorMsg = body['error'];
          }
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FETCH & SET PROFILE
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> fetchAndSetProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile/');
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        userNameNotifier.value = userData['first_name'] ?? '';
        userEmailNotifier.value = userData['email'] ?? '';
        isGuestNotifier.value = false;
        return true;
      }
    } catch (e) {
      debugPrint('Fetching profile failed: $e');
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _apiClient.clearTokens();
    userNameNotifier.value = '';
    userEmailNotifier.value = '';
    isGuestNotifier.value = false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD — Step 1: Send OTP to email
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post('/auth/forgot-password/', {
        'email': email.trim().toLowerCase(),
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Could not send OTP. Please try again.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VERIFY OTP — Step 2 (optional standalone check)
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiClient.post('/auth/verify-otp/', {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Invalid OTP. Please try again.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESET PASSWORD — Step 3: OTP + new password
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final response = await _apiClient.post('/auth/reset-password/', {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
        'password': newPassword,
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Password reset failed. Please try again.');
      }
    } catch (e) {
      rethrow;
    }
  }
}

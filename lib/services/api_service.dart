import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IMPORTANT: Replace with your live Render URL if it's different
  static const String _baseUrl = "https://customerconnect-0jz7.onrender.com/api";
  String? _sessionCookie;

  // Private constructor for singleton pattern
  ApiService._privateConstructor();
  static final ApiService _instance = ApiService._privateConstructor();

  factory ApiService() {
    return _instance;
  }

  // Method to load the cookie from storage
  Future<void> _loadCookie() async {
    if (_sessionCookie != null) return;
    final prefs = await SharedPreferences.getInstance();
    _sessionCookie = prefs.getString('session_cookie');
  }

  // Method to save the cookie to storage
  Future<void> _saveCookie(String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_cookie', cookie);
    _sessionCookie = cookie;
  }

  // Method to clear the cookie on logout
  Future<void> clearCookie() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
    _sessionCookie = null;
  }

  // Generic method to make a GET request with the session cookie
  Future<http.Response> _get(String endpoint) async {
    await _loadCookie();
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_sessionCookie != null) 'Cookie': _sessionCookie!,
      },
    );
    return response;
  }

  /// Attempts to log in the user with the given credentials.
  /// Returns true on success, false on failure.
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Successfully logged in, now extract and save the session cookie.
      String? rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        // The cookie value is often like "session=...; Path=/; HttpOnly". We only need the "session=..." part.
        int index = rawCookie.indexOf(';');
        String sessionCookie = (index == -1) ? rawCookie : rawre.substring(0, index);
        await _saveCookie(sessionCookie);
        return true;
      }
    }
    return false;
  }

  /// Fetches the analytics summary data from the API.
  /// Throws an exception if the request fails or user is not authenticated.
  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    final response = await _get('/analytics/summary');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle errors, e.g., user not authenticated
      throw Exception('Failed to load summary data. Status code: ${response.statusCode}');
    }
  }

  /// Fetches the time series data for charts.
  /// Throws an exception if the request fails or user is not authenticated.
  Future<List<dynamic>> getAnalyticsTimeseries() async {
    final response = await _get('/analytics/timeseries');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load time series data. Status code: ${response.statusCode}');
    }
  }
  
  /// Checks if a user session cookie exists.
  Future<bool> isAuthenticated() async {
    await _loadCookie();
    return _sessionCookie != null;
  }
}
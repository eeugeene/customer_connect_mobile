import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const CustomerConnectApp(),
    ),
  );
}

class CustomerConnectApp extends StatelessWidget {
  const CustomerConnectApp({super.key});

    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomerConnect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final ApiService _apiService = ApiService();

  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _apiService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData && snapshot.data == true) {
          // User is authenticated, go to Dashboard
          // We will create this screen later
          return const DashboardScreen();
        } else {
          // User is not authenticated, go to Login
          return const LoginScreen();
        }
      },
    );
  }
}

// A simple provider to manage auth state if needed later
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
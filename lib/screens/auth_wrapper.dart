import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_list_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true;

  void _toggleView() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            // User is not logged in
            return _showLogin
                ? LoginScreen(onRegisterPressed: _toggleView)
                : RegisterScreen(onLoginPressed: _toggleView);
          } else {
            return const TaskListScreen();
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
} 
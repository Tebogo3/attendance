import 'package:attendance/screens/home_screen.dart';
import 'package:attendance/screens/login_screen.dart';
import 'package:attendance/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    //authService.signOut();
//if the user has logged in before go to homescreen or else loginScreen
    return authService.currentUser == null
        ? const LoginScreen()
        : const HomeScreen();
  }
}

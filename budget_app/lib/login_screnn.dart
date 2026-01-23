import 'dart:convert';
import 'package:budget_app/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> login() async {
  try {
    final response = await http.post(
      Uri.parse("https://fullstack-mobile-budgetapp.onrender.com/api/login"), // URL RENDER
      headers: {
        'Accept': 'application/json', // INDISPENSABLE
      },
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
    },
    ).timeout(const Duration(seconds: 40)); // Pour laisser le temps au serveur gratuit de se réveiller

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);

      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const ExpenseListScreen())
        );
      }
    } else {
      final errorData = json.decode(response.body);
      String message = errorData['message'] ?? "Identifiants incorrects";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erreur de connexion : Vérifiez votre internet ou attendez le réveil du serveur"))
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Mot de passe"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Se connecter")),
            TextButton(
  onPressed: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
  },
  child: const Text("Pas encore de compte ? Inscrivez-vous"),
),
          ],
        ),
      ),
    );
  }
}
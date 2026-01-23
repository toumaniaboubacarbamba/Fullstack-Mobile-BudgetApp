import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  Future<void> register() async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Les mots de passe ne correspondent pas")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://fullstack-mobile-budgetapp.onrender.com/api/register"),
        headers: {'Accept': 'application/json','Content-Type': 'application/json',},
        body: jsonEncode({                    // <--- Encode les données
    'name': _nameController.text,
    'email': _emailController.text,
    'password': _passwordController.text,
    'password_confirmation': _confirmController.text,
  }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ExpenseListScreen()));
        }
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error['message'] ?? "Erreur d'inscription")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur de connexion au serveur")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: SingleChildScrollView( // Pour éviter les erreurs de clavier
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom complet")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Mot de passe"), obscureText: true),
            TextField(controller: _confirmController, decoration: const InputDecoration(labelText: "Confirmer le mot de passe"), obscureText: true),
            const SizedBox(height: 30),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: register, child: const Text("S'inscrire")),
          ],
        ),
      ),
    );
  }
}
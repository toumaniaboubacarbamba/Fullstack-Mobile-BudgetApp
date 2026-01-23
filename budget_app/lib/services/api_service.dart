import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.model.dart';

class ApiService {
  final String baseUrl = "https://fullstack-mobile-budgetapp.onrender.com/api";

  // Fonction privée pour récupérer les headers avec le token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // C'est ici que la magie opère
    };
  }

  // Récupérer les dépenses
  Future<List<Expense>> fetchExpenses() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Expense.fromJson(data)).toList();
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  // Ajouter une dépense
  Future<void> addExpense(Expense expense) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _getHeaders(),
      body: jsonEncode(expense.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création');
    }
  }

  // Supprimer une dépense
  Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression');
    }
  }
}
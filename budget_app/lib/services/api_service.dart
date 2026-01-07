import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.model.dart';

class ApiService {
  // L'adresse IP spéciale pour l'émulateur Android vers ton PC
  final String baseUrl = "http://10.0.2.2:8000/api/expenses";

  // Récupérer la liste des dépenses
  Future<List<Expense>> fetchExpenses() async {
  try {
    final response = await http.get(Uri.parse(baseUrl));
    print("Status Code: ${response.statusCode}");
    print("Response Body: '${response.body}'"); // Les guillemets ici sont importants pour voir si c'est vide

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return []; // Sécurité si c'est vide
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Expense.fromJson(data)).toList();
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  } catch (e) {
    print("Erreur attrapée: $e");
    rethrow;
  }
}

  // Envoyer une nouvelle dépense
  Future<void> addExpense(Expense expense) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(expense.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création');
    }
  }

  Future<void> deleteExpense(int id) async {
  final response = await http.delete(Uri.parse("$baseUrl/$id"));

  if (response.statusCode != 200) {
    throw Exception('Erreur lors de la suppression');
  }
}
}
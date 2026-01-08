import 'package:budget_app/add_expense_screen.dart';
import 'package:budget_app/login_screnn.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/expense.model.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(BudgetApp(isLoggedIn: token != null));
}

class BudgetApp extends StatelessWidget {
  final bool isLoggedIn;
  const BudgetApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: isLoggedIn ? const ExpenseListScreen() : const LoginScreen(),
    );
  }
}

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Expense>> futureExpenses;

  double _calculateTotal(List<Expense> expenses) {
  return expenses.fold(0, (sum, item) => sum + item.amount);
}

  @override
  void initState() {
    super.initState();
    futureExpenses = apiService.fetchExpenses(); // On charge les données au lancement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Budget")),
      body: FutureBuilder<List<Expense>>(
  future: futureExpenses,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasData) {
      final expenses = snapshot.data!;
      final total = _calculateTotal(expenses);

      return Column(
        children: [
          // --- LE WIDGET DU TOTAL ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Column(
              children: [
                const Text("Dépenses Totales", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 10),
                Text("${total.toStringAsFixed(2)} €", 
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                
                return Dismissible(
                  key: Key(expense.id.toString()), // Clé unique pour Flutter
                  direction: DismissDirection.endToStart, // Glisser de droite à gauche
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    // 1. Appel au backend pour supprimer en base
                    await apiService.deleteExpense(expense.id!);
                    
                    // 2. Refresh de l'UI et du Total
                    setState(() {
                      futureExpenses = apiService.fetchExpenses();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${expense.title} supprimé")),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(expense.category[0])),
                      title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(expense.category),
                      trailing: Text("${expense.amount} CFA", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    return const Center(child: Text("Aucune donnée disponible"));
  },
),
floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // On attend le résultat de la page d'ajout
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );

          // Si l'ajout a réussi, on rafraîchit la liste et donc le total !
          if (result == true) {
            setState(() {
              futureExpenses = apiService.fetchExpenses();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
    
  }
}
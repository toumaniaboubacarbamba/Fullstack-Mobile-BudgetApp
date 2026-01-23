import 'package:budget_app/add_expense_screen.dart';
import 'package:budget_app/login_screnn.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/expense.model.dart';
import 'services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        ),
      ),
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

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Alimentation':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Loisirs':
        return Icons.sports_esports;
      case 'Santé':
        return Icons.medical_services;
      default:
        return Icons.monetization_on;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Alimentation':
        return Colors.deepOrange;
      case 'Transport':
        return Colors.indigo;
      case 'Loisirs':
        return Colors.green;
      case 'Santé':
        return Colors.pink;
      default:
        return Colors.teal;
    }
  }

  // Génère les sections pour le PieChart à partir de la liste des dépenses
  List<PieChartSectionData> _getSections(List<Expense> expenses) {
    // 1. On regroupe les montants par catégorie
    final Map<String, double> data = {};
    for (var e in expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }

    // 2. Couleurs par catégorie (cyclique)
    final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    int colorIndex = 0;

    // 3. Création des sections
    return data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n${entry.value.toStringAsFixed(0)} CFA',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  IconData _getIcon(String category) {
    switch (category) {
      case 'Alimentation':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_car;
      case 'Loisirs':
        return Icons.movie;
      case 'Santé':
        return Icons.medical_services;
      default:
        return Icons.payments;
    }
  }

  Widget _buildTotalCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          const Text("Dépenses Totales", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 10),
          Text("${total.toStringAsFixed(2)} CFA", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildListView(List<Expense> expenses) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Dismissible(
          key: Key(expense.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) async {
            await apiService.deleteExpense(expense.id!);
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
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(_getIcon(expense.category), color: Colors.blue),
              ),
              title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(expense.category),
              trailing: Text("${expense.amount} CFA", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    futureExpenses = apiService.fetchExpenses(); // On charge les données au lancement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Budget"),
      actions: [
  IconButton(
    icon: const Icon(Icons.logout),
    onPressed: () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // On supprime le token
      if (context.mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
    },
  )
],),
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
          _buildTotalCard(total),

          if (expenses.isNotEmpty)
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _getSections(expenses),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),

          Expanded(child: _buildListView(expenses)),
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
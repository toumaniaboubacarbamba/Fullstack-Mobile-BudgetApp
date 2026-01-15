import 'package:flutter/material.dart';
import 'models/expense.model.dart';
import 'services/api_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Alimentation';
  bool _isLoading = false;

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newExpense = Expense(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
      );

      try {
        await ApiService().addExpense(newExpense);
        if (mounted) Navigator.pop(context, true); // Retourne à la liste avec un succès
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter une dépense")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) => value!.isEmpty ? 'Entrez un titre' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Entrez un prix' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 18,
                    child: Icon(getCategoryIcon(_selectedCategory), color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      items: ['Alimentation', 'Transport', 'Loisirs', 'Santé']
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _submitData, 
                    child: const Text("Enregistrer", style: TextStyle(fontSize: 16, color: Colors.white),),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
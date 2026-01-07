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
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: ['Alimentation', 'Transport', 'Loisirs', 'Santé']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitData, 
                    child: const Text("Enregistrer"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
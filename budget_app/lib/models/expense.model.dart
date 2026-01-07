class Expense{
    final int? id;
    final String title;
    final double amount;
    final String category;

    Expense({this.id, required this.title, required this.amount, required this.category});

    //Cette fonction transforme le JSON en un objet Expense
    factory Expense.fromJson(Map<String, dynamic> json) {
  return Expense(
    id: json['id'],
    title: json['title'],
    // On convertit en String puis on parse, ou on utilise .toDouble() 
    // pour être sûr que peu importe ce que Laravel envoie, on aura un double.
    amount: (json['amount'] is int) 
        ? (json['amount'] as int).toDouble() 
        : double.parse(json['amount'].toString()),
    category: json['category'],
  );
}

    //Cette fonction transforme notre objet Expense en JSON
    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'title': title,
            'amount': amount,
            'category': category,
        };
    }
}
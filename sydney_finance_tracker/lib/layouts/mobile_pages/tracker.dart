import 'package:flutter/material.dart';
import 'package:sydney_finance_tracker/database.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  final api = ApiService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Food',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills',
    'Other'
  ];

  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    //db stuff
    setState(() {});
  }

  void _addExpense() async {
    if (_amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text);

    final Map<String, dynamic> expense = {
      "amount": amount,
      "category": _selectedCategory,
      "note": _noteController.text,
      "dateSpent": DateTime.now()
    };

    await api.addExpense(expense);

    _amountController.clear();
    _noteController.clear();

    await _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Tracker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "Amount (\$)"),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      value: _selectedCategory,
                      items: _categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                      decoration: const InputDecoration(labelText: "Category"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      decoration:
                          const InputDecoration(labelText: "Note (optional)"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addExpense,
                      child: const Text("Add Expense"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final e = expenses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(e['category'][0])),
                      title: Text(
                          "${e['category']} - \$${e['amount'].toStringAsFixed(2)}"),
                      subtitle: Text(e['note'] ?? ''),
                      trailing: Text(
                        "${e['date'].month}/${e['date'].day}/${e['date'].year}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  final TextEditingController _purchaseController = TextEditingController();
  String _selectedCategory = 'General';

  String _filterCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> filteredExpenses = [];

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
    final data = await api.getExpenses(null);
    setState(() {
      expenses = data;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      filteredExpenses = expenses.where((e) {
        final matchesCategory =
            _filterCategory == 'All' || e['category'] == _filterCategory;
        final matchesSearch = _searchController.text.isEmpty ||
            e['purchase']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
        final date = DateTime.parse(e['date']).toLocal();

        final startMatch = _startDate == null ||
            date.isAfter(_startDate!.subtract(const Duration(days: 1)));
        final endMatch = _endDate == null ||
            date.isBefore(_endDate!.add(const Duration(days: 1)));
        return matchesCategory && matchesSearch && startMatch && endMatch;
      }).toList();
    });
  }

  double get totalFilteredAmount {
    return filteredExpenses.fold(0.0, (sum, e) => sum + (e['amount'] ?? 0));
  }

  void _addExpense() async {
    if (_amountController.text.isEmpty || _purchaseController.text.isEmpty) {
      return;
    }

    final amount = double.tryParse(_amountController.text);

    final Map<String, dynamic> expense = {
      "amount": amount,
      "purchase": _purchaseController.text,
      "category": _selectedCategory,
      "note": _noteController.text,
      "date": DateTime.now()
    };

    await api.addExpense(expense);

    _amountController.clear();
    _noteController.clear();
    _purchaseController.clear();

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
        child: SingleChildScrollView(
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
                      TextField(
                        controller: _purchaseController,
                        decoration:
                            const InputDecoration(labelText: "Purchase (\$)"),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField(
                        value: _selectedCategory,
                        items: _categories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                        },
                        decoration:
                            const InputDecoration(labelText: "Category"),
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
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: _filterCategory,
                        items: ['All', ..._categories]
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (value) {
                          _filterCategory = value!;
                          _applyFilters();
                        },
                        decoration: const InputDecoration(
                            labelText: "Filter by Category"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => _applyFilters(),
                        decoration: const InputDecoration(
                          labelText: "Search by Purchase Name",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 5.0,
                        alignment: WrapAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now());
                              if (picked != null) {
                                _startDate = picked;
                                _applyFilters();
                              }
                            },
                            child: Text(_startDate == null
                                ? "Start Date"
                                : "${_startDate!.month}/${_startDate!.day}/${_startDate!.year}"),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                _endDate = picked;
                                _applyFilters();
                              }
                            },
                            child: Text(_endDate == null
                                ? "End Date"
                                : "${_endDate!.month}/${_endDate!.day}/${_endDate!.year}"),
                          ),
                          OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _endDate = null;
                                  _startDate = null;
                                });
                                _applyFilters();
                              },
                              child: Text("Clear")),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Total: \$${totalFilteredAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                itemCount: filteredExpenses.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final e = filteredExpenses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(e['category'][0])),
                      title: Text(
                          "${e['category']} - ${e['purchase']} - \$${e['amount'].toStringAsFixed(2)}"),
                      subtitle: Text(e['note'] ?? ''),
                      trailing: Text(
                        "${DateTime.parse(e['date']).toLocal().month}/${DateTime.parse(e['date']).toLocal().day}/${DateTime.parse(e['date']).toLocal().year}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

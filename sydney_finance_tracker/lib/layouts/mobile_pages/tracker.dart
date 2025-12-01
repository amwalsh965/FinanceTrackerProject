import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String? _selectedCategory;
  String? _filterCategory;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> filteredExpenses = [];

  int? _editingTrackerId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadExpenses();
  }

  Future<void> _loadCategories() async {
    final data = await api.getCategories(null);
    print("Categories: $data");
    setState(() {
      categories = data;
    });
  }

  Future<void> _loadExpenses() async {
    final data = await api.getExpenses(null);
    setState(() {
      expenses = data;
      _applyFilters();
    });
  }

  Future<void> _addCategoryDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await api.addCategory({"name": controller.text});
                await _loadCategories();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(int id) async {
    await api.deleteCategories([id]);
    await _loadCategories();
  }

  // Future<void> _loadCategories() async {
  //   final data = await api.getCategories(null);
  //   setState(() => categories = data);
  // }

  void _addExpense() async {
    if (_amountController.text.isEmpty || _purchaseController.text.isEmpty) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    print("SelectedCategory: $_selectedCategory");
    print("a ${int.tryParse(_selectedCategory!)}");
    print(_selectedCategory != null);
    final Map<String, dynamic> expense = {
      "amount": amount,
      "purchase": _purchaseController.text,
      "category_id":
          _selectedCategory != null ? int.tryParse(_selectedCategory!) : null,
      "note": _noteController.text,
      "date": DateTime.now()
    };

    print(expense["category"]);

    await api.addExpense(expense);

    _amountController.clear();
    _noteController.clear();
    _purchaseController.clear();
    setState(() => _selectedCategory = null);

    await _loadExpenses();
  }

  Future<void> _updateExpense(Map<String, dynamic> expense) async {
    expense["date"] = DateTime.parse(expense["date"]);
    await api.updateExpense(expense);
    setState(() => _editingTrackerId = null);
    await _loadExpenses();
  }

  Future<void> _deleteExpenses(id) async {
    await api.deleteExpenses([id]);
    await _loadExpenses();
  }

  void _applyFilters() {
    print(_filterCategory);
    setState(() {
      filteredExpenses = expenses.where((e) {
        print(e['category_id']);
        final matchesCategory = _filterCategory == null ||
            e['category_id'] == int.tryParse(_filterCategory!);
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
                            const InputDecoration(labelText: "Purchase"),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String?>(
                        value: _selectedCategory,
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text("None"),
                          ),
                          ...categories.map((c) => DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(c['name']),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 18, color: Colors.redAccent),
                                    onPressed: () => _deleteCategory(c['id']),
                                  )
                                ],
                              ))),
                          DropdownMenuItem(
                            value: "add",
                            child: Row(
                              children: const [
                                Icon(Icons.add, color: Colors.green),
                                SizedBox(width: 5),
                                Text("Add New Category"),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == "add") {
                            await _addCategoryDialog();
                          } else {
                            setState(() => _selectedCategory = value);
                          }
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
                      DropdownButtonFormField<String?>(
                        value: _filterCategory,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text("All")),
                          ...?categories.map((c) => DropdownMenuItem(
                                value: c['id'].toString(),
                                child: Text(c['name']),
                              )),
                        ],
                        onChanged: (value) {
                          _filterCategory = value;
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
              if (filteredExpenses.isNotEmpty)
                ListView.builder(
                  itemCount: filteredExpenses.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final e = filteredExpenses[index];
                    final isEditing = _editingTrackerId == e['id'];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Optional tap action
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Leading CircleAvatar
                                CircleAvatar(
                                  child: Text(
                                      (e['category_name']?.isNotEmpty == true)
                                          ? e['category_name'][0].toUpperCase()
                                          : ""),
                                ),
                                const SizedBox(width: 16),

                                // Middle: title + subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${e['category_name'] ?? ""} - ${e['purchase']} - \$${e['amount'].toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        e['note'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),

                                // Trailing buttons + date
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isEditing)
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.check,
                                                color: Colors.green),
                                            onPressed: () async =>
                                                await _updateExpense(e),
                                          )
                                        else
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blueAccent),
                                            onPressed: () => setState(() =>
                                                _editingTrackerId = e['id']),
                                          ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.delete,
                                              color: Colors.redAccent),
                                          onPressed: () =>
                                              _deleteExpenses(e['id']),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${DateTime.parse(e['date']).toLocal().month}/${DateTime.parse(e['date']).toLocal().day}/${DateTime.parse(e['date']).toLocal().year}",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

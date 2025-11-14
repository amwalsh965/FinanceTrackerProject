import 'package:flutter/material.dart';
import 'package:sydney_finance_tracker/database.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final api = ApiService();
  final TextEditingController _spendingController = TextEditingController();
  final TextEditingController _customDurationController =
      TextEditingController();
  String? _selectedCategory;
  String _selectedDuration = 'monthly';
  bool _reoccuring = false;

  List<Map<String, dynamic>> goals = [];
  List<Map<String, dynamic>> categories = [];

  final List<String> _durationOptions = [
    'weekly',
    'monthly',
    'yearly',
    'custom'
  ];

  int? _editingGoalId;

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _loadCategories();
  }

  Future<void> _loadGoals() async {
    final data = await api.getGoals(null);
    setState(() => goals = data);
  }

  Future<void> _loadCategories() async {
    final data = await api.getCategories(null);
    setState(() => categories = data);
  }

  Future<void> _addGoal() async {
    if (_spendingController.text.isEmpty) return;

    int? customDuration;
    if (_selectedDuration == 'custom') {
      customDuration = int.tryParse(_customDurationController.text);
      if (customDuration == null) return;
    }

    final goal = {
      "category_id":
          _selectedCategory != null ? int.tryParse(_selectedCategory!) : null,
      "spending_goal": int.tryParse(_spendingController.text),
      "reoccuring": _reoccuring,
      "duration_type": _selectedDuration,
      "custom_duration": customDuration
    };

    await api.addGoal(goal);
    _resetFields();
    await _loadGoals();
  }

  Future<void> _updateGoal(Map<String, dynamic> goal) async {
    await api.updateGoal(goal);
    setState(() => _editingGoalId = null);
    await _loadGoals();
  }

  Future<void> _deleteGoal(int id) async {
    await api.deleteGoals([id]);
    await _loadGoals();
  }

  void _resetFields() {
    _spendingController.clear();
    _customDurationController.clear();
    setState(() => _reoccuring = false);
    _selectedDuration = 'monthly';
    _selectedCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: _selectedCategory,
                        items: categories
                            .map((c) => DropdownMenuItem(
                                value: c['id'].toString(),
                                child: Text(c['name'])))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value),
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _spendingController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Spending Goals'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedDuration,
                        items: _durationOptions
                            .map((d) =>
                                DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedDuration = value!),
                        decoration:
                            const InputDecoration(labelText: 'Duration'),
                      ),
                      if (_selectedDuration == 'custom')
                        TextField(
                          controller: _customDurationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Custom Duration (days)'),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Recurring Goal"),
                          Switch(
                            value: _reoccuring,
                            onChanged: (value) =>
                                setState(() => _reoccuring = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: _addGoal, child: const Text('Add Goal')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                itemCount: goals.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final g = goals[index];
                  final isEditing = _editingGoalId == g['id'];

                  if (isEditing) {
                    final editSpendingController = TextEditingController(
                        text: g['spending_goal'].toString());
                    final editCustomController = TextEditingController(
                        text: g['custom_duration']?.toString() ?? '');
                    String editDuration = g['duration_type'];
                    bool editReoccuring = false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text("Editing ${g['name']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: editSpendingController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Spending Goal'),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: editDuration,
                              items: _durationOptions
                                  .map((d) => DropdownMenuItem(
                                      value: d, child: Text(d.toUpperCase())))
                                  .toList(),
                              onChanged: (value) => setState(
                                  () => editDuration = value ?? editDuration),
                              decoration: const InputDecoration(
                                  labelText: 'Duration Type'),
                            ),
                            if (editDuration == 'custom')
                              TextField(
                                controller: editCustomController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Custom Duration (days)'),
                              ),
                            Row(
                              children: [
                                const Text("Reccuring Goal"),
                                Switch(
                                  value: editReoccuring,
                                  onChanged: (value) =>
                                      setState(() => editReoccuring = value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check),
                                  label: const Text("Save"),
                                  onPressed: () {
                                    final updatedGoal = {
                                      "id": g['id'],
                                      "category_id": g['category_id'],
                                      "spending_goal": int.tryParse(
                                          editSpendingController.text),
                                      "reoccuring": g['reoccuring'],
                                      "duration_type": editDuration,
                                      "custom_duration":
                                          editDuration == 'custom'
                                              ? int.tryParse(
                                                  editCustomController.text)
                                              : null,
                                    };
                                    _updateGoal(updatedGoal);
                                  },
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.close),
                                  label: const Text("Cancel"),
                                  onPressed: () =>
                                      setState(() => _editingGoalId = null),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text("${g['name']} - \$${g['spending_goal']}"),
                      subtitle: Text(
                          "Duration: ${g['duration_type']}${g['duration_type'] == 'custom' ? '(${g['custom_duration']} days)' : ''}\nEnd: ${g['end_date'] is String ? DateTime.parse(g['end_date']).toLocal().month : ""}/${g['end_date'] is String ? DateTime.parse(g['end_date']).toLocal().day : ""}/${g['end_date'] is String ? DateTime.parse(g['end_date']).toLocal().year : ""}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => {_deleteGoal(g['id'])},
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

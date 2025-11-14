import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sydney_finance_tracker/database.dart';
import 'package:sydney_finance_tracker/styles/app_styles.dart';

class Reminder extends StatefulWidget {
  const Reminder({super.key});

  @override
  State<Reminder> createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  final api = ApiService();
  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final data = await api.getReminders(null);
    setState(() {
      reminders = data;
    });
  }

  // Future<void> _loadGoals() async {
  //   final data = await api.getGoals(null);
  //   setState(() => goals = data);
  // }

  Future<void> _navigateToEditReminder(bool create, {int id = 0}) async {
    final (reminder, deleted) = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditReminder(created: create, id: id)),
    );

    if (reminder != null) {
      if (deleted == true) {
        await api.deleteReminders([reminder["id"]]);
      } else if (create == true) {
        await api.addReminder(reminder);
      } else {
        await api.updateReminder(reminder);
      }
      _loadReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sydneys Finance Tracker")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ReminderBox(
            reminders: reminders,
            onAddPressed: _navigateToEditReminder,
            onDeletePressed: api.deleteReminders,
            onDeleteAllPressed: api.deleteReminders,
            loadReminders: _loadReminders,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

class ReminderBox extends StatelessWidget {
  final List<Map<String, dynamic>> reminders;
  final Future<void> Function(bool create, {int id}) onAddPressed;
  final Future<void> Function(List<int>? ids) onDeletePressed;
  final Future<void> Function(List<int>? ids) onDeleteAllPressed;
  final VoidCallback loadReminders;

  const ReminderBox({
    super.key,
    required this.reminders,
    required this.onAddPressed,
    required this.onDeletePressed,
    required this.onDeleteAllPressed,
    required this.loadReminders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.pink[200] ?? Colors.pink,
        border: Border.all(color: Colors.pink[300] ?? Colors.pink),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Reminders",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppStyles.textColor,
            ),
          ),
          SizedBox(height: 8),
          if (reminders.isEmpty)
            Text(
              "No reminders yet. Add one!",
              style: TextStyle(
                fontSize: 16,
                color: AppStyles.textColor,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reminders.map((reminder) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await onAddPressed(false, id: reminder["id"]);
                      },
                      style: ButtonStyle(
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        elevation: WidgetStateProperty.all(0),
                      ),
                      child: ReminderInd(
                          reminder: reminder, onAddPressed: onAddPressed),
                    ),
                    SizedBox(height: 5),
                  ],
                );
              }).toList(),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await onAddPressed(true);
            },
            child: const Text("Add reminder"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: const Text(
                        "Are you sure you want to delete ALL reminders? This cannot be undone."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await onDeleteAllPressed(null);
                loadReminders();
              }
            },
            child: const Text("Delete All Reminders"),
          ),
        ],
      ),
    );
  }
}

class EditReminder extends StatefulWidget {
  final bool created;
  final int id;
  const EditReminder({
    super.key,
    required this.created,
    required this.id,
  });

  @override
  State<EditReminder> createState() => _EditReminderState();
}

class _EditReminderState extends State<EditReminder> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  final api = ApiService();
  List<Map<String, dynamic>> goals = [];
  String? _selectedGoalId;

  @override
  void initState() {
    super.initState();
    // _titleController = TextEditingController();
    // _contentController = TextEditingController();
    _loadGoals();
    _loadReminder();
  }

  Future<void> _loadGoals() async {
    final data = await api.getGoals(null);
    setState(() => goals = data);
  }

  void _loadReminder() async {
    if (widget.created == false) {
      final oldReminder = await api.getReminders([widget.id]);

      if (oldReminder.isNotEmpty) {
        final firstReminder = oldReminder[0];

        setState(() {
          _titleController.text = firstReminder["title"] ?? "";
          _contentController.text = firstReminder["content"] ?? "";
          _selectedGoalId = firstReminder["goal_id"];
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty) return;

    Map<String, dynamic> reminder = {
      'title': _titleController.text,
      'content': _contentController.text,
      'goal_id':
          _selectedGoalId != null ? int.tryParse(_selectedGoalId!) : null,
      if (!widget.created) 'id': widget.id
    };

    Navigator.pop(context, (reminder, false));
  }

  void _deleteReminder() {
    final reminder = {
      'title': _titleController.text,
      'content': _contentController.text,
      'goal_id': _selectedGoalId,
      'id': widget.id,
    };
    Navigator.pop(context, (reminder, true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Reminder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: "Context"),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String?>(
              value: _selectedGoalId,
              decoration: const InputDecoration(labelText: "Associated Goal"),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text("No Goal")),
                ...goals.map((goal) => DropdownMenuItem<String?>(
                      value: goal["id"].toString(),
                      child: Text(goal["name"]),
                    )),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedGoalId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _saveReminder,
                  child: const Text("Save"),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                if (!widget.created)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ElevatedButton(
                      onPressed: _deleteReminder,
                      child: const Text("Delete"),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderInd extends StatelessWidget {
  final Map<String, dynamic> reminder;
  final Future<void> Function(bool)? onAddPressed;

  const ReminderInd({super.key, required this.reminder, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    String goalText = "";
    if (reminder["spending_goal"] != null) {
      goalText = reminder["category_id"]
          ? "Spend under ${reminder['spending_goal']} on ${reminder['category_name']} until ${reminder['end_date']}"
          : "Spend under ${reminder['spending_goal']} until ${reminder['end_date']}";
    }

    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
            decoration: BoxDecoration(
              color: Colors.pink[50] ?? Colors.pink,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              reminder['title'] + ":" ?? "",
              style: TextStyle(
                fontSize: 16,
                decorationColor: Colors.white,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.pink[100] ?? Colors.pink,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              goalText != ""
                  ? "${reminder['content']}\n$goalText"
                  : (reminder['content'] ?? ""),
              style: TextStyle(
                fontSize: 16,
                color: AppStyles.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

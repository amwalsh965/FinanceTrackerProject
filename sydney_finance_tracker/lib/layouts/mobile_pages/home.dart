import 'package:flutter/material.dart';
import 'package:sydney_finance_tracker/layouts/mobile_pages/reminder.dart';
import 'package:sydney_finance_tracker/layouts/mobile_pages/tracker.dart';
import 'package:sydney_finance_tracker/styles/app_styles.dart';
import 'package:sydney_finance_tracker/widgets/buttons.dart';
import 'package:sydney_finance_tracker/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final api = ApiService();
  Map<String, dynamic>? reminder;

  @override
  void initState() {
    super.initState();
    _loadFirstReminder();
  }

  Future<void> _loadFirstReminder() async {
    final firstReminder = await api.getFirstReminderByDate();
    setState(() {
      reminder = firstReminder;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.pink[200] ?? Colors.pink,
            border: Border.all(color: Colors.pink[300] ?? Colors.pink),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Reminder()),
                  );
                  _loadFirstReminder();
                },
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  elevation: WidgetStateProperty.all(0),
                ),
                child: Column(children: [
                  const Text(
                    "Reminders",
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  if (reminder != null)
                    ReminderInd(reminder: reminder!)
                  else
                    const Text("No reminder yet"),
                  SizedBox(height: 10),
                  const Text("See more..."),
                ]),
              ),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          padding: EdgeInsets.all(20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MenuButton(
              label: "Tracker",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Tracker()),
                );
                print("Mobile Button Tapped");
              },
              icon: Icon(Icons.attach_money_rounded, size: AppStyles.iconSize),
            ),
            MenuButton(
              label: "Graphs",
              onPressed: () {
                print("Mobile Button Tapped");
              },
              icon: Icon(Icons.auto_graph_rounded, size: AppStyles.iconSize),
            ),
            MenuButton(
              label: "Goals",
              onPressed: () {
                print("Mobile Button Tapped");
              },
              icon: Icon(Icons.menu_book_rounded, size: AppStyles.iconSize),
            ),
            MenuButton(
              label: "Other",
              onPressed: () {
                print("Mobile Button Tapped");
              },
              icon: Icon(Icons.question_mark_rounded, size: AppStyles.iconSize),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sydney_finance_tracker/layouts/mobile_pages/home.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sydneys Finance Tracker")),
      body: SingleChildScrollView(child: Home()),
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

class MobileTrackerLayout extends StatelessWidget {
  const MobileTrackerLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

// class MobileTrackerEditLayout extends StatelessWidget {}

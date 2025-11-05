import "package:flutter/material.dart";

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200,
            color: Colors.blueGrey,
            child: Column(
              children: const [
                ListTile(title: Text("Home")),
                ListTile(title: Text("Settings")),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(height: 80, color: Colors.blue),
                const Expanded(
                  child: Center(
                    child: Text("This is the desktop layout"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

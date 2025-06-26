import 'package:flutter/material.dart';
import '../models/user_item.dart';
import '../widgets/expandable_item.dart';

class HomeScreen extends StatelessWidget {
  final List<UserItem> users;

  const HomeScreen({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Split users into two groups
    final youngFlock = users.where((u) => u.age < 4).toList();
    final oldFlock = users.where((u) => u.age >= 4).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: [
        if (youngFlock.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Warning',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...youngFlock.map((user) => ExpandableItem(user: user, imageColor: Colors.redAccent)).toList(),
        ],
        if (oldFlock.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Healthy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...oldFlock.map((user) => ExpandableItem(user: user, imageColor: Colors.greenAccent)).toList(),
        ],
      ],
    );
  }
}

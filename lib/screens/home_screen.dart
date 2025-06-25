import 'package:flutter/material.dart';
import '../models/user_item.dart';
import '../widgets/expandable_item.dart';

class HomeScreen extends StatelessWidget {
  final List<UserItem> users;

  const HomeScreen({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return users.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => ExpandableItem(user: users[index]),
          );
  }
}

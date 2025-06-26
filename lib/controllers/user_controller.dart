import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_item.dart';

class UserController {
  final List<UserItem> _users = [];

  List<UserItem> get users => List.unmodifiable(_users);

  Future<void> loadInitialUsers() async {
    final rawData = await rootBundle.loadString('lib/data/dummy_users.json');
    final jsonList = json.decode(rawData) as List;
    _users.clear();
    _users.addAll(jsonList.map((e) => UserItem.fromJson(e)));
  }

  void addUser(UserItem user) {
    _users.add(user);
  }
}

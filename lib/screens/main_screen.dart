import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../models/user_item.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final UserController _userController = UserController();
  int _selectedIndex = 0;
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _userController.loadInitialUsers().then((_) {
      setState(() {
        _loadingUsers = false;
      });
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddUserDialog() {
    final _formKey = GlobalKey<FormState>();
    String username = '';
    int age = 0;
    String gender = '';
    String extraInfo = '';

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    onSaved: (val) => username = val!.trim(),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => age = int.tryParse(val!) ?? 0,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    onSaved: (val) => gender = val!.trim(),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Extra Info'),
                    onSaved: (val) => extraInfo = val!.trim(),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newUser = UserItem(
                    username: username,
                    age: age,
                    gender: gender,
                    extraInfo: extraInfo,
                  );
                  setState(() {
                    _userController.addUser(newUser);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(users: _userController.users),
      const CalendarScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          // HEADER
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Image.asset(
                  'assets/fabicon_400x400.png',
                  height: 80,
                ),
                const SizedBox(height: 8),
                const Text(
                  'PRoVaTo: FETA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const Divider(height: 1),

          // CONTENT AREA WITH BACKGROUND IMAGE
          Expanded(
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/sheeps.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                _loadingUsers
                    ? const Center(child: CircularProgressIndicator())
                    : pages[_selectedIndex],
              ],
            ),
          ),
        ],
      ),

      // FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => _onTabSelected(0),
                color: _selectedIndex == 0 ? Colors.black : Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _onTabSelected(1),
                color: _selectedIndex == 1 ? Colors.black : Colors.grey,
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _onTabSelected(2),
                color: _selectedIndex == 2 ? Colors.black : Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => _onTabSelected(3),
                color: _selectedIndex == 3 ? Colors.black : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

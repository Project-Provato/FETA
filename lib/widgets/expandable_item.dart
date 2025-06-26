import 'package:flutter/material.dart';
import '../models/user_item.dart';

class ExpandableItem extends StatefulWidget {
  final UserItem user;
  final Color imageColor; // ✅ NEW INPUT

  const ExpandableItem({
    super.key,
    required this.user,
    required this.imageColor,
  });

  @override
  State<ExpandableItem> createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<ExpandableItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.imageColor, // ✅ Use provided color
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage('assets/fabicon_192x192.png'),
                      fit: BoxFit.cover,
                      opacity: 0.9, // optional
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.username,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Age: ${widget.user.age}"),
                      Text("Gender: ${widget.user.gender}"),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.user.extraInfo,
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

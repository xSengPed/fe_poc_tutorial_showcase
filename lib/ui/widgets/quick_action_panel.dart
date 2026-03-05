import 'package:flutter/material.dart';

class QuickActionPanel extends StatelessWidget {
  const QuickActionPanel({super.key});

  GestureDetector _createQuickActionButton({
    String title = '',
    Icon icon = const Icon(Icons.question_mark_outlined),
    VoidCallbackAction? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap;
      },
      child: Column(
        mainAxisSize: .min,
        spacing: 4,
        children: [
          CircleAvatar(child: icon),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Card(
        elevation: 0,
        child: Row(
          crossAxisAlignment: .center,
          mainAxisAlignment: .spaceEvenly,
          children: [
            _createQuickActionButton(icon: Icon(Icons.monitor), title: 'Menu 1'),
            _createQuickActionButton(icon: Icon(Icons.monitor), title: 'Menu 2'),
            _createQuickActionButton(icon: Icon(Icons.monitor), title: 'Menu 3'),
            _createQuickActionButton(icon: Icon(Icons.monitor), title: 'Menu 4'),
            _createQuickActionButton(icon: Icon(Icons.monitor), title: 'Menu 5'),
          ],
        ),
      ),
    );
  }
}

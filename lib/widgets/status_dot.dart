import 'package:flutter/material.dart';

// status indicator placed near usernames
// cant trade with offline ppl, hence its pretty useful
// moved from recent orders bcs its useful to have everywhere
class StatusDot extends StatelessWidget {
  final String status;

  const StatusDot({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'ingame':
        color = Colors.green;
        break;
      case 'online':
        color = Colors.lightBlue;
        break;
      default:
        color = Colors.grey;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:scankit/core/theme.dart';

class IconBadge extends StatelessWidget {
  final IconData icon;
  const IconBadge(this.icon, {super.key});

  @override
  Widget build(BuildContext context) =>
      CircleAvatar(backgroundColor: teal.withOpacity(.12), child: Icon(icon, color: teal));
}

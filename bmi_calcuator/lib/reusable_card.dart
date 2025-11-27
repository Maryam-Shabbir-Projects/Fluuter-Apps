import 'package:flutter/material.dart';
import 'constants.dart'; 

// Reusable card container (The dark boxes for all inputs)
class RepeatContainerCode extends StatelessWidget {
  const RepeatContainerCode({super.key, required this.color, this.cardChild, this.onPress});

  final Color color;
  final Widget? cardChild;
  final VoidCallback? onPress; 

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress, 
      child: Container(
        margin: const EdgeInsets.all(kCardMargin),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(kCardBorderRadius),
        ),
        child: cardChild,
      ),
    );
  }
}
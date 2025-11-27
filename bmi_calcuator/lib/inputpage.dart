import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key, required this.title});

  final String title;

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  // A reusable container style
  BoxDecoration cardStyle = BoxDecoration(
    color: const Color(0xFF1D1E83),       // blackish-grey
    borderRadius: BorderRadius.circular(15),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // full black background
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: <Widget>[
          // ---------------- ROW 1 ----------------
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    decoration: cardStyle,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    decoration: cardStyle,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: cardStyle,
            ),
          ),
          // ---------------- ROW 2 ----------------
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    decoration: cardStyle,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    decoration: cardStyle,
                  ),
                ),
              ],
            ),
          ),

          // ---------------- SINGLE LARGE BOX ----------------

        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Counter Extended',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: ' Counter APP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      _checkMultipleOfTen();
    });
  }

  void _decrementCounter() {
    if (_counter > 0) {
      setState(() {
        _counter--;
        _checkMultipleOfTen();
      });
    }
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _checkMultipleOfTen();
    });
  }

  void _doubleCounter() {
    setState(() {
      _counter *= 2;
      _checkMultipleOfTen();
    });
  }

  void _halveCounter() {
    setState(() {
      _counter = (_counter ~/ 2); // integer division
      _checkMultipleOfTen();
    });
  }

  void _toggleSign() {
    setState(() {
      _counter = -_counter;
      _checkMultipleOfTen();
    });
  }

  void _checkMultipleOfTen() {
    if (_counter != 0 && _counter % 10 == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Counter hit a multiple of 10: $_counter'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('+1'),
                ),
                ElevatedButton(
                  onPressed: _counter > 0 ? _decrementCounter : null,
                  child: const Text('-1'),
                ),
                ElevatedButton(
                  onPressed: _resetCounter,
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _doubleCounter,
                  child: const Text('Double'),
                ),
                ElevatedButton(
                  onPressed: _halveCounter,
                  child: const Text('Halve'),
                ),
                ElevatedButton(
                  onPressed: _toggleSign,
                  child: const Text('+/-'),
                ),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

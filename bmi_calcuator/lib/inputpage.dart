
import 'package:flutter/material.dart';
class InputPage extends StatefulWidget {
  const InputPage({super.key, required this.title});

  final String title;

  @override
  State<InputPage> createState() => _InputPageState();
}

// 3️⃣ _InputPageState Class
class _InputPageState extends State<InputPage> {
  final TextEditingController heightCtrl = TextEditingController();
  final TextEditingController weightCtrl = TextEditingController();

  double? bmi;
  String resultMsg = "";

  void calculateBMI() {
    final double? height = double.tryParse(heightCtrl.text);
    final double? weight = double.tryParse(weightCtrl.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      setState(() {
        bmi = null;
        resultMsg = "Please enter valid numbers!";
      });
      return;
    }

    final double hMeters = height / 100;
    final double calcBMI = weight / (hMeters * hMeters);

    setState(() {
      bmi = calcBMI;

      if (calcBMI < 18.5) {
        resultMsg = "Underweight";
      } else if (calcBMI >= 18.5 && calcBMI < 24.9) {
        resultMsg = "Normal Weight";
      } else if (calcBMI >= 25 && calcBMI < 29.9) {
        resultMsg = "Overweight";
      } else {
        resultMsg = "Obese";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: heightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Height (cm)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateBMI,
              child: const Text("Calculate BMI"),
            ),
            const SizedBox(height: 30),
            if (bmi != null)
              Column(
                children: [
                  Text(
                    "Your BMI: ${bmi!.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    resultMsg,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
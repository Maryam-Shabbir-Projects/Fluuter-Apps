import 'package:flutter/material.dart';
import 'constants.dart';
import 'reusable_card.dart';

class ResultsPage extends StatelessWidget {
  
  final String bmiResult;
  final String resultText;
  final String interpretation;

  const ResultsPage({
    super.key, 
    required this.bmiResult, 
    required this.resultText, 
    required this.interpretation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI CALCULATOR'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: <Widget>[
          // 1. YOUR RESULT Header (Layout fix for display)
          Container(
            padding: const EdgeInsets.only(top: 20.0, left: 15.0, bottom: 10.0),
            height: 100.0, 
            alignment: Alignment.bottomLeft, 
            child: const Text(
              'Your Result',
              style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
            ),
          ),
          
          // 2. MAIN RESULT CARD (Displays data)
          Expanded(
            flex: 5,
            child: RepeatContainerCode(
              color: kActiveCardColor,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Result Status Text
                  Text(
                    resultText.toUpperCase(), 
                    style: const TextStyle(
                      color: Color(0xFF24D876), 
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // BMI Score Number
                  Text(
                    bmiResult, 
                    style: kNumberTextStyle.copyWith(fontSize: 100.0), 
                  ),
                  
                  // Interpretation Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Text(
                      interpretation, 
                      textAlign: TextAlign.center,
                      style: kLabelTextStyle.copyWith(fontSize: 20.0), 
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 3. RE-CALCULATE Button
          GestureDetector(
            onTap: () {
              Navigator.pop(context); 
            },
            child: Container(
              color: kBottomContainerColor,
              width: double.infinity,
              height: kBottomContainerHeight,
              margin: EdgeInsets.zero, 
              child: const Center(
                child: Text(
                  'RE-CALCULATE',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart'; // <--- ESSENTIAL IMPORT FOR WIDGETS AND NAVIGATOR
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'bmi_calculator.dart';
import 'constants.dart'; 
import 'reusable_card.dart'; 
import 'round_icon_button.dart'; 
import 'results_page.dart'; // <--- NEW IMPORT FOR NAVIGATION TARGET

// Enum for state management
enum Gender { male, female }

// 2. INPUT PAGE WIDGET
class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

// 3. STATE CLASS: Builds the UI and manages state
class _InputPageState extends State<InputPage> {
  // State variables
  Gender? selectedGender; 
  int height = 180; 
  int weight = 60; 
  int age = 19; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI CALCULATOR'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: <Widget>[
            // 1. GENDER CARDS (Row of 2)
            SizedBox(
              height: 200, 
              child: Row(
                children: <Widget>[
                  // Male Card
                  Expanded(
                    child: RepeatContainerCode(
                      color: selectedGender == Gender.male ? kActiveCardColor : kInactiveCardColor,
                      onPress: () { setState(() { selectedGender = Gender.male; }); },
                      cardChild: const IconContent(
                        icon: FontAwesomeIcons.mars,
                        label: 'MALE',
                      ),
                    ),
                  ), 
                  // Female Card
                  Expanded(
                    child: RepeatContainerCode(
                      color: selectedGender == Gender.female ? kActiveCardColor : kInactiveCardColor,
                      onPress: () { setState(() { selectedGender = Gender.female; }); },
                      cardChild: const IconContent(
                        icon: FontAwesomeIcons.venus,
                        label: 'FEMALE',
                      ),
                    ),
                  ),
                ],
              ),
            ), 
            
            // 2. HEIGHT CARD (Slider)
            SizedBox(
              height: 250, 
              child: RepeatContainerCode(
                color: kActiveCardColor,
                cardChild: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('HEIGHT', style: kLabelTextStyle),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic, 
                      children: <Widget>[
                        Text(height.toString(), style: kNumberTextStyle), 
                        const Text('cm', style: kLabelTextStyle),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        inactiveTrackColor: const Color(0xFF8D8E98),
                        activeTrackColor: Colors.white,
                        thumbColor: const Color(0xFFEB1555), 
                        overlayColor: const Color(0x29EB1555), 
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 30.0),
                      ),
                      child: Slider(
                        value: height.toDouble(), min: 120.0, max: 220.0, 
                        onChanged: (double newValue) {
                          setState(() { height = newValue.round(); });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 3. WEIGHT & AGE CARDS (Row of 2)
            SizedBox(
              height: 200, 
              child: Row(
                children: <Widget>[
                  // Weight Card
                  Expanded(
                    child: RepeatContainerCode(
                      color: kActiveCardColor,
                      cardChild: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('WEIGHT', style: kLabelTextStyle),
                          Text(weight.toString(), style: kNumberTextStyle),
                          Row( 
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RoundIconButton(
                                icon: FontAwesomeIcons.minus,
                                onPressed: () {
                                  setState(() {
                                    weight = (weight > 1) ? weight - 1 : 1; // Prevent going below 1
                                  });
                                },
                              ),
                              const SizedBox(width: 10.0),
                              RoundIconButton(
                                icon: FontAwesomeIcons.plus,
                                onPressed: () {
                                  setState(() {
                                    weight++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Age Card
                  Expanded(
                    child: RepeatContainerCode(
                      color: kActiveCardColor,
                      cardChild: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('AGE', style: kLabelTextStyle),
                          Text(age.toString(), style: kNumberTextStyle), 
                          Row( 
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RoundIconButton(
                                icon: FontAwesomeIcons.minus,
                                onPressed: () {
                                  setState(() {
                                    age = (age > 1) ? age - 1 : 1; // Prevent going below 1
                                  });
                                },
                              ),
                              const SizedBox(width: 10.0),
                              RoundIconButton(
                                icon: FontAwesomeIcons.plus,
                                onPressed: () {
                                  setState(() {
                                    age++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Calculate Button (Using Navigator)
            // Inside input_page.dart (Focus on the GestureDetector)

// ... existing code above ...

// Calculate Button (Updated to Calculate and Navigate)
GestureDetector(
  onTap: () {
    // 1. Create the calculator object using current state values
    BMICalculator calc = BMICalculator(height: height, weight: weight);

    // 2. Navigate to the ResultsPage, passing the required data
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          // Passing calculated data to the ResultsPage constructor
          bmiResult: calc.calculateBMI(),
          resultText: calc.getResult(),
          interpretation: calc.getInterpretation(),
        ),
      ),
    );
  },
  
              child: Container(
                color: kBottomContainerColor, 
                width: double.infinity,
                height: kBottomContainerHeight,
                margin: const EdgeInsets.only(top: 10.0), 
                child: const Center(
                  child: Text(
                    'CALCULATE YOUR BMI', 
                    style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ), 
    ); 
  }
}

// IconContent widget (Remains the same)
class IconContent extends StatelessWidget {
  const IconContent({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FaIcon(
          icon,
          size: kIconSize,
          color: Colors.white,
        ),
        kHeightSpacer, 
        Text(
          label,
          style: kLabelTextStyle,
        ),
      ],
    );
  }
}
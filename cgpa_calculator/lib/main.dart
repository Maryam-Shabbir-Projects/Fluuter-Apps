import 'package:flutter/material.dart';

void main() => runApp(const CGPACalculatorApp());

class CGPACalculatorApp extends StatelessWidget {
  const CGPACalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.teal.shade300, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.teal.shade300, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
////////////////////////////////////////////////////////////////////////////////
/// HOME SCREEN
////////////////////////////////////////////////////////////////////////////////
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('CGPA Calculator Home')),
        backgroundColor: Colors.teal,
        toolbarHeight: 50,
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Scaffold.of(ctx).openEndDrawer();
              },
            ),
          ),

        ],
      ),
      endDrawer: const SettingsDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navButton(context, 'Subject GPA', 0),
              const SizedBox(height: 18),
              _navButton(context, 'Semester GPA', 1),
              const SizedBox(height: 18),
              _navButton(context, 'CGPA', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(BuildContext ctx, String label, int startIndex) {
    return SizedBox(
      width: 300,
      height: 40,
      child:  ElevatedButton(
        onPressed: () {
          Navigator.push(
            ctx,
            MaterialPageRoute(
                builder: (_) => MainNavigation(startIndex: startIndex)),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 58),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// SETTINGS DRAWER
////////////////////////////////////////////////////////////////////////////////
class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 80,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal,),

              child: Center(
                child: const Text(

                  'Settings',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.grade),
            title: const Text('Grade Scale'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GradeScaleScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: const Text('Total GPA'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TotalGPAScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Total GPA Screen
////////////////////////////////////////////////////////////////////////////////
class TotalGPAScreen extends StatefulWidget {
  const TotalGPAScreen({super.key});
  @override
  State<TotalGPAScreen> createState() => _TotalGPAScreenState();
}

class _TotalGPAScreenState extends State<TotalGPAScreen> {
  double maxGPA = 4.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Total GPA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Select Total GPA Scale:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          DropdownButton<double>(
            value: maxGPA,
            items: const [
              DropdownMenuItem(value: 4.0, child: Text('4.0')),
              DropdownMenuItem(value: 5.0, child: Text('5.0')),
              DropdownMenuItem(value: 10.0, child: Text('10.0')),
            ],
            onChanged: (v) {
              setState(() {
                maxGPA = v!;
              });
            },
          ),
          const SizedBox(height: 24),
          Text('Current total GPA scale: $maxGPA',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
        ]),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// GRADE SCALE SCREEN
////////////////////////////////////////////////////////////////////////////////
class GradeScaleScreen extends StatefulWidget {
  const GradeScaleScreen({super.key});

  @override
  State<GradeScaleScreen> createState() => _GradeScaleScreenState();
}

class _GradeScaleScreenState extends State<GradeScaleScreen> {
  final List<Map<String, dynamic>> gradeList = [
    {'grade': 'A+', 'gpa': 4.0, 'marks': 85},
    {'grade': 'A', 'gpa': 3.7, 'marks': 80},
    {'grade': 'A-', 'gpa': 3.3, 'marks': 75},
    {'grade': 'B+', 'gpa': 3.0, 'marks': 70},
    {'grade': 'B', 'gpa': 2.7, 'marks': 65},
    {'grade': 'B-', 'gpa': 2.3, 'marks': 60},
    {'grade': 'C+', 'gpa': 2.0, 'marks': 55},
    {'grade': 'C', 'gpa': 1.7, 'marks': 50},
    {'grade': 'F', 'gpa': 0.0, 'marks': 0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grade Scale')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.teal.shade100),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          columns: const [
            DataColumn(label: Text('Grade')),
            DataColumn(label: Text('GPA')),
            DataColumn(label: Text('Marks')),
          ],
          rows: gradeList
              .map(
                (item) => DataRow(cells: [
              DataCell(Text(item['grade'].toString())),
              DataCell(Text(item['gpa'].toStringAsFixed(1))),
              DataCell(
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: item['marks'].toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      if (val != null) {
                        setState(() {
                          item['marks'] = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ]),
          )
              .toList(),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// MAIN NAVIGATION
////////////////////////////////////////////////////////////////////////////////
class MainNavigation extends StatefulWidget {
  final int startIndex;
  const MainNavigation({super.key, this.startIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int currentIndex;

  final List<Widget> pages = const [
    SubjectGPAScreen(),
    SemesterGPAHome(),
    CGPAScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        height: 66,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book), label: 'Subject GPA'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Semester GPA'),
          NavigationDestination(icon: Icon(Icons.grade), label: 'CGPA'),
        ],
      ),
    );
  }
}


///////////////////////////////////////////////////////////////////////////////
/// Subject GPA Screen
///////////////////////////////////////////////////////////////////////////////


class SubjectGPAScreen extends StatefulWidget {
  const SubjectGPAScreen({super.key});
  @override
  State<SubjectGPAScreen> createState() => _SubjectGPAScreenState();
}

class _SubjectGPAScreenState extends State<SubjectGPAScreen> {
  int quizCount = 0;
  int assignmentCount = 0;

  List<TextEditingController> quizTotal = [];
  List<TextEditingController> quizObt = [];
  List<TextEditingController> assignTotal = [];
  List<TextEditingController> assignObt = [];

  final TextEditingController midTotal = TextEditingController();
  final TextEditingController midObt = TextEditingController();
  final TextEditingController finalTotal = TextEditingController();
  final TextEditingController finalObt = TextEditingController();

  double resultGPA = 0.0;

  // Fixed column widths
  final double col1Width = 100; // Label
  final double col2Width = 150; // Total
  final double col3Width = 150; // Obtained

  void setQuizCount(String v) {
    final n = int.tryParse(v) ?? 0;
    setState(() {
      quizCount = n;
      quizTotal = List.generate(n, (_) => TextEditingController());
      quizObt = List.generate(n, (_) => TextEditingController());
    });
  }

  void setAssignmentCount(String v) {
    final n = int.tryParse(v) ?? 0;
    setState(() {
      assignmentCount = n;
      assignTotal = List.generate(n, (_) => TextEditingController());
      assignObt = List.generate(n, (_) => TextEditingController());
    });
  }

  double _marksToGPA(double marks) {
    if (marks >= 85) return 4.0;
    if (marks >= 80) return 3.7;
    if (marks >= 75) return 3.3;
    if (marks >= 70) return 3.0;
    if (marks >= 65) return 2.7;
    if (marks >= 60) return 2.3;
    if (marks >= 55) return 2.0;
    if (marks >= 50) return 1.7;
    return 0.0;
  }

  void calculateSubject() {
    double totalQuiz = 0, obtainedQuiz = 0;
    for (int i = 0; i < quizCount; i++) {
      final t = double.tryParse(quizTotal[i].text) ?? 0;
      final o = double.tryParse(quizObt[i].text) ?? 0;
      totalQuiz += t;
      obtainedQuiz += o;
    }
    double totalAssign = 0, obtainedAssign = 0;
    for (int i = 0; i < assignmentCount; i++) {
      final t = double.tryParse(assignTotal[i].text) ?? 0;
      final o = double.tryParse(assignObt[i].text) ?? 0;
      totalAssign += t;
      obtainedAssign += o;
    }

    double quizAssignPercent = 0;
    if (totalQuiz + totalAssign > 0) {
      quizAssignPercent = ((obtainedQuiz + obtainedAssign) / (totalQuiz + totalAssign)) * 100;
    }

    double midP = (double.tryParse(midTotal.text) ?? 0) > 0
        ? (double.tryParse(midObt.text) ?? 0) / (double.tryParse(midTotal.text) ?? 1) * 100
        : 0;
    double finalP = (double.tryParse(finalTotal.text) ?? 0) > 0
        ? (double.tryParse(finalObt.text) ?? 0) / (double.tryParse(finalTotal.text) ?? 1) * 100
        : 0;

    double overall = (quizAssignPercent * 0.25) + (midP * 0.25) + (finalP * 0.5);
    setState(() {
      resultGPA = _marksToGPA(overall);
    });
  }

  Widget _roundedField({
    required TextEditingController controller,
    String? label,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return SizedBox(
      width: col2Width,
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        ),
      ),
    );
  }

  Widget _tableHeader(List<String> headers) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: col1Width,
            child: Center(
              child: Text(headers[0],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(
            width: col2Width,
            child: Center(
              child: Text(headers[1],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(
            width: col3Width,
            child: Center(
              child: Text(headers[2],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRowNumbered({
    required int index,
    required String labelPrefix,
    required TextEditingController totalController,
    required TextEditingController obtController,
  }) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: col1Width,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('$labelPrefix ${index + 1}'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: _roundedField(controller: totalController, label: 'Total'),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: _roundedField(controller: obtController, label: 'Obtained'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var c in quizTotal) c.dispose();
    for (var c in quizObt) c.dispose();
    for (var c in assignTotal) c.dispose();
    for (var c in assignObt) c.dispose();
    midTotal.dispose();
    midObt.dispose();
    finalTotal.dispose();
    finalObt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject GPA'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quiz count
            SizedBox(
              width: 250,
              height: 35,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Total Quizzes',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: setQuizCount,
              ),
            ),
            const SizedBox(height: 8),
            if (quizCount > 0) ...[
              _tableHeader(['Quiz', 'Total Marks', 'Obtained Marks']),
              const SizedBox(height: 6),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Column(
                  children: List.generate(quizCount, (i) {
                    return _tableRowNumbered(
                      index: i,
                      labelPrefix: 'Quiz',
                      totalController: quizTotal[i],
                      obtController: quizObt[i],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Assignment count
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: 250,
                height: 35,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Total Assignments',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: setAssignmentCount,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (assignmentCount > 0) ...[
              _tableHeader(['Assignment', 'Total Marks', 'Obtained Marks']),
              const SizedBox(height: 6),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Column(
                  children: List.generate(assignmentCount, (i) {
                    return _tableRowNumbered(
                      index: i,
                      labelPrefix: 'Assignment',
                      totalController: assignTotal[i],
                      obtController: assignObt[i],
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: const SizedBox(height: 14),
              ),
            ],

            // Mid and Final exams
            _tableHeader(['Exam', 'Total Marks', 'Obtained Marks']),
            const SizedBox(height: 6),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: col1Width,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Mid'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: _roundedField(controller: midTotal, label: 'Total'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: _roundedField(controller: midObt, label: 'Obtained'),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: col1Width,
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('Final'),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: _roundedField(controller: finalTotal, label:'Total'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: _roundedField(controller: finalObt, label: 'Obtained'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18, ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: calculateSubject,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal,
                    minimumSize: const Size.fromHeight(48,)),
                child: const Text('Calculate GPA',style: TextStyle(
                  color: Colors.white,
                ),),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'GPA: ${resultGPA.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Semester GPA home (menu for by marks / by GPA)
///////////////////////////////////////////////////////////////////////////////
class SemesterGPAHome extends StatelessWidget {
  const SemesterGPAHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semester GPA '),
        backgroundColor: Colors.teal,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterByMarksScreen())),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: Colors.teal),
                child: const Text('By Subject Marks', style: TextStyle(fontSize: 18,
                  color:Colors.black,)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterByGPAScreen())),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: Colors.teal),
                child: const Text('By Subject GPA', style: TextStyle(fontSize: 18,
                  color: Colors.black,)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Semester By GPA (compact table)
///////////////////////////////////////////////////////////////////////////////
class SemesterByGPAScreen extends StatefulWidget {
  const SemesterByGPAScreen({super.key});

  @override
  State<SemesterByGPAScreen> createState() => _SemesterByGPAScreenState();
}

class _SemesterByGPAScreenState extends State<SemesterByGPAScreen> {
  int subjectCount = 0;
  List<TextEditingController> gpaControllers = [];
  List<TextEditingController> creditControllers = [];
  double semesterGPA = 0.0;

  void setSubjectCount(String v) {
    final n = int.tryParse(v) ?? 0;
    setState(() {
      subjectCount = n;
      gpaControllers = List.generate(n, (_) => TextEditingController());
      creditControllers = List.generate(n, (_) => TextEditingController());
    });
  }

  void calculateSemesterGPA_byGPA() {
    double totalPoints = 0;
    double totalCredits = 0;
    for (int i = 0; i < subjectCount; i++) {
      final g = double.tryParse(gpaControllers[i].text) ?? 0;
      final c = double.tryParse(creditControllers[i].text) ?? 0;
      totalPoints += g * c;
      totalCredits += c;
    }
    setState(() {
      semesterGPA = totalCredits > 0 ? totalPoints / totalCredits : 0;
    });
  }

  @override
  void dispose() {
    for (var c in gpaControllers) c.dispose();
    for (var c in creditControllers) c.dispose();
    super.dispose();
  }

  Widget _smallField({required TextEditingController controller, String? label}) {
    return SizedBox(
      width: 100, // smaller width
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester GPA (By GPA)'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 250,
                height: 40,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Total subjects'),
                  keyboardType: TextInputType.number,
                  onChanged: setSubjectCount,
                ),
              ),
              const SizedBox(height: 12),
              if (subjectCount > 0) _tableHeader(['Subject', 'GPA', 'Credit Hours']),
              const SizedBox(height: 8),
              ...List.generate(subjectCount, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // center align the row
                    children: [
                      SizedBox(
                        width: 40,
                        child: Center(child: Text('${i + 1}')),
                      ),
                      const SizedBox(width: 12),
                      _smallField(controller: gpaControllers[i], label: 'GPA'),
                      const SizedBox(width: 12),
                      _smallField(controller: creditControllers[i], label: 'Credit'),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),
              SizedBox(
                width: 150,
                height: 48,
                child: ElevatedButton(
                  onPressed: calculateSemesterGPA_byGPA,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // change button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Calculate GPA',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Semester GPA: ${semesterGPA.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(List<String> headers) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // center align header
        children: headers.map((h) {
          return SizedBox(
            width: h == 'Subject' ? 40 : 100, // match width of columns
            child: Center(
              child: Text(
                h,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


///////////////////////////////////////////////////////////////////////////////
/// Semester By Marks - compact subject table + lab details per 4-credit subject
///////////////////////////////////////////////////////////////////////////////


class SemesterByMarksScreen extends StatefulWidget {
  const SemesterByMarksScreen({super.key});

  @override
  State<SemesterByMarksScreen> createState() => _SemesterByMarksScreenState();
}

class _SemesterByMarksScreenState extends State<SemesterByMarksScreen> {
  int subjectCount = 0;
  List<TextEditingController> subjTotal = [];
  List<TextEditingController> subjObt = [];
  List<TextEditingController> subjCredit = [];

  // Lab toggle & details
  List<bool> labEnabled = [];
  List<int> labQuizCount = [];
  List<List<TextEditingController>> labQuizTot = [];
  List<List<TextEditingController>> labQuizObt = [];
  List<int> labAssignCount = [];
  List<List<TextEditingController>> labAssignTot = [];
  List<List<TextEditingController>> labAssignObt = [];
  List<TextEditingController> labMidTot = [];
  List<TextEditingController> labMidObt = [];
  List<TextEditingController> labFinalTot = [];
  List<TextEditingController> labFinalObt = [];

  double semesterGPA = 0.0;

  void setSubjectCount(String v) {
    final n = int.tryParse(v) ?? 0;
    setState(() {
      subjectCount = n;
      subjTotal = List.generate(n, (_) => TextEditingController());
      subjObt = List.generate(n, (_) => TextEditingController());
      subjCredit = List.generate(n, (_) => TextEditingController());
      labEnabled = List.generate(n, (_) => false);
      labQuizCount = List.generate(n, (_) => 0);
      labQuizTot = List.generate(n, (_) => <TextEditingController>[]);
      labQuizObt = List.generate(n, (_) => <TextEditingController>[]);
      labAssignCount = List.generate(n, (_) => 0);
      labAssignTot = List.generate(n, (_) => <TextEditingController>[]);
      labAssignObt = List.generate(n, (_) => <TextEditingController>[]);
      labMidTot = List.generate(n, (_) => TextEditingController());
      labMidObt = List.generate(n, (_) => TextEditingController());
      labFinalTot = List.generate(n, (_) => TextEditingController());
      labFinalObt = List.generate(n, (_) => TextEditingController());
    });
  }

  double _marksToGPA(double marks) {
    if (marks >= 85) return 4.0;
    if (marks >= 80) return 3.7;
    if (marks >= 75) return 3.3;
    if (marks >= 70) return 3.0;
    if (marks >= 65) return 2.7;
    if (marks >= 60) return 2.3;
    if (marks >= 55) return 2.0;
    if (marks >= 50) return 1.7;
    return 0.0;
  }

  double _avgPercentFromPairs(
      List<TextEditingController> obt, List<TextEditingController> tot) {
    double totalPercent = 0;
    int count = 0;
    for (int i = 0; i < obt.length && i < tot.length; i++) {
      double o = double.tryParse(obt[i].text) ?? 0;
      double t = double.tryParse(tot[i].text) ?? 0;
      if (t > 0) {
        totalPercent += (o / t) * 100;
        count++;
      }
    }
    return count > 0 ? totalPercent / count : 0;
  }

  void calculateSemesterByMarks() {
    double totalPoints = 0;
    double totalCredits = 0;

    for (int i = 0; i < subjectCount; i++) {
      double t = double.tryParse(subjTotal[i].text) ?? 0;
      double o = double.tryParse(subjObt[i].text) ?? 0;
      double cr = double.tryParse(subjCredit[i].text) ?? 0;

      double subjectPercent = t > 0 ? (o / t) * 100 : 0;
      double subjectGPA = _marksToGPA(subjectPercent);

      if (cr == 4 && labEnabled[i]) {
        double quizPercent = _avgPercentFromPairs(labQuizObt[i], labQuizTot[i]);
        double assignPercent =
        _avgPercentFromPairs(labAssignObt[i], labAssignTot[i]);
        double qa = (quizPercent + assignPercent) / 2;
        double midPercent = (double.tryParse(labMidTot[i].text) ?? 0) > 0
            ? (double.tryParse(labMidObt[i].text) ?? 0) /
            (double.tryParse(labMidTot[i].text) ?? 1) *
            100
            : 0;
        double finalPercent = (double.tryParse(labFinalTot[i].text) ?? 0) > 0
            ? (double.tryParse(labFinalObt[i].text) ?? 0) /
            (double.tryParse(labFinalTot[i].text) ?? 1) *
            100
            : 0;

        double labPercent = qa * 0.25 + midPercent * 0.25 + finalPercent * 0.5;
        double labGPA = _marksToGPA(labPercent);

        subjectGPA = subjectGPA * 0.75 + labGPA * 0.25;
      }

      totalPoints += subjectGPA * cr;
      totalCredits += cr;
    }

    setState(() {
      semesterGPA = totalCredits > 0 ? totalPoints / totalCredits : 0;
    });
  }

  @override
  void dispose() {
    for (var c in subjTotal) c.dispose();
    for (var c in subjObt) c.dispose();
    for (var c in subjCredit) c.dispose();
    for (var list in labQuizTot) for (var c in list) c.dispose();
    for (var list in labQuizObt) for (var c in list) c.dispose();
    for (var list in labAssignTot) for (var c in list) c.dispose();
    for (var list in labAssignObt) for (var c in list) c.dispose();
    for (var c in labMidTot) c.dispose();
    for (var c in labMidObt) c.dispose();
    for (var c in labFinalTot) c.dispose();
    for (var c in labFinalObt) c.dispose();
    super.dispose();
  }

  Widget _tableField({required TextEditingController controller, String? label}) {
    return SizedBox(
      width: 200,
      height: 45,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text('Semester GPA (By Marks)'), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 250,
                height: 40,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Total Subjects'),
                  keyboardType: TextInputType.number,
                  onChanged: setSubjectCount,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(subjectCount, (i) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Subject ${i + 1}'),
                        const SizedBox(width: 8),
                        _tableField(controller: subjTotal[i], label: 'Total marks'),
                        const SizedBox(width: 8),
                        _tableField(controller: subjObt[i], label: 'Obtained marks'),
                        const SizedBox(width: 8),
                        _tableField(controller: subjCredit[i], label: 'Credit hours'),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Lab'),
                            value: labEnabled[i],
                            onChanged: (v) => setState(() => labEnabled[i] = v ?? false),
                          ),
                        ),
                      ],
                    ),
                    if (labEnabled[i]) _labSection(i),
                  ],
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: calculateSemesterByMarks,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Calculate GPA'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Semester GPA: ${semesterGPA.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labSection(int idx) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 45,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'No. of Lab Quizzes'),
                onChanged: (val) {
                  int n = int.tryParse(val) ?? 0;
                  setState(() {
                    labQuizCount[idx] = n;
                    labQuizTot[idx] = List.generate(
                        n,
                            (i) => i < labQuizTot[idx].length
                            ? labQuizTot[idx][i]
                            : TextEditingController());
                    labQuizObt[idx] = List.generate(
                        n,
                            (i) => i < labQuizObt[idx].length
                            ? labQuizObt[idx][i]
                            : TextEditingController());
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 200,
              height: 45,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'No. of Lab Assignments'),
                onChanged: (val) {
                  int n = int.tryParse(val) ?? 0;
                  setState(() {
                    labAssignCount[idx] = n;
                    labAssignTot[idx] = List.generate(
                        n,
                            (i) => i < labAssignTot[idx].length
                            ? labAssignTot[idx][i]
                            : TextEditingController());
                    labAssignObt[idx] = List.generate(
                        n,
                            (i) => i < labAssignObt[idx].length
                            ? labAssignObt[idx][i]
                            : TextEditingController());
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (labQuizCount[idx] > 0)
    Column(
      children: List.generate(labQuizCount[idx], (j) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quiz ${j + 1}'),
            const SizedBox(width: 8),
            _tableField(controller: labQuizTot[idx][j], label: 'Total'),
            const SizedBox(width: 8),
            _tableField(controller: labQuizObt[idx][j], label: 'Obtained'),
          ],
        );
      }),
    ),
    if (labAssignCount[idx] > 0)
    Column(
    children: List.generate(labAssignCount[idx], (j) {
    return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text('Assignment ${j + 1}'),
    const SizedBox(width: 8),
    _tableField(controller: labAssignTot[idx][j], label: 'Total'),
    const SizedBox(width: 8),
    _tableField(controller: labAssignObt[idx][j], label: 'Obtained'),
    ],
    );
    }),
    ),
    const SizedBox(height: 8),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    _tableField(controller: labMidTot[idx], label: 'Lab Mid Total'),
    const SizedBox(width: 8),
    _tableField(controller: labMidObt[idx], label: 'Lab Mid Obtained'),
    ],
    ),
    const SizedBox(height: 6),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    _tableField(controller: labFinalTot[idx], label: 'Lab Final Total'),
    const SizedBox(width: 8),
      _tableField(controller: labFinalObt[idx], label: 'Lab Final Obtained'),
    ],
    ),
          ],
        ),
    );
  }
}


///////////////////////////////////////////////////////////////////////////////
/// CGPA Screen
///////////////////////////////////////////////////////////////////////////////
class CGPAScreen extends StatefulWidget {
  const CGPAScreen({super.key});
  @override
  State<CGPAScreen> createState() => _CGPAScreenState();
}

class _CGPAScreenState extends State<CGPAScreen> {
  int semesterCount = 0;
  List<TextEditingController> controllers = [];
  double cgpa = 0.0;

  void setSemesterCount(String v) {
    final n = int.tryParse(v) ?? 0;
    setState(() {
      semesterCount = n;
      controllers = List.generate(n, (_) => TextEditingController());
    });
  }

  void calculateCGPA() {
    double total = 0;
    double count = 0;
    for (var c in controllers) {
      final v = double.tryParse(c.text);
      if (v != null) {
        total += v;
        count++;
      }
    }
    setState(() {
      cgpa = count > 0 ? total / count : 0;
    });
  }

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CGPA Calculator'),
      backgroundColor: Colors.teal,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(children: [
            SizedBox(
              width: 180,
              height: 40,
              child: TextField(
                decoration: const InputDecoration(labelText: 'Total Semesters'),
                keyboardType: TextInputType.number,
                onChanged: setSemesterCount,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(semesterCount, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  width: 200,
                  height: 40,
                  child: TextField(
                    controller: controllers[i],
                    decoration: InputDecoration(labelText: 'Semester ${i + 1} GPA '),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: 170,
              child: ElevatedButton(
                  onPressed: calculateCGPA,
                  style: ElevatedButton.styleFrom(backgroundColor:Colors.teal,
                      minimumSize: const Size.fromHeight(48)),
                  child: const Text('Calculate CGPA',style: TextStyle(
                    color:Colors.white,
                  ),)),
            ),
            const SizedBox(height: 12),
            Text('CGPA: ${cgpa.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
          ]),
        ),
      ),
    );
  }
}


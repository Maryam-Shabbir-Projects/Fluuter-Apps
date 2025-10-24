import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const CommitteeApp());
}

// ------------------ APP ------------------
class CommitteeApp extends StatelessWidget {
  const CommitteeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Committee Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const CommitteeListScreen(),
    );
  }
}

// ------------------ MODELS ------------------
class Committee {
  final String id;
  String name;
  double totalAmount;
  int duration;
  String durationUnit;
  int winnerFrequency;
  int totalMembers;
  DateTime startDate;
  final List<Member> members = [];
  final List<WinnerRecord> winners = [];

  Committee({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.duration,
    required this.totalMembers,
    this.durationUnit = 'Months',
    this.winnerFrequency = 1,
  }) : startDate = DateTime.now();

  double perMemberShare() => totalMembers == 0 ? 0 : totalAmount / totalMembers;

  double totalCollected() => members.fold(0, (sum, m) => sum + m.paid);

  double totalPending() => totalAmount - totalCollected();

  bool allPaid() {
    final per = perMemberShare();
    return members.length == totalMembers &&
        members.every((m) => m.paid >= per);
  }

  bool isDurationComplete() {
    final now = DateTime.now();
    DateTime end = durationUnit == 'Months'
        ? DateTime(startDate.year, startDate.month + duration, startDate.day)
        : startDate.add(Duration(days: duration * 7));
    return now.isAfter(end) || now.isAtSameMomentAs(end);
  }

  Duration timeLeft() {
    final now = DateTime.now();
    final end = durationUnit == 'Months'
        ? DateTime(startDate.year, startDate.month + duration, startDate.day)
        : startDate.add(Duration(days: duration * 7));
    return now.isAfter(end) ? Duration.zero : end.difference(now);
  }

  List<Member> eligibleForWinning() => members.where((m) => !m.hasWon).toList();
}

class Member {
  final String id;
  String name;
  String phone;
  double paid;
  bool hasWon;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    this.paid = 0,
    this.hasWon = false,
  });

  double pendingForThisCommittee(double perMemberAmount) {
    final pending = perMemberAmount - paid;
    return pending < 0 ? 0 : pending;
  }
}

class WinnerRecord {
  final String id;
  final String memberId;
  final String memberName;
  final DateTime date;
  final double prizeAmount;

  WinnerRecord({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.prizeAmount,
  });
}

// ------------------ COMMITTEE LIST ------------------
class CommitteeListScreen extends StatefulWidget {
  const CommitteeListScreen({super.key});

  @override
  State<CommitteeListScreen> createState() => _CommitteeListScreenState();
}

class _CommitteeListScreenState extends State<CommitteeListScreen> {
  final List<Committee> _committees = [];
  final _uuid = const Uuid();

  void _createCommittee() async {
    final created = await Navigator.push<Committee>(
      context,
      MaterialPageRoute(builder: (_) => const CreateCommitteeScreen()),
    );
    if (created != null) setState(() => _committees.add(created));
  }

  void _openCommittee(Committee committee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommitteeDetailScreen(committee: committee),
      ),
    ).then((_) => setState(() {}));
  }

  Widget _barChart() {
    if (_committees.isEmpty) return const SizedBox(height: 180);

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < _committees.length; i++) {
      final c = _committees[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: c.totalAmount, color: Colors.indigo),
            BarChartRodData(toY: c.totalCollected(), color: Colors.green),
            BarChartRodData(toY: c.totalPending(), color: Colors.red),
          ],
          showingTooltipIndicators: [0, 1, 2],
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: BarChart(
          BarChartData(
            maxY: _committees.map((c) => c.totalAmount).reduce(max) * 1.2,
            barGroups: barGroups,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < _committees.length) {
                      return Text(
                        _committees[index].name,
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: true),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Committees'),
      backgroundColor: Colors.blueGrey,),
      floatingActionButton: FloatingActionButton(
          onPressed: _createCommittee, child: const Icon(Icons.add)),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _barChart(),
          const SizedBox(height: 12),
          Expanded(
            child: _committees.isEmpty
                ? Center(
                  child: const Text(
                  'No committees yet.\nTap + to create one.',
                  textAlign: TextAlign.center,
                                ),
                )

                : ListView.builder(
              itemCount: _committees.length,
              itemBuilder: (context, i) {
                final c = _committees[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: Rs ${c.totalAmount.toStringAsFixed(0)}'),
                          Text('Members: ${c.members.length}/${c.totalMembers}'),
                          Text('Collected: Rs ${c.totalCollected().toStringAsFixed(0)}'),
                          Text('Pending: Rs ${c.totalPending().toStringAsFixed(0)}'),
                          Text('Winners: ${c.winners.length}'),
                        ]),
                    onTap: () => _openCommittee(c),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// ------------------ CREATE COMMITTEE ------------------
class CreateCommitteeScreen extends StatefulWidget {
  const CreateCommitteeScreen({super.key});

  @override
  State<CreateCommitteeScreen> createState() => _CreateCommitteeScreenState();
}

class _CreateCommitteeScreenState extends State<CreateCommitteeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  String _name = '';
  double _totalAmount = 0;
  int _duration = 1;
  String _durationUnit = 'Months';
  int _winnerFrequency = 1;
  int _totalMembers = 0;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final c = Committee(
      id: _uuid.v4(),
      name: _name,
      totalAmount: _totalAmount,
      duration: _duration,
      durationUnit: _durationUnit,
      winnerFrequency: _winnerFrequency,
      totalMembers: _totalMembers,
    );
    Navigator.pop(context, c);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Committee'),
      backgroundColor: Colors.blueGrey,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          TextFormField(
          decoration: const InputDecoration(labelText: 'Committee Name'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
          onSaved: (v) => _name = v!.trim(),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Total Amount (Rs)'),
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter amount' : null,
          onSaved: (v) => _totalAmount = double.tryParse(v ?? '0') ?? 0,
        ),
        const SizedBox(height: 12),
        Row(children: [
        Expanded(
        child: TextFormField(
        decoration: const InputDecoration(labelText: 'Duration'),
        keyboardType: TextInputType.number,
        initialValue: '1',
        onSaved: (v) => _duration = int.tryParse(v ?? '1') ?? 1,
      ),
    ),
    const SizedBox(width: 12),
    DropdownButton<String>(
    value: _durationUnit,
    items: const [
    DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
    DropdownMenuItem(value: 'Months', child: Text('Months')),
    ],
      onChanged: (v) => setState(() => _durationUnit = v ?? 'Months'),
    )
        ]),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Winner Frequency (rounds)'),
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  onSaved: (v) => _winnerFrequency = int.tryParse(v ?? '1') ?? 1,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Total Members (number)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter number' : null,
                  onSaved: (v) => _totalMembers = int.tryParse(v ?? '0') ?? 0,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Create Committee'),

                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }
}

// ------------------ COMMITTEE DETAIL ------------------
class CommitteeDetailScreen extends StatefulWidget {
  final Committee committee;
  const CommitteeDetailScreen({super.key, required this.committee});

  @override
  State<CommitteeDetailScreen> createState() => _CommitteeDetailScreenState();
}

class _CommitteeDetailScreenState extends State<CommitteeDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // ------------------ MEMBER FUNCTIONS ------------------
  void _addMember() {
    if (widget.committee.members.length >= widget.committee.totalMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All members already added')),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
              setState(() {
                widget.committee.members.add(Member(
                  id: _uuid.v4(),
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _editMember(Member m) {
    final nameCtrl = TextEditingController(text: m.name);
    final phoneCtrl = TextEditingController(text: m.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                m.name = nameCtrl.text.trim();
                m.phone = phoneCtrl.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _recordPayment(Member m) {
    final payCtrl = TextEditingController();
    final perShare = widget.committee.perMemberShare();
    final pending = m.pendingForThisCommittee(perShare);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment for ${m.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pending: Rs ${pending.toStringAsFixed(0)}'),
            TextField(
              controller: payCtrl,
              decoration: const InputDecoration(labelText: 'Amount to add'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final add = double.tryParse(payCtrl.text) ?? 0;
              if (add <= 0 || add > pending) return;
              setState(() => m.paid += add);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  // ------------------ PICK WINNER ------------------
  void _pickWinner() {
    final c = widget.committee;
    if (!c.allPaid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All members must complete payment before selecting a winner.')),
      );
      return;
    }

    if (!c.isDurationComplete()) {
      final leftStr = _formatDurationShort(c.timeLeft());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duration not completed. Time left: $leftStr')),
      );
      return;
    }

    final eligible = c.eligibleForWinning();
    if (eligible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All members have already won.')),
      );
      return;
    }

    final rnd = Random();
    final winner = eligible[rnd.nextInt(eligible.length)];
    final prize = c.perMemberShare() * c.totalMembers;

    setState(() {
      winner.hasWon = true;
      c.winners.add(WinnerRecord(
        id: _uuid.v4(),
        memberId: winner.id,
        memberName: winner.name,
        date: DateTime.now(),
        prizeAmount: prize,
      ));
      c.members.forEach((m) => m.paid = 0);
      c.startDate = DateTime.now();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Winner Announced 🎉'),
        content: Text('Winner: ${winner.name}\nPrize: Rs ${prize.toStringAsFixed(0)}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  String _formatDurationShort(Duration d) {
    if (d.inDays >= 1) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }

  // ------------------ TABS ------------------
  Widget _membersTab() {
    final c = widget.committee;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Members: ${c.members.length}/${c.totalMembers}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(onPressed: _addMember, icon: const Icon(Icons.person_add), label: const Text('Add Member'))
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: c.members.length,
            itemBuilder: (context, i) {
              final m = c.members[i];
              final pending = m.pendingForThisCommittee(c.perMemberShare());
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Phone: ${m.phone}\nPaid: Rs ${m.paid.toStringAsFixed(0)} / Pending: Rs ${pending.toStringAsFixed(0)}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _editMember(m);
                      if (v == 'pay') _recordPayment(m);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit Info')),
                      PopupMenuItem(value: 'pay', child: Text('Record Payment')),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.committee.name),
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(text: 'Members'),
          Tab(text: 'Finance'),
          Tab(text: 'Winners'),
        ]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _membersTab(),
          const Center(child: Text('Finance Tab - To Be Continued')), // Can implement finance chart here
          const Center(child: Text('Winners Tab - To Be Continued')), // Can implement winners history here
        ],
      ),
    );
  }
}


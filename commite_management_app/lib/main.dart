import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const CommitteeApp());
}

class CommitteeApp extends StatelessWidget {
  const CommitteeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Committee Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
// MODELS
//////////////////////////////////////////////////////////////////////////////
class Committee {
  String name;
  List<Member> members = [];
  List<Meeting> meetings = [];
  Committee(this.name);
}

class Member {
  String id;
  String name;
  String phone;
  String email;
  bool paid;
  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.paid = false,
  });
}

class Meeting {
  String title;
  DateTime dateTime;
  String link;
  Meeting({required this.title, required this.dateTime, required this.link});
}

//////////////////////////////////////////////////////////////////////////////
// NOTIFICATION SERVICE
//////////////////////////////////////////////////////////////////////////////
class NotificationService {
  static final _notif = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: initSettingsAndroid);
    await _notif.initialize(initSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'main_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platform = NotificationDetails(android: android);
    await _notif.show(0, title, body, platform);
  }
}

//////////////////////////////////////////////////////////////////////////////
// HOME SCREEN
//////////////////////////////////////////////////////////////////////////////
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Committee> committees = [];
  final nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Committee Manager"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Committee"),
        onPressed: () => _addCommitteeDialog(),
      ),
      body: committees.isEmpty
          ? const Center(child: Text("No committees yet"))
          : ListView.builder(
        itemCount: committees.length,
        itemBuilder: (context, index) {
          final c = committees[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(c.name),
              subtitle: Text(
                  "${c.members.length} Members • ${c.meetings.length} Meetings"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommitteeScreen(committee: c),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addCommitteeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Committee"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: "Committee Name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              setState(() => committees.add(Committee(name)));
              nameCtrl.clear();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
// COMMITTEE SCREEN
//////////////////////////////////////////////////////////////////////////////
class CommitteeScreen extends StatefulWidget {
  final Committee committee;
  const CommitteeScreen({super.key, required this.committee});

  @override
  State<CommitteeScreen> createState() => _CommitteeScreenState();
}

class _CommitteeScreenState extends State<CommitteeScreen> {
  late Committee c;

  @override
  void initState() {
    super.initState();
    c = widget.committee;
  }

  Future<void> _sendWhatsApp(String phone, String msg) async {
    final url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(msg)}");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _sendEmail(String email, String subject, String body) async {
    final url = Uri.parse(
        "mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  /////////////////////////////////////////////////////////////////////////////
  // Send message to all members
  /////////////////////////////////////////////////////////////////////////////
  void _sendMessageToAll() {
    if (c.members.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No members to message")));
      return;
    }

    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Send Message to All Members"),
        content: TextField(
          controller: msgCtrl,
          decoration: const InputDecoration(
            labelText: "Message",
            hintText: "Type your message here...",
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.message),
            label: const Text("Send WhatsApp"),
            onPressed: () {
              for (var m in c.members) {
                _sendWhatsApp(m.phone, msgCtrl.text);
              }
              Navigator.pop(context);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.email),
            label: const Text("Send Email"),
            onPressed: () {
              for (var m in c.members) {
                _sendEmail(m.email, "Committee Message", msgCtrl.text);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  // Edit member details
  /////////////////////////////////////////////////////////////////////////////
  void _editMember(Member member) {
    final nameCtrl = TextEditingController(text: member.name);
    final phoneCtrl = TextEditingController(text: member.phone);
    final emailCtrl = TextEditingController(text: member.email);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Member Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Phone")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final phone = phoneCtrl.text.trim();
              final email = emailCtrl.text.trim();
              if (name.isEmpty || phone.isEmpty || email.isEmpty) return;

              setState(() {
                member.name = name;
                member.phone = phone;
                member.email = email;
              });

              NotificationService().showNotification(
                  "Member Updated", "${member.name}'s details were updated.");
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  // MAIN BUILD
  /////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(c.name),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Members"),
              Tab(icon: Icon(Icons.calendar_today), text: "Meetings"),
              Tab(icon: Icon(Icons.account_balance_wallet), text: "Finance"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: "Send Message to All Members",
              onPressed: _sendMessageToAll,
            )
          ],
        ),
        body: TabBarView(
          children: [
            _buildMembersTab(),
            _buildMeetingsTab(),
            _buildFinanceTab(),
          ],
        ),
      ),
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  // MEMBERS TAB
  /////////////////////////////////////////////////////////////////////////////
  Widget _buildMembersTab() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text("Add Member"),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Add Member"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                      TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Phone")),
                      TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        final email = emailCtrl.text.trim();

                        if (name.isEmpty || phone.isEmpty || email.isEmpty) return;

                        final m = Member(
                          id: DateTime.now().toString(),
                          name: name,
                          phone: phone,
                          email: email,
                        );
                        setState(() => c.members.add(m));
                        Navigator.pop(context);
                      },
                      child: const Text("Add"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: c.members.length,
            itemBuilder: (_, i) {
              final m = c.members[i];
              return Card(
                child: ListTile(
                  title: Text(m.name),
                  subtitle: Text("${m.phone} • ${m.email}"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _editMember(m),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.teal),
                        onPressed: () => _sendWhatsApp(m.phone, "Hello ${m.name}, message from ${c.name}."),
                      ),
                      IconButton(
                        icon: const Icon(Icons.email, color: Colors.indigo),
                        onPressed: () => _sendEmail(m.email, "Committee Update", "Hello ${m.name}, this is an update from ${c.name}."),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  // MEETINGS TAB
  /////////////////////////////////////////////////////////////////////////////
  Widget _buildMeetingsTab() {
    final titleCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    DateTime? meetingDate;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Schedule Meeting"),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("New Meeting"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
                      TextField(controller: linkCtrl, decoration: const InputDecoration(labelText: "Meeting Link")),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) meetingDate = picked;
                        },
                        child: const Text("Pick Date"),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty || meetingDate == null) return;
                        final m = Meeting(title: titleCtrl.text.trim(), dateTime: meetingDate!, link: linkCtrl.text.trim());
                        setState(() => c.meetings.add(m));
                        NotificationService().showNotification("New Meeting Scheduled", m.title);
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: c.meetings.length,
            itemBuilder: (_, i) {
              final m = c.meetings[i];
              return ListTile(
                title: Text(m.title),
                subtitle: Text("${DateFormat.yMMMd().format(m.dateTime)} • ${m.link}"),
              );
            },
          ),
        ),
      ],
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  // FINANCE TAB
  /////////////////////////////////////////////////////////////////////////////
  Widget _buildFinanceTab() {
    return ListView(
      children: c.members.map((m) {
        return SwitchListTile(
          title: Text(m.name),
          subtitle: Text(m.paid ? "Paid" : "Unpaid"),
          value: m.paid,
          onChanged: (val) {
            setState(() => m.paid = val);
            NotificationService().showNotification(
              "Finance Update",
              val ? "${m.name} has submitted payment" : "${m
                  .name} marked unpaid",
            );
          },
        );
      }).toList(),
    );
  }}

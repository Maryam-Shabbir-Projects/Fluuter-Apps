import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../models/committee.dart';
import '../models/member.dart';
import '../services/db_service.dart';
import '../ui/widgets.dart';
import 'package:uuid/uuid.dart';

class MemberScreen extends StatefulWidget {
  final Committee committee;
  MemberScreen({required this.committee});

  @override
  _MemberScreenState createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final DBService _db = DBService();
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _members = await _db.getMembersForCommittee(widget.committee.id);
    setState(() {});
  }

  // 🔹 Centered Add Member Dialog
  Future<void> _openAddMemberDialog() async {
    final _formKey = GlobalKey<FormState>();
    final _nameCtl = TextEditingController();
    final _phoneCtl = TextEditingController();
    PhoneNumber _phone = PhoneNumber(isoCode: 'PK');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Member', style: Theme.of(context).textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtl,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 10),
                InternationalPhoneNumberInput(
                  onInputChanged: (pn) => _phone = pn,
                  selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.DROPDOWN),
                  inputDecoration: const InputDecoration(labelText: 'Phone'),
                  textFieldController: _phoneCtl,
                  initialValue: _phone,
                  validator: (s) => s == null || s.trim().isEmpty ? 'Enter phone' : null,
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Add'),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              // enforce member count limit
              final current = await _db.getMembersForCommittee(widget.committee.id);
              if (current.length >= widget.committee.totalMembers) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Member limit reached')),
                );
                return;
              }

              final member = Member(
                id: const Uuid().v4(),
                committeeId: widget.committee.id,
                name: _nameCtl.text.trim(),
                phone: _phoneCtl.text.trim(),
              );
              await _db.insertMember(member);
              Navigator.pop(ctx);
              await _load();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _editMember(Member m) async {
    final _formKey = GlobalKey<FormState>();
    final _nameCtl = TextEditingController()..text = m.name;
    final _phoneCtl = TextEditingController()..text = m.phone;
    PhoneNumber phone = PhoneNumber(isoCode: 'PK');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Member'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 8),
              InternationalPhoneNumberInput(
                onInputChanged: (pn) => phone = pn,
                selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.DROPDOWN),
                inputDecoration: const InputDecoration(labelText: 'Phone'),
                textFieldController: _phoneCtl,
                initialValue: phone,
                validator: (s) => s == null || s.trim().isEmpty ? 'Enter phone' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              m.name = _nameCtl.text.trim();
              m.phone = _phoneCtl.text.trim();
              await _db.updateMember(m);
              Navigator.pop(context);
              await _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perMember = _db.perMemberPendingAmount(widget.committee);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Members',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openAddMemberDialog, // 🔹 Changed here
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Member'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _members.isEmpty
                  ? const Center(child: Text('No members yet.'))
                  : ListView.builder(
                itemCount: _members.length,
                itemBuilder: (ctx, i) {
                  final m = _members[i];
                  final pending = perMember - m.paid;
                  return AppCard(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(m.name.isNotEmpty ? m.name[0] : '?'),
                      ),
                      title: Text(m.name),
                      subtitle: Text(
                        'Phone: ${m.phone}\n'
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editMember(m),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

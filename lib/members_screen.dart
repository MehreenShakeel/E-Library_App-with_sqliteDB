// members_screen.dart
import 'package:flutter/material.dart';
import 'member_detail_screen.dart';
import '../services/database_helper.dart';

class Member {
  final int? id;
  final String name;
  final String email;
  final String image;
  final String description;

  Member({this.id, required this.name, required this.email, required this.image, required this.description});

  Member copyWithId(int id) => Member(
        id: id,
        name: name,
        email: email,
        image: image,
        description: description,
      );
}

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Member> _members = [];
  List<Member> _filteredMembers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _searchController.addListener(_filterMembers);
  }

  Future<void> _loadMembers() async {
    final members = await dbHelper.getMembers();
    setState(() {
      _members = members;
      _filteredMembers = members;
    });
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _members.where((m) {
        return m.name.toLowerCase().contains(query) || m.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Member'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'Profile Image URL')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final member = Member(
                name: nameCtrl.text,
                email: emailCtrl.text,
                image: imageCtrl.text.isEmpty ? 'https://picsum.photos/150?random=${DateTime.now().millisecondsSinceEpoch}' : imageCtrl.text,
                description: descCtrl.text,
              );
              await dbHelper.insertMember(member);
              _loadMembers();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          ElevatedButton.icon(
            onPressed: _showAddMemberDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _filteredMembers.isEmpty
          ? const Center(child: Text('No members found'))
          : ListView.builder(
              itemCount: _filteredMembers.length,
              itemBuilder: (context, index) {
                final member = _filteredMembers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(member.image)),
                    title: Text(member.name),
                    subtitle: Text(member.email),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (member.id != null) {
                          await dbHelper.deleteMember(member.id!);
                          _loadMembers();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
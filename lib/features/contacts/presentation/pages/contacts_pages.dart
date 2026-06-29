import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _dummyContacts = [
    {"name": "Aarav Sharma", "phone": "+91 9876543210"},
    {"name": "Riya Gupta", "phone": "+91 9123456780"},
    {"name": "Rahul Verma", "phone": "+91 9988776655"},
    {"name": "Ananya Singh", "phone": "+91 9012345678"},
  ];

  List<Map<String, String>> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = _dummyContacts;

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();

      setState(() {
        _filteredContacts = _dummyContacts.where((contact) {
          return contact["name"]!.toLowerCase().contains(query) ||
              contact["phone"]!.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search contacts",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildContactTile(Map<String, String> contact) {
    return ListTile(
      leading: CircleAvatar(child: Text(contact["name"]![0])),
      title: Text(contact["name"]!),
      subtitle: Text(contact["phone"]!),
      trailing: const Icon(Icons.chat_outlined),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Chat with ${contact["name"]}")));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contacts"), centerTitle: true),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredContacts.isEmpty
                ? const Center(child: Text("No Contacts Found"))
                : ListView.separated(
                    itemCount: _filteredContacts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _buildContactTile(_filteredContacts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

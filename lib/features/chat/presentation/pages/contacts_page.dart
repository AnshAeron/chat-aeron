import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/auth/providers/user_provider.dart';
import 'package:chat_aeron/features/chat/data/datasources/firestore_chat_datasource.dart';
import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_aeron/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<UserEntity> _allUsers = [];
  List<UserEntity> _filteredUsers = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    // NOTE: In real app you should create getAllUsers method
    // For now we fetch current user only + placeholder logic

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final user = await ref.read(userProvider(currentUser.uid).future);

      if (user != null) {
        _allUsers = [user];
        _filteredUsers = _allUsers;
      }
    }

    setState(() {
      _loading = false;
    });
  }

  void _search(String value) {
    setState(() {
      _filteredUsers = _allUsers
          .where(
            (u) =>
                (u.displayName ?? "").toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                u.phoneNumber.contains(value),
          )
          .toList();
    });
  }

  Future<void> _startChat(UserEntity user) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final chatId = FirestoreChatDataSource().getChatId(currentUserId, user.uid);

    final chat = ChatEntity(
      chatId: chatId,
      participants: [currentUserId, user.uid],
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage(chat: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Contact")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: const InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user.displayName ?? "No Name"),
                    subtitle: Text(user.phoneNumber),
                    onTap: () => _startChat(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_aeron/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_aeron/features/chat/providers/chat_providers.dart';
import 'package:chat_aeron/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
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

  Future<void> _startChat(String otherUserId, String displayName) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatId = await ref
          .read(chatRepositoryProvider)
          .getOrCreateChat(currentUserId, otherUserId);

      if (!mounted) return;
      Navigator.of(context).pop(); // close loading dialog

      final chat = ChatEntity(
        chatId: chatId,
        participants: [currentUserId, otherUserId],
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatPage(chat: chat)),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to start chat: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Contacts"), centerTitle: true),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: contactsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
              data: (users) {
                final filtered = _query.isEmpty
                    ? users
                    : users.where((u) {
                        final name = (u.displayName ?? '').toLowerCase();
                        final phone = u.phoneNumber.toLowerCase();
                        final q = _query.toLowerCase();
                        return name.contains(q) || phone.contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No Contacts Found"));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final name = user.displayName?.isNotEmpty == true
                        ? user.displayName!
                        : user.phoneNumber;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?")
                            : null,
                      ),
                      title: Text(name),
                      subtitle: Text(user.phoneNumber),
                      trailing: const Icon(Icons.chat_outlined),
                      onTap: () => _startChat(user.uid, name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:chat_aeron/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_aeron/features/chat/presentation/providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_aeron/features/contacts/presentation/pages/contacts_pages.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final chatsAsync = ref.watch(chatsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatAeron"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactsPage()),
          );
        },
        child: const Icon(Icons.chat),
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Text("No chats yet 💬", style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),

            itemBuilder: (context, index) {
              final chat = chats[index];

              final otherUserId = chat.participants.firstWhere(
                (e) => e != userId,
                orElse: () => "Unknown",
              );

              final unread = chat.unreadCount[userId] ?? 0;

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),

                title: Text(
                  otherUserId,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                subtitle: Text(
                  chat.lastMessage ?? "No messages yet",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat.lastMessageTime != null
                          ? "${chat.lastMessageTime!.hour.toString().padLeft(2, '0')}:${chat.lastMessageTime!.minute.toString().padLeft(2, '0')}"
                          : "",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 6),

                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$unread",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatPage(chat: chat)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

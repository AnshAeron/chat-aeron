import 'package:chat_aeron/features/auth/providers/auth_providers.dart';
import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_aeron/features/chat/presentation/providers/chat_provider.dart';
import 'package:chat_aeron/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(chatsProvider);
  }

  void _openContacts() {
    context.push(AppRoutes.contacts);
  }

  void _openProfile() {
    context.push(AppRoutes.profile);
  }

  void _signOut() async {
    await ref.read(signOutUseCaseProvider).call();

    if (!mounted) return;

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final chatsAsync = ref.watch(chatsProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChatAeron',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,

        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),

          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _openProfile();
                  break;

                case 'logout':
                  _signOut();
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openContacts,
        child: const Icon(Icons.chat),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,

        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: chatsAsync.when(
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },

                error: (error, stack) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },

                data: (chats) {
                  List<ChatEntity> filteredChats = chats;

                  if (_searchQuery.isNotEmpty) {
                    filteredChats = chats.where((chat) {
                      final message = (chat.lastMessage ?? '').toLowerCase();

                      return message.contains(_searchQuery) ||
                          chat.participants
                              .join(' ')
                              .toLowerCase()
                              .contains(_searchQuery);
                    }).toList();
                  }

                  if (filteredChats.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),

                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 20),

                        Center(
                          child: Text(
                            'No Chats Yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 8),

                        Center(
                          child: Text(
                            'Tap the chat button to start a conversation.',
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),

                    itemCount: filteredChats.length,

                    separatorBuilder: (_, __) => const Divider(height: 1),

                    itemBuilder: (context, index) {
                      final chat = filteredChats[index];

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          child: Text(
                            chat.participants.isNotEmpty
                                ? chat.participants.last
                                      .substring(0, 1)
                                      .toUpperCase()
                                : '?',
                          ),
                        ),

                        title: Text(
                          chat.participants.isNotEmpty
                              ? chat.participants.last
                              : 'Unknown User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        subtitle: Text(
                          chat.lastMessage ?? 'No messages',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(chat.lastMessageTime),
                              style: const TextStyle(fontSize: 12),
                            ),

                            const SizedBox(height: 6),

                            if ((chat.unreadCount[currentUser.uid] ?? 0) > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${chat.unreadCount[currentUser.uid]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        onTap: () {
                          context.push(AppRoutes.chat, extra: chat);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break;

            case 1:
              context.push(AppRoutes.contacts);
              break;

            case 2:
              context.push(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();

    if (now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day) {
      final hour = dateTime.hour.toString().padLeft(2, '0');

      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$hour:$minute';
    }

    if (now.difference(dateTime).inDays == 1) {
      return 'Yesterday';
    }

    return '${dateTime.day}/${dateTime.month}';
  }

  Widget buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 90, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No conversations yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Start chatting with your contacts.'),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(error.toString(), textAlign: TextAlign.center),
      ),
    );
  }

  Widget buildUnreadBadge(int count) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildOnlineIndicator(bool online) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: online ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  Future<void> openChat(ChatEntity chat) async {
    if (!mounted) return;

    context.push(AppRoutes.chat, extra: chat);
  }

  Future<void> refreshChats() async {
    ref.invalidate(chatsProvider);
  }
}

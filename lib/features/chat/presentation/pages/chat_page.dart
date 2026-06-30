import 'package:chat_aeron/features/auth/providers/user_provider.dart';
import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_aeron/features/chat/presentation/controllers/chat_controller.dart';
import 'package:chat_aeron/features/chat/presentation/providers/chat_provider.dart';
import 'package:chat_aeron/features/chat/widgets/chat_app_bar.dart';
import 'package:chat_aeron/features/chat/widgets/message_input.dart';
import 'package:chat_aeron/features/chat/widgets/message_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerStatefulWidget {
  final ChatEntity chat;

  const ChatPage({super.key, required this.chat});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  late final String currentUserId;
  late final String otherUserId;

  @override
  void initState() {
    super.initState();

    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    otherUserId = widget.chat.getOtherUserId(currentUserId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(chatRepositoryProvider)
          .markMessagesAsSeen(widget.chat.chatId, currentUserId);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider(otherUserId));
    final messagesAsync = ref.watch(messagesProvider(widget.chat.chatId));

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),

      data: (user) {
        return Scaffold(
          appBar: ChatAppBar(
            name: user?.displayName ?? 'Unknown User',
            photoUrl: user?.photoUrl,
            isOnline: user?.isOnline ?? false,
            lastSeen: user?.lastSeen != null
                ? _formatLastSeen(user!.lastSeen!)
                : 'Offline',
          ),

          body: Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (e, _) => Center(child: Text(e.toString())),

                  data: (messages) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return MessageList(
                      messages: messages,
                      currentUserId: currentUserId,
                      scrollController: _scrollController,
                    );
                  },
                ),
              ),

              MessageInput(
                onSend: (text) async {
                  if (text.trim().isEmpty) return;

                  await ref
                      .read(chatControllerProvider.notifier)
                      .sendTextMessage(
                        chatId: widget.chat.chatId,
                        senderId: currentUserId,
                        text: text,
                      );

                  _scrollToBottom();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatLastSeen(DateTime time) {
    final now = DateTime.now();

    if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      return "Today ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }

    if (now.difference(time).inDays == 1) {
      return "Yesterday";
    }

    return "${time.day}/${time.month}/${time.year}";
  }
}

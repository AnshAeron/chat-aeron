import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageInput extends StatefulWidget {
  final Future<void> Function(String text) onSend;

  /// NEW: media callback
  final Future<void> Function(File file)? onMediaSelected;

  const MessageInput({super.key, required this.onSend, this.onMediaSelected});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  bool _canSend = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final value = _controller.text.trim().isNotEmpty;

      if (value != _canSend) {
        setState(() {
          _canSend = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      await widget.onSend(text);

      _controller.clear();

      setState(() {
        _canSend = false;
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);

    if (widget.onMediaSelected != null) {
      await widget.onMediaSelected!(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(icon: const Icon(Icons.image), onPressed: _pickImage),

            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),

            const SizedBox(width: 8),

            FloatingActionButton.small(
              heroTag: null,
              onPressed: _canSend && !_sending ? _send : null,
              child: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

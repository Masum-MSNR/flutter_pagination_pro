import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../theme/app_theme.dart';

/// Mock message model for the bidirectional demo
class _ChatMessage {
  const _ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
  });

  final int id;
  final String text;
  final bool isMe;
  final String time;
}

/// Demonstrates bidirectional (two-way) pagination.
///
/// Simulates a chat interface that loads older messages upward
/// and newer messages downward from an anchor page.
class BidirectionalScreen extends StatefulWidget {
  const BidirectionalScreen({super.key});

  @override
  State<BidirectionalScreen> createState() => _BidirectionalScreenState();
}

class _BidirectionalScreenState extends State<BidirectionalScreen> {
  late final BidirectionalPaginationController<int, _ChatMessage> _controller;
  bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    _controller = BidirectionalPaginationController<int, _ChatMessage>(
      fetchPage: _fetchForward,
      fetchPreviousPage: _fetchBackward,
      initialPageKey: 5,
      config: const PaginationConfig(pageSize: 15),
    );
  }

  Future<List<_ChatMessage>> _fetchForward(int page) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_simulateError && page == 7) {
      throw Exception('Network error loading newer messages');
    }
    if (page > 8) return []; // No more forward pages
    return _generateMessages(page);
  }

  Future<List<_ChatMessage>> _fetchBackward(int page) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_simulateError && page == 3) {
      throw Exception('Network error loading older messages');
    }
    if (page < 1) return []; // No more backward pages
    return _generateMessages(page);
  }

  List<_ChatMessage> _generateMessages(int page) {
    final startId = (page - 1) * 15;
    return List.generate(15, (i) {
      final id = startId + i + 1;
      final hour = (id % 12) + 1;
      final minute = (id * 7) % 60;
      return _ChatMessage(
        id: id,
        text: _sampleTexts[id % _sampleTexts.length],
        isMe: id % 3 != 0,
        time: '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
    });
  }

  static const _sampleTexts = [
    'Hey! How are you doing?',
    'I\'m good, thanks! Working on the new pagination feature.',
    'That sounds great! Need any help?',
    'Actually, yes. Can you review the PR?',
    'Sure, I\'ll take a look right after lunch.',
    'Perfect, no rush 👍',
    'The bidirectional scroll is so smooth!',
    'Right? CustomScrollView center key is the trick.',
    'I also added auto-retry with exponential backoff.',
    'Nice! That\'s really important for unreliable networks.',
    'Did you see the new skeleton loading?',
    'Yes! It looks much better than a plain spinner.',
    'We should add a grid example too.',
    'Already done! Check the Grid View screen.',
    'This is looking really professional.',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bidirectional Scroll'),
        actions: [
          IconButton(
            icon: Icon(
              _simulateError ? Icons.error : Icons.error_outline,
              color: _simulateError ? Colors.red : colorScheme.primary,
            ),
            tooltip: _simulateError ? 'Disable errors' : 'Simulate errors',
            onPressed: () {
              setState(() => _simulateError = !_simulateError);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            tooltip: 'Refresh',
            onPressed: _controller.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.secondaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Scroll up to load older messages, scroll down to load newer ones. Uses CustomScrollView center key for stable scrolling.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bidirectional list
          Expanded(
            child: BidirectionalPaginationListView<int, _ChatMessage>.withController(
              controller: _controller,
              itemBuilder: (context, message, index) =>
                  _MessageBubble(message: message),
              backwardLoadingBuilder: (context) => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading older messages...',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              forwardLoadingBuilder: (context) => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading newer messages...',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat-style message bubble widget
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMe = message.isMe;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64 : 8,
        right: isMe ? 8 : 64,
        top: 4,
        bottom: 4,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${message.time} • #${message.id}',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

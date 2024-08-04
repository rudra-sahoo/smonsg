import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shared_preferences/shared_preferences.dart';

class MessageList extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final bool isSending;

  const MessageList(
      {super.key, required this.messages, required this.isSending});

  @override
  // ignore: library_private_types_in_public_api
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToLatestButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadScrollPosition();
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSending && !oldWidget.isSending) {
      _scrollToBottom();
    }
  }

  void _scrollListener() {
    if (_scrollController.offset <
        _scrollController.position.maxScrollExtent - 100) {
      if (!_showScrollToLatestButton) {
        setState(() {
          _showScrollToLatestButton = true;
        });
      }
    } else {
      if (_showScrollToLatestButton) {
        setState(() {
          _showScrollToLatestButton = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(
              milliseconds: 500), // Adjust duration for smoother animation
          curve: Curves.easeInOut, // Adjust curve for smoother effect
        );
      }
    });
  }

  Future<void> _loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final position = prefs.getDouble('scroll_position');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (position != null && _scrollController.hasClients) {
        _scrollController.jumpTo(position);
      } else {
        _scrollToBottom();
      }
    });
  }

  Future<void> _saveScrollPosition() async {
    if (_scrollController.hasClients) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble('scroll_position', _scrollController.offset);
    }
  }

  @override
  void dispose() {
    _saveScrollPosition();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime).inMinutes;

    if (difference < 60) {
      return timeago.format(dateTime, locale: 'en');
    } else if (difference < 1440) {
      // 60 minutes * 24 hours
      return DateFormat('h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  String _formatDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 365) {
      return DateFormat('MMMM dd').format(dateTime);
    } else {
      return DateFormat('MM/dd/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: widget.messages.length,
          itemBuilder: (context, index) {
            final message = widget.messages[index];
            final isSentByMe = message['isSentByMe'];
            final messageDate = DateTime.parse(message['timestamp']);
            final messageStatus = message['status'] ??
                'sent'; // Default to 'sent' if not provided

            bool showDateHeader = false;
            if (index == 0 ||
                DateTime.parse(widget.messages[index - 1]['timestamp']).day !=
                    messageDate.day) {
              showDateHeader = true;
            }

            return Column(
              children: [
                if (showDateHeader)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              Divider(thickness: 1.0, color: Colors.grey[400]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            _formatDateHeader(messageDate),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Expanded(
                          child:
                              Divider(thickness: 1.0, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment:
                      isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isSentByMe ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: isSentByMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                message['message'],
                                style: TextStyle(
                                    color: isSentByMe
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              _formatTimestamp(message['timestamp']),
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: isSentByMe
                                      ? Colors.white70
                                      : Colors.black54),
                            ),
                            if (messageStatus == 'sending')
                              SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      isSentByMe ? Colors.white : Colors.black),
                                ),
                              ),
                            if (messageStatus == 'sent' ||
                                messageStatus == 'delivered')
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16.0,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (_showScrollToLatestButton)
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward),
            ),
          ),
      ],
    );
  }
}

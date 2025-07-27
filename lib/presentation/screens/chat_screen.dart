import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daytask/constants.dart'; // Assuming your constants.dart has colors like scaffoldBackgroundColor, textColor, etc.

@RoutePage()
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'AlienFriend',
      'message': 'Greetings, Earthling! How are your day-tasks progressing?',
      'isMe': false,
      'time': '10:00 AM',
    },
    {
      'sender': 'Me',
      'message': 'Pretty good! Just wrapped up some important notes. ✨',
      'isMe': true,
      'time': '10:01 AM',
    },
    {
      'sender': 'AlienFriend',
      'message':
          'Excellent! Remember, optimal task management ensures universal harmony.',
      'isMe': false,
      'time': '10:05 AM',
    },
    {
      'sender': 'Me',
      'message': 'Haha, definitely! What\'s on your quadrant today?',
      'isMe': true,
      'time': '10:06 AM',
    },
    {
      'sender': 'AlienFriend',
      'message':
          'Analyzing temporal distortions in Sector Gamma. Routine cosmic maintenance.',
      'isMe': false,
      'time': '10:15 AM',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'Me',
          'message': _messageController.text.trim(),
          'isMe': true,
          'time': TimeOfDay.now().format(context),
        });
      });
      _messageController.clear();
      // Simulate a reply after a short delay (optional)
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            'sender': 'AlienFriend',
            'message': 'Understood. Processing your transmission.',
            'isMe': false,
            'time': TimeOfDay.now().format(context),
          });
        });
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor, // From your constants
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => context.router.pop(), // Goes back to previous route
        ),
        title: Text(
          'Galactic Comms',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () {
              // Handle chat options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              reverse: true, // Show latest messages at the bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message =
                    _messages[_messages.length -
                        1 -
                        index]; // Display in reverse order
                return MessageBubble(
                  sender: message['sender'],
                  message: message['message'],
                  isMe: message['isMe'],
                  time: message['time'],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: searchFieldFillColor, // From your constants
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Transmitting message...',
                hintStyle: GoogleFonts.inter(color: Colors.white54),
                filled: true,
                fillColor: const Color(
                  0xff2C2C2E,
                ), // A slightly lighter dark for the input field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(), // Send on enter
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffFED36A), // Your accent color
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xffFED36A).withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String message;
  final bool isMe;
  final String time;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            isMe ? 'You' : sender, // Show 'You' for current user
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15.0),
              topRight: const Radius.circular(15.0),
              bottomLeft: isMe
                  ? const Radius.circular(15.0)
                  : const Radius.circular(5.0),
              bottomRight: isMe
                  ? const Radius.circular(5.0)
                  : const Radius.circular(15.0),
            ),
            color: isMe
                ? const Color(0xffFED36A)
                : Colors.white10, // Your accent for 'me', white10 for 'them'
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      color: isMe ? Colors.black : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isMe ? Colors.black54 : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

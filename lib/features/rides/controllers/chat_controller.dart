import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';

class ChatController extends GetxController {
  static ChatController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isTyping = false.obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  String? currentChatRoomId;
  String? otherUserId;
  Map<String, dynamic>? rideInfo;

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(_onMessageChanged);
  }

  @override
  void onClose() {
    messageController.removeListener(_onMessageChanged);
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onMessageChanged() {
    // Handle typing indicator if needed
  }

  void initializeChatWithRide(
    String otherUserId,
    Map<String, dynamic> rideInfo,
  ) {
    this.otherUserId = otherUserId;
    this.rideInfo = rideInfo;

    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    // Create or get chat room
    _createOrGetChatRoom(currentUserId, otherUserId, rideInfo);
  }

  Future<void> _createOrGetChatRoom(
    String user1Id,
    String user2Id,
    Map<String, dynamic> rideInfo,
  ) async {
    try {
      isLoading.value = true;

      // Check if chat room already exists
      final existingRoomQuery =
          await _db
              .collection('chatRooms')
              .where('user1Id', whereIn: [user1Id, user2Id])
              .where('user2Id', whereIn: [user1Id, user2Id])
              .limit(1)
              .get();

      if (existingRoomQuery.docs.isNotEmpty) {
        // Use existing chat room
        final roomDoc = existingRoomQuery.docs.first;
        currentChatRoomId = roomDoc.id;

        // Update ride info if needed
        if (rideInfo.isNotEmpty) {
          await roomDoc.reference.update({
            'rideInfo': rideInfo,
            'lastMessageTime': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Create new chat room
        final roomRef = await _db.collection('chatRooms').add({
          'user1Id': user1Id,
          'user2Id': user2Id,
          'rideInfo': rideInfo,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageSenderId': '',
          'isActive': true,
        });

        currentChatRoomId = roomRef.id;
      }

      // Load messages
      _loadMessages();
    } catch (e) {
      print('Error creating/getting chat room: $e');
      Get.snackbar('Error', 'Failed to initialize chat');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMessages() {
    if (currentChatRoomId == null || currentChatRoomId!.isEmpty) {
      print('Error: currentChatRoomId is null or empty in _loadMessages');
      Get.snackbar('Error', 'Chat room not found.');
      return;
    }
    _db
        .collection('chatRooms')
        .doc(currentChatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
          final newMessages =
              snapshot.docs
                  .map((doc) => ChatMessage.fromFirestore(doc))
                  .toList();

          messages.value = newMessages.reversed.toList();

          // Scroll to bottom after messages load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty ||
        currentChatRoomId == null ||
        currentChatRoomId!.isEmpty) {
      print('Error: Cannot send message, chatRoomId is null or empty');
      Get.snackbar('Error', 'Chat room not found.');
      return;
    }

    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final messageData = {
        'senderId': currentUserId,
        'message': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      // Add message to chat room
      await _db
          .collection('chatRooms')
          .doc(currentChatRoomId)
          .collection('messages')
          .add(messageData);

      // Update chat room with last message info
      await _db.collection('chatRooms').doc(currentChatRoomId).update({
        'lastMessage': text.trim(),
        'lastMessageSenderId': currentUserId,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // Clear input
      messageController.clear();

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    if (currentChatRoomId == null ||
        currentChatRoomId!.isEmpty ||
        messageId.isEmpty) {
      print(
        'Error: Cannot mark message as read, chatRoomId or messageId is null or empty',
      );
      return;
    }
    try {
      await _db
          .collection('chatRooms')
          .doc(currentChatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  Future<void> deleteMessageForMe(String messageId) async {
    if (currentChatRoomId == null ||
        currentChatRoomId!.isEmpty ||
        messageId.isEmpty) {
      print(
        'Error: Cannot delete message, chatRoomId or messageId is null or empty',
      );
      Get.snackbar('Error', 'Chat room or message not found.');
      return;
    }
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _db
          .collection('chatRooms')
          .doc(currentChatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
            'deletedFor': FieldValue.arrayUnion([currentUserId]),
          });
    } catch (e) {
      print('Error deleting message: $e');
      Get.snackbar('Error', 'Failed to delete message');
    }
  }

  bool isMessageFromMe(String senderId) {
    return senderId == _auth.currentUser?.uid;
  }

  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }

  String getCurrentUserName() {
    return _auth.currentUser?.displayName ?? 'You';
  }
}

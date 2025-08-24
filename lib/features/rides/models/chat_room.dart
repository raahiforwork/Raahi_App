import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? rideId;
  final DateTime createdAt;
  final DateTime lastMessageTime;
  final String lastMessage;
  final String lastMessageSenderId;
  final bool isActive;
  final Map<String, dynamic>? rideInfo; // Store ride information

  ChatRoom({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.rideId,
    required this.createdAt,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.lastMessageSenderId,
    this.isActive = true,
    this.rideInfo,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      user1Id: data['user1Id'] ?? '',
      user2Id: data['user2Id'] ?? '',
      rideId: data['rideId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      isActive: data['isActive'] ?? true,
      rideInfo: data['rideInfo'],
    );
  }

  ChatRoom copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    String? rideId,
    DateTime? createdAt,
    DateTime? lastMessageTime,
    String? lastMessage,
    String? lastMessageSenderId,
    bool? isActive,
    Map<String, dynamic>? rideInfo,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      rideId: rideId ?? this.rideId,
      createdAt: createdAt ?? this.createdAt,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      isActive: isActive ?? this.isActive,
      rideInfo: rideInfo ?? this.rideInfo,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'rideId': rideId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'isActive': isActive,
      'rideInfo': rideInfo,
    };
  }

  // Get the other user's ID
  String getOtherUserId(String currentUserId) {
    if ((user1Id.isEmpty && user2Id.isEmpty) || currentUserId.isEmpty) {
      print('Error: getOtherUserId found empty user IDs');
      return 'unknown';
    }
    return user1Id == currentUserId ? user2Id : user1Id;
  }

  // Generate a unique chat room ID for two users
  static String generateChatRoomId(
    String user1Id,
    String user2Id,
    String? rideId,
  ) {
    // Sort the user IDs to ensure consistent chat room ID and append rideId for per-ride uniqueness
    final sortedIds = [user1Id, user2Id]..sort();
    final baseId = '${sortedIds[0]}_${sortedIds[1]}';
    return rideId != null && rideId.isNotEmpty ? '${baseId}_$rideId' : baseId;
  }
}

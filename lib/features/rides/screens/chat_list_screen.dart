import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../models/chat_room.dart';
import '../screens/chat_screen.dart';
import 'dart:async';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final Set<String> _selectedRoomIds = <String>{};
  bool get _selectionMode => _selectedRoomIds.isNotEmpty;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;
  bool _showSearch = false;
  void _toggleSelection(String roomId) {
    setState(() {
      if (_selectedRoomIds.contains(roomId)) {
        _selectedRoomIds.remove(roomId);
      } else {
        _selectedRoomIds.add(roomId);
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesRoom(ChatRoom room) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    final lastMsg = room.lastMessage.toLowerCase();
    final pickup =
        (room.rideInfo?['pickup']?['name'] ?? '').toString().toLowerCase();
    final dest =
        (room.rideInfo?['destination']?['name'] ?? '').toString().toLowerCase();
    return lastMsg.contains(q) || pickup.contains(q) || dest.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: RAppBar(
        title: Text(
          _selectionMode ? '${_selectedRoomIds.length} selected' : 'Messages',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        showBackArrow: true,
        actions: [
          if (_selectionMode)
            IconButton(
              tooltip: 'Delete selected',
              icon: const Icon(Iconsax.trash, color: Colors.redAccent),
              onPressed: () async {
                if (_selectedRoomIds.isEmpty) return;
                final confirm = await Get.dialog<bool>(
                  Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Iconsax.trash, color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Delete ${_selectedRoomIds.length} chat(s)?',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This will permanently delete the selected conversations for you.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(result: false),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => Get.back(result: true),
                                  child: const Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (confirm == true) {
                  try {
                    // await chatController.deleteChatRoomsHardByIds(
                    //   _selectedRoomIds.toList(),
                    // );
                    setState(() {
                      _selectedRoomIds.clear();
                    });
                    Get.snackbar('Deleted', 'Selected chats deleted');
                  } catch (_) {
                    Get.snackbar('Error', 'Failed to delete chats');
                  }
                }
              },
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  _showSearch = true;
                });
              },
              icon: const Icon(Iconsax.search_normal),
            ),
          if (_showSearch && !_selectionMode)
            IconButton(
              tooltip: 'Close search',
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _showSearch = false;
                });
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body:
          _showSearch
              ? _buildUserSearchView()
              : Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('chatRooms')
                              .where('isActive', isEqualTo: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Something went wrong',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: RColors.primary,
                            ),
                          );
                        }

                        final allChatRooms = snapshot.data?.docs ?? [];
                        final chatRooms =
                            allChatRooms.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return data['user1Id'] == currentUserId ||
                                  data['user2Id'] == currentUserId;
                            }).toList();

                        if (chatRooms.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: RColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Iconsax.message,
                                    size: 48,
                                    color: RColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodyLarge?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start a conversation by booking a ride',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: chatRooms.length,
                          itemBuilder: (context, index) {
                            final chatRoom = ChatRoom.fromFirestore(
                              chatRooms[index],
                            );
                            final otherUserId = chatRoom.getOtherUserId(
                              currentUserId!,
                            );

                            return FutureBuilder<DocumentSnapshot>(
                              future:
                                  (otherUserId == null || otherUserId.isEmpty)
                                      ? null
                                      : FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(otherUserId)
                                          .get(),
                              builder: (context, userSnapshot) {
                                if (otherUserId == null ||
                                    otherUserId.isEmpty) {
                                  print('Error: otherUserId is null or empty');
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    Get.snackbar(
                                      'Error',
                                      'User not found. Cannot open chat.',
                                    );
                                  });
                                  return const SizedBox.shrink();
                                }
                                if (!userSnapshot.hasData) {
                                  return _buildChatRoomSkeleton();
                                }

                                final userData =
                                    userSnapshot.data!.data()
                                        as Map<String, dynamic>?;
                                final firstName = userData?['firstName'] ?? '';
                                final lastName = userData?['lastName'] ?? '';
                                final profileImageUrl =
                                    userData?['profileImageUrl'] ?? '';
                                final isOnline = userData?['isOnline'] ?? false;

                                final basicMatch = _matchesRoom(chatRoom);
                                // If searching and not matched yet, we'll still evaluate name after user data
                                if (_searchQuery.isNotEmpty && !basicMatch) {
                                  final fullName =
                                      ('$firstName $lastName')
                                          .trim()
                                          .toLowerCase();
                                  final matchesUser = fullName.contains(
                                    _searchQuery.toLowerCase(),
                                  );
                                  if (!matchesUser) {
                                    return const SizedBox.shrink();
                                  }
                                }
                                return _buildChatRoomTile(
                                  chatRoom,
                                  firstName,
                                  lastName,
                                  profileImageUrl,
                                  isOnline,
                                  otherUserId,
                                  selected: _selectedRoomIds.contains(
                                    chatRoom.id,
                                  ),
                                  showSelector:
                                      _selectionMode ||
                                      _selectedRoomIds.contains(chatRoom.id),
                                  onLongPress:
                                      () => _toggleSelection(chatRoom.id),
                                  onTap: () {
                                    if (_selectionMode) {
                                      _toggleSelection(chatRoom.id);
                                    } else {
                                      if (otherUserId == null ||
                                          otherUserId.isEmpty) {
                                        Get.snackbar(
                                          'Error',
                                          'User not found. Cannot open chat.',
                                        );
                                      } else {
                                        Get.to(
                                          () => ChatScreen(
                                            otherUserId: otherUserId,
                                            rideInfo: chatRoom.rideInfo,
                                            otherUserName:
                                                ('$firstName $lastName').trim(),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
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

  Widget _buildUserSearchView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Iconsax.search_normal, size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search users by name…',
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 250),
                        () {
                          setState(() {
                            _searchQuery = text.trim();
                          });
                        },
                      );
                    },
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .limit(100)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              final docs = snapshot.data!.docs;
              final term = _searchQuery.toLowerCase();
              final filtered =
                  docs.where((d) {
                    if (term.isEmpty) return false;
                    final data = d.data() as Map<String, dynamic>;
                    final first =
                        (data['firstName'] ?? '').toString().toLowerCase();
                    final last =
                        (data['lastName'] ?? '').toString().toLowerCase();
                    final full = ('$first $last').trim();
                    return first.contains(term) ||
                        last.contains(term) ||
                        full.contains(term);
                  }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    term.isEmpty ? 'Type to search users' : 'No users found',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: filtered.length,
                separatorBuilder:
                    (_, __) => Divider(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                itemBuilder: (context, index) {
                  final doc = filtered[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final first = (data['firstName'] ?? '').toString();
                  final last = (data['lastName'] ?? '').toString();
                  final profileImageUrl =
                      (data['profileImageUrl'] ?? '').toString();
                  final displayName =
                      ('$first $last').trim().isEmpty
                          ? 'User'
                          : ('$first $last').trim();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: RColors.primary.withOpacity(0.1),
                      backgroundImage:
                          profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                      child:
                          profileImageUrl.isEmpty
                              ? Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: RColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              : null,
                    ),
                    title: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      if (doc.id == null || doc.id!.isEmpty) {
                        print('Error: doc.id is null or empty in user search');
                        Get.snackbar(
                          'Error',
                          'User not found. Cannot open chat.',
                        );
                        return;
                      }
                      setState(() {
                        _showSearch = false;
                      });
                      Get.to(
                        () => ChatScreen(
                          otherUserId: doc.id!,
                          rideInfo: null,
                          otherUserName: displayName,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatRoomSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: Colors.grey[200]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomTile(
    ChatRoom chatRoom,
    String firstName,
    String lastName,
    String profileImageUrl,
    bool isOnline,
    String otherUserId, {
    required bool selected,
    required bool showSelector,
    required VoidCallback onLongPress,
    required VoidCallback onTap,
  }) {
    final isMe =
        chatRoom.lastMessageSenderId == FirebaseAuth.instance.currentUser?.uid;
    final fullName = '$firstName $lastName'.trim();
    final displayName = fullName.isNotEmpty ? fullName : 'User';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Selection checkbox (hidden until selection mode or selected)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                  child:
                      showSelector
                          ? Container(
                            key: const ValueKey('selector'),
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color:
                                  selected
                                      ? RColors.primary
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    selected
                                        ? RColors.primary
                                        : Theme.of(context).dividerColor,
                              ),
                            ),
                            child:
                                selected
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                    : null,
                          )
                          : const SizedBox.shrink(),
                ),
                // User Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: RColors.primary.withOpacity(0.1),
                      backgroundImage:
                          profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                      child:
                          profileImageUrl.isEmpty
                              ? Text(
                                firstName.isNotEmpty
                                    ? firstName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: RColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                              : null,
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(chatRoom.lastMessageTime),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isMe
                                  ? 'You: ${chatRoom.lastMessage}'
                                  : chatRoom.lastMessage,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Unread message indicator
                          if (!isMe) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: RColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd').format(time);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

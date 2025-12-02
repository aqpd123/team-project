class FriendData {
  const FriendData({
    required this.friendshipId,
    required this.userId,
    required this.name,
    required this.elementLabel,
    required this.statusLabel,
    this.email,
  });

  final int friendshipId;
  final int userId;
  final String name;
  final String elementLabel;
  final String statusLabel;
  final String? email;
}

enum FriendRelationStatus { none, friend, incomingPending, outgoingPending }

class FriendRequestModel {
  const FriendRequestModel({
    required this.friendshipId,
    required this.userId,
    required this.name,
    required this.elementLabel,
    required this.isInbox,
    this.email,
    this.createdAt,
  });

  final int friendshipId;
  final int userId;
  final String name;
  final String elementLabel;
  final bool isInbox;
  final String? email;
  final DateTime? createdAt;
}

class FriendSearchResult {
  const FriendSearchResult({
    required this.userId,
    required this.name,
    required this.email,
    required this.elementLabel,
    required this.status,
  });

  final int userId;
  final String name;
  final String email;
  final String elementLabel;
  final FriendRelationStatus status;
}



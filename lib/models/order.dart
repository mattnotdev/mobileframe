// a buy/sell order class
class Order {
  final String id;
  final String type; // wts / wtb
  final int platinum;
  final int quantity;
  final int perTrade;
  final int? rank;
  final int? amberStars;
  final int? cyanStars;
  final bool visible;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String itemId;
  final OrderUser user;

  Order({
    required this.id,
    required this.type,
    required this.platinum,
    required this.quantity,
    required this.perTrade,
    this.rank,
    this.amberStars,
    this.cyanStars,
    required this.visible,
    required this.createdAt,
    required this.updatedAt,
    required this.itemId,
    required this.user,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    type: json['type'] as String,
    platinum: json['platinum'] as int,
    quantity: json['quantity'] as int,
    perTrade: json['perTrade'] as int? ?? 1,
    rank: json['rank'] as int?,
    amberStars: json['amberStars'] as int?,
    cyanStars: json['cyanStars'] as int?,
    visible: json['visible'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    itemId: json['itemId'] as String,
    user: OrderUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}

// the user which creates the order
class OrderUser {
  final String id;
  final String ingameName;
  final int reputation;
  final String platform;
  final String status; // player offline / online (on website) / ingame
  final DateTime? lastSeen;
  final String? avatar;

  OrderUser({
    required this.id,
    required this.ingameName,
    required this.reputation,
    required this.platform,
    required this.status,
    this.lastSeen,
    this.avatar,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) => OrderUser(
    id: json['id'] as String,
    ingameName: json['ingameName'] as String,
    reputation: json['reputation'] as int? ?? 0,
    platform: json['platform'] as String? ?? 'pc',
    status: json['status'] as String? ?? 'offline',
    lastSeen: json['lastSeen'] != null
        ? DateTime.parse(json['lastSeen'] as String)
        : null,
    avatar: json['avatar'] as String?,
  );
}
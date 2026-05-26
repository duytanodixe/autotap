class Profile {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isActive;

  const Profile({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    final created = map['createdAt'];
    DateTime createdAt;
    if (created is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(created);
    } else if (created is String) {
      createdAt = DateTime.tryParse(created) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }
    return Profile(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Profile',
      createdAt: createdAt,
      isActive: map['isActive'] as bool? ?? false,
    );
  }
}



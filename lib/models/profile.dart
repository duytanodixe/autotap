class Profile {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isActive;

  Profile({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.isActive,
  });

  Profile copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false,
    );
  }
}

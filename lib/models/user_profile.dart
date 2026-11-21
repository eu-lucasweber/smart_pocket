class UserProfile {
  final int id;
  final String name;
  final String email;
  final String currency;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
  });

  factory UserProfile.fromMap(Map<String, Object?> map) {
    return UserProfile(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      currency: map['currency'] as String,
    );
  }

  /// Sem o `id`: ele é gerado pelo AUTOINCREMENT no insert.
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'email': email,
      'currency': currency,
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? currency,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          currency == other.currency;

  @override
  int get hashCode =>
      Object.hash(id, name, email, currency);
}
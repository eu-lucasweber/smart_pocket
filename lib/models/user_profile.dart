
class UserProfile {
  final int id;
  final String name;
  final String email;
  final String currency;
  final double monthlySpendingLimit;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
    required this.monthlySpendingLimit,
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? currency,
    double? monthlySpendingLimit,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      monthlySpendingLimit:
          monthlySpendingLimit ?? this.monthlySpendingLimit,
    );
  }
}

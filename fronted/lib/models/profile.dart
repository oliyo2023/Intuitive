class Profile {
  final String id;
  final String subscriptionLevel;
  final int credits;

  Profile({
    required this.id,
    required this.subscriptionLevel,
    required this.credits,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      subscriptionLevel: map['subscription_level'] ?? 'free',
      credits: map['credits'] ?? 0,
    );
  }
}
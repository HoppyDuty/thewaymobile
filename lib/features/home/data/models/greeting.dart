class Greeting {
  const Greeting({required this.greeting, required this.name, required this.fullName, this.avatarUrl});

  final String greeting;
  final String name;
  final String fullName;
  final String? avatarUrl;

  factory Greeting.fromJson(Map<String, dynamic> json) {
    return Greeting(
      greeting: json['greeting'] as String,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class Therapist {
  final String id;
  final String name;
  final String? email;

  const Therapist({
    required this.id,
    required this.name,
    this.email,
  });

  factory Therapist.fromJson(Map<String, dynamic> json) => Therapist(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String?,
      );
}

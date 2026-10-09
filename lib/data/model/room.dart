class Room {
  final int id;
  final String name;
  final String? department;
  final String status;

  Room({
    required this.id,
    required this.name,
    this.department,
    required this.status,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'],
    name: json['name'],
    department: json['department'],
    status: json['status'],
  );
}

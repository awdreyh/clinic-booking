class Timeslot {
  final int id;
  final int roomId;
  final String date;
  final String startTime;
  final String endTime;
  final int capacity;
  final int usedCount;

  Timeslot({
    required this.id,
    required this.roomId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.usedCount,
  });

  factory Timeslot.fromJson(Map<String, dynamic> json) => Timeslot(
        id: json['id'],
        roomId: json['room_id'],
        date: json['date'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        capacity: json['capacity'],
        usedCount: json['used_count'],
      );
}
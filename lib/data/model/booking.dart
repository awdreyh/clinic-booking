class Booking {
  final int id;
  final String userId;
  final String? therapistId;
  final int roomId;
  final int timeslotId;
  final String status;
  final String recurrenceType;
  final String? recurrenceGroupId;

  Booking({
    required this.id,
    required this.userId,
    this.therapistId,
    required this.roomId,
    required this.timeslotId,
    required this.status,
    this.recurrenceType = 'single',
    this.recurrenceGroupId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as int,
        userId: json['user_id'] as String,
        therapistId: json['therapist_id'] as String?,
        roomId: json['room_id'] as int,
        timeslotId: json['timeslot_id'] as int,
        status: json['status'] as String,
        recurrenceType: json['recurrence_type'] as String? ?? 'single',
        recurrenceGroupId: json['recurrence_group_id'] as String?,
      );
}
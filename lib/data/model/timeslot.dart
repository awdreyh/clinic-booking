class Timeslot {
  const Timeslot({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  final String date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
}

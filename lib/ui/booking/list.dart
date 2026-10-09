import 'package:flutter/material.dart';
import '../../data/model/booking.dart';
import '../../data/realtime/booking_realtime.dart';

class BookingRealtimeScreen extends StatefulWidget {
  const BookingRealtimeScreen({super.key});

  @override
  State<BookingRealtimeScreen> createState() => _BookingRealtimeScreenState();
}

class _BookingRealtimeScreenState extends State<BookingRealtimeScreen> {
  final List<Booking> bookings = [];

  @override
  void initState() {
    super.initState();

    subscribeBookingRealtime().listen((booking) {
      setState(() {
        bookings.add(booking);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('实时预约')),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (_, i) {
          final b = bookings[i];
          return ListTile(
            title: Text('预约ID: ${b.id}'),
            subtitle: Text('用户: ${b.userId}  诊室: ${b.roomId}'),
          );
        },
      ),
    );
  }
}

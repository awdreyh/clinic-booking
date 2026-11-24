import 'package:flutter/material.dart';
import '../../data/model/booking.dart';
import '../../data/realtime/booking_realtime.dart';
import '../../l10n/app_localizations.dart';

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
      setState(() => bookings.add(booking));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('Realtime bookings'))),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (_, index) {
          final booking = bookings[index];
          return ListTile(
            title: Text(l10n.tr('Booking ID: {id}', {'id': booking.id})),
            subtitle: Text(
              '${l10n.tr('Customer')}: ${booking.customerId ?? '-'}  '
              '${l10n.tr('Time')}: ${booking.bookingDate ?? '-'} '
              '${booking.startTime ?? '-'}–${booking.endTime ?? '-'}',
            ),
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../supabase_config.dart';
import '../../data/model/booking.dart';

Stream<Booking> subscribeBookingRealtime() {
  final controller = StreamController<Booking>();

  supabase.channel('booking_changes')
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'booking',
      callback: (payload) {
        final data = payload.newRecord;
        controller.add(Booking.fromJson(data));
      },
    )
    .subscribe();

  return controller.stream;
}

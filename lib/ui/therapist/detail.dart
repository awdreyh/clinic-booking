import 'package:flutter/material.dart';

import '../../data/model/service.dart';
import '../../data/model/timeslot.dart';
import '../../data/model/user.dart';
import '../../data/repository/timeslot.dart';
import '../booking/confirm.dart';

class TherapistDetailPage extends StatefulWidget {
  const TherapistDetailPage({
    super.key,
    required this.therapist,
    required this.services,
  });

  final User therapist;
  final List<Service> services;

  @override
  State<TherapistDetailPage> createState() => _TherapistDetailPageState();
}

class _TherapistDetailPageState extends State<TherapistDetailPage> {
  final _timeslotRepository = TimeslotRepository();
  late DateTime _selectedDate;
  int? _selectedServiceId;
  List<Timeslot> _slots = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
    _loadSlots();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final slots = await _timeslotRepository.fetchTimeslots(
        date: _dateKey(_selectedDate),
        therapistId: widget.therapist.id,
        availableOnly: true,
      );
      if (!mounted) return;
      setState(() {
        _slots = slots;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openBooking(Timeslot slot) async {
    Service? service;
    for (final item in widget.services) {
      if (item.id == _selectedServiceId) service = item;
    }
    final booked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BookingConfirmPage(
          therapist: widget.therapist,
          timeslot: slot,
          service: service,
        ),
      ),
    );
    if (booked == true && mounted) await _loadSlots();
  }

  @override
  Widget build(BuildContext context) {
    final therapist = widget.therapist;
    final colors = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);
    Service? selectedService;
    for (final service in widget.services) {
      if (service.id == _selectedServiceId) selectedService = service;
    }

    return Scaffold(
      appBar: AppBar(title: Text(therapist.name)),
      body: ListView(
        children: [
          SizedBox(
            height: 240,
            width: double.infinity,
            child: therapist.photoUrl == null ||
                    therapist.photoUrl!.isEmpty
                ? Container(
                    color: colors.surfaceContainerHighest,
                    child: const Icon(Icons.person, size: 90),
                  )
                : Image.network(
                    therapist.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: colors.surfaceContainerHighest,
                      child: const Icon(Icons.person, size: 90),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(therapist.name,
                    style: Theme.of(context).textTheme.headlineSmall),
                if (therapist.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(therapist.description!),
                ],
                const SizedBox(height: 16),
                if (therapist.phone.isNotEmpty == true)
                  _ContactLine(icon: Icons.phone_outlined, text: therapist.phone),
                if (therapist.email.isNotEmpty == true)
                  _ContactLine(icon: Icons.email_outlined, text: therapist.email),
                if (therapist.address?.isNotEmpty == true)
                  _ContactLine(
                      icon: Icons.location_on_outlined,
                      text: therapist.address!),
                const SizedBox(height: 24),
                Text('Services', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (widget.services.isEmpty)
                  const Text('No services listed yet.')
                else ...[
                  DropdownButtonFormField<int?>(
                    initialValue: _selectedServiceId,
                    decoration: const InputDecoration(labelText: 'Service'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Choose a service (optional)'),
                      ),
                      for (final service in widget.services)
                        DropdownMenuItem<int?>(
                          value: service.id,
                          child: Text(service.name),
                        ),
                    ],
                    onChanged: (id) => setState(() => _selectedServiceId = id),
                  ),
                  if (selectedService?.description?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(selectedService!.description!),
                    ),
                  const SizedBox(height: 8),
                  for (final service in widget.services)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.medical_services_outlined),
                      title: Text(service.name),
                      subtitle: service.description == null
                          ? null
                          : Text(service.description!),
                    ),
                ],
                const SizedBox(height: 24),
                Text('Availability',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateUtils.dateOnly(DateTime.now()),
                  lastDate: DateUtils.dateOnly(
                    DateTime.now().add(const Duration(days: 365)),
                  ),
                  onDateChanged: (date) {
                    setState(() => _selectedDate = DateUtils.dateOnly(date));
                    _loadSlots();
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.formatMediumDate(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Center(
                    child: Column(
                      children: [
                        const Text('Could not load availability.'),
                        TextButton(onPressed: _loadSlots, child: const Text('Retry')),
                      ],
                    ),
                  )
                else if (_slots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No available times for this day.')),
                  )
                else
                  for (final slot in _slots)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.schedule_outlined),
                        title: Text('${slot.startTime} – ${slot.endTime}'),
                        subtitle: const Text('Available'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: slot.isAvailable ? () => _openBooking(slot) : null,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../data/model/category.dart';
import '../../data/model/service.dart';
import '../../data/model/timeslot.dart';
import '../../data/model/user.dart';
import '../../data/repository/booking.dart';
import '../../data/repository/category.dart';
import '../../data/repository/service.dart';
import '../../data/repository/therapist.dart';
import '../../data/repository/timeslot.dart';
import 'booking_step_shared.dart';
import 'step1.dart';
import 'step2.dart';
import 'step3.dart';
import 'step4.dart';
import 'step5.dart';

/// Guided customer booking flow: service, therapist, time, summary, payment.
class BookingConfirmPage extends StatefulWidget {
  const BookingConfirmPage({super.key});

  @override
  State<BookingConfirmPage> createState() => _BookingConfirmPageState();
}

class _BookingConfirmPageState extends State<BookingConfirmPage> {
  final _categories = CategoryRepository();
  final _services = ServiceRepository();
  final _therapists = TherapistRepository();
  final _timeslots = TimeslotRepository();
  final _bookings = BookingRepository();

  int _step = 0;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<Category> _categoryItems = [];
  List<Service> _serviceItems = [];
  List<User> _therapistItems = [];
  List<BookingPriceOption> _priceOptions = [];
  Map<int, List<BookingPriceOption>> _priceOptionsByService = {};
  List<Timeslot> _slotItems = [];
  int? _categoryId;
  Service? _service;
  User? _therapist;
  BookingPriceOption? _priceOption;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  Timeslot? _slot;

  String? get _collectionName {
    final categoryId = _service?.categoryId;
    for (final category in _categoryItems) {
      if (category.id == categoryId) return category.name;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadCategories() async {
    try {
      final rows = await _categories.fetchCategories();
      if (rows.isNotEmpty) {
        final services = await _services.fetchServices(
          categoryId: rows.first.id,
        );
        final prices = await _fetchPriceOptions(services);
        if (!mounted) return;
        setState(() {
          _categoryItems = rows;
          _categoryId = rows.first.id;
          _serviceItems = services;
          _priceOptionsByService = prices;
          _loading = false;
        });
        if (services.isNotEmpty) await _selectService(services.first);
        return;
      }
      if (!mounted) return;
      setState(() {
        _categoryItems = rows;
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

  Future<Map<int, List<BookingPriceOption>>> _fetchPriceOptions(
    List<Service> services,
  ) async {
    if (services.isEmpty) return {};
    final rows = await Supabase.instance.client
        .from('service_attribute')
        .select('service_id, duration, sessions, price')
        .inFilter('service_id', services.map((service) => service.id).toList())
        .order('duration');
    final options = <int, List<BookingPriceOption>>{};
    for (final row in rows) {
      final values = Map<String, dynamic>.from(row);
      options
          .putIfAbsent((values['service_id'] as num).toInt(), () => [])
          .add(BookingPriceOption.fromJson(values));
    }
    return options;
  }

  Future<void> _selectCategory(Category category) async {
    setState(() {
      _loading = true;
      _error = null;
      _categoryId = category.id;
      _service = null;
      _priceOption = null;
      _therapist = null;
      _slot = null;
      _priceOptions = [];
    });
    try {
      final rows = await _services.fetchServices(categoryId: category.id);
      final prices = await _fetchPriceOptions(rows);
      if (!mounted) return;
      setState(() {
        _serviceItems = rows;
        _priceOptionsByService = prices;
        _loading = false;
        _step = 0;
      });
      if (rows.isNotEmpty) await _selectService(rows.first);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _selectService(Service service) async {
    final loadedOptions = _priceOptionsByService[service.id];
    if (service.id == _service?.id && loadedOptions != null) return;
    setState(() {
      _loading = true;
      _error = null;
      _service = service;
      _priceOption = null;
      _therapist = null;
      _slot = null;
      _priceOptions = [];
    });
    try {
      final attrs =
          loadedOptions ??
          (await Supabase.instance.client
                  .from('service_attribute')
                  .select('duration, sessions, price')
                  .eq('service_id', service.id)
                  .order('duration'))
              .map(
                (row) =>
                    BookingPriceOption.fromJson(Map<String, dynamic>.from(row)),
              )
              .toList();
      final therapists = await _therapists.fetchTherapists();
      final mappings = await _therapists.fetchServicesByTherapist(
        therapists.map((t) => t.id).toList(),
      );
      if (!mounted) return;
      final availableTherapists = therapists
          .where(
            (therapist) =>
                mappings[therapist.id]?.any((item) => item.id == service.id) ??
                false,
          )
          .toList();
      setState(() {
        _priceOptions = attrs;
        _priceOption = attrs.isEmpty ? null : attrs.first;
        _therapistItems = availableTherapists;
        _therapist = availableTherapists.isEmpty
            ? null
            : availableTherapists.first;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _selectTherapist(User therapist) async {
    setState(() {
      _therapist = therapist;
      _slot = null;
    });
  }

  Future<void> _loadSlots() async {
    final therapist = _therapist;
    if (therapist == null) return;
    try {
      final rows = await _timeslots.fetchTimeslots(
        date: _dateKey(_date),
        therapistId: therapist.id,
        availableOnly: true,
      );
      if (!mounted) return;
      setState(() {
        _slotItems = rows;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  bool get _canContinue => switch (_step) {
    0 => _service != null && (_priceOptions.isEmpty || _priceOption != null),
    1 => _therapist != null,
    2 => _slot != null,
    _ => true,
  };

  Future<void> _next() async {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    if (_step == 1) {
      setState(() {
        _loading = true;
        _error = null;
      });
      await _loadSlots();
      if (mounted && _error == null) setState(() => _step = 2);
      return;
    }
    if (_step == 2) {
      setState(() => _step = 3);
      return;
    }
    if (_step == 3) {
      setState(() => _step = 4);
    }
  }

  Future<void> _confirmAndPay() async {
    final customerId = Supabase.instance.client.auth.currentUser?.id;
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to request a booking.')),
      );
      return;
    }
    if (_therapist == null || _service == null || _slot == null) return;
    setState(() => _saving = true);
    try {
      final booking = await _bookings.createBooking(
        customerId: customerId,
        therapistId: _therapist!.id,
        bookingDate: _slot!.date,
        startTime: _slot!.startTime,
        endTime: _slot!.endTime,
        serviceId: _service!.id,
        duration: _priceOption?.duration == null
            ? null
            : '${_priceOption!.duration} minutes',
        price: _priceOption?.price,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PaymentPage(
            bookingId: booking.id,
            service: _service!,
            therapist: _therapist!,
            priceOption: _priceOption,
          ),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create booking: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Choose a service',
      'Choose a therapist',
      'Choose a time',
      'Booking summary',
      'Confirm & pay',
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF30372B),
            size: 20,
          ),
        ),
        centerTitle: true,
        title: _step <= 1
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.spa_outlined, color: Color(0xFF4A5D3E), size: 20),
                  SizedBox(width: 6),
                  Text(
                    'AUREA',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 20,
                      letterSpacing: .6,
                      color: Color(0xFF30372B),
                    ),
                  ),
                ],
              )
            : Text(titles[_step]),
        actions: [
          if (_step <= 1)
            IconButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Need a hand?'),
                  content: Text(
                    _step == 0
                        ? 'Choose a collection, select a treatment and duration, then choose your therapist.'
                        : 'Choose the therapist who feels right for you, then continue to choose a date and time.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(
                Icons.help_outline,
                color: Color(0xFF30372B),
                size: 20,
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
      body: Column(
        children: [
          _ProgressHeader(step: _step, title: titles[_step]),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _ErrorPanel(message: _error!, onRetry: _retry)
                : _buildStep(),
          ),
          if (!_loading && _error == null) _bottomBar(),
        ],
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
    0 => BookingStep1(
      categories: _categoryItems,
      categoryId: _categoryId,
      services: _serviceItems,
      priceOptionsByService: _priceOptionsByService,
      selectedService: _service,
      selectedPrice: _priceOption,
      onCategorySelected: _selectCategory,
      onServiceSelected: _selectService,
      onPriceSelected: (service, option) {
        if (service.id != _service?.id) {
          _selectService(service).then((_) {
            if (mounted) setState(() => _priceOption = option);
          });
        } else {
          setState(() => _priceOption = option);
        }
      },
    ),
    1 => BookingStep2(
      service: _service,
      collectionName: _collectionName,
      priceOption: _priceOption,
      therapists: _therapistItems,
      selectedTherapist: _therapist,
      onSelected: _selectTherapist,
      onEditService: () => setState(() => _step = 0),
    ),
    2 => BookingStep3(
      date: _date,
      slots: _slotItems,
      selectedSlot: _slot,
      onDateChanged: (date) {
        setState(() {
          _date = DateUtils.dateOnly(date);
          _slot = null;
          _loading = true;
        });
        _loadSlots();
      },
      onSlotSelected: (slot) => setState(() => _slot = slot),
    ),
    3 => BookingStep4(
      service: _service!,
      therapist: _therapist!,
      date: _date,
      slot: _slot!,
      priceOption: _priceOption,
    ),
    _ => BookingStep5(
      service: _service!,
      therapist: _therapist!,
      date: _date,
      slot: _slot!,
      priceOption: _priceOption,
    ),
  };

  Future<void> _retry() async {
    if (_step >= 2) return _loadSlots();
    if (_step == 1 && _therapist != null) {
      setState(() {
        _loading = true;
        _error = null;
      });
      return _loadSlots();
    }
    if (_categoryId != null && _service != null)
      return _selectService(_service!);
    if (_categoryId != null)
      return _selectCategory(
        _categoryItems.firstWhere((item) => item.id == _categoryId),
      );
    return _loadCategories();
  }

  Widget _bottomBar() {
    if (_step <= 1) {
      final price = _priceOption?.price;
      final isTherapistStep = _step == 1;
      return SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFEFA),
            border: Border(top: BorderSide(color: Color(0xFFE2E0D5))),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTherapistStep
                              ? 'Treatment price'
                              : 'Selected treatment',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF77796E),
                          ),
                        ),
                        Text(
                          price == null
                              ? 'Choose a service'
                              : '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF30372B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isTherapistStep && _therapist != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF1E7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _therapist!.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4A5D3E),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saving ? null : (_canContinue ? _next : null),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5D3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _saving
                            ? 'Please wait...'
                            : isTherapistStep
                            ? 'Choose date & time'
                            : 'Choose your therapist',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Row(
          children: [
            if (_step > 0)
              OutlinedButton(
                onPressed: _saving ? null : () => setState(() => _step--),
                child: const Text('Back'),
              ),
            const Spacer(),
            FilledButton(
              onPressed: _saving
                  ? null
                  : (_step == 4
                        ? _confirmAndPay
                        : (_canContinue ? _next : null)),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _step == 4
                          ? 'Confirm & continue to payment'
                          : _step == 3
                          ? 'Continue'
                          : 'Continue',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentPage extends StatelessWidget {
  const _PaymentPage({
    required this.bookingId,
    required this.service,
    required this.therapist,
    required this.priceOption,
  });
  final int bookingId;
  final Service service;
  final User therapist;
  final BookingPriceOption? priceOption;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Payment')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.account_balance_wallet_outlined, size: 64),
        const SizedBox(height: 20),
        Text(
          'Booking request received',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Request #$bookingId is pending confirmation with ${therapist.name}.',
        ),
        const SizedBox(height: 20),
        BookingSummaryTile(
          icon: Icons.spa_outlined,
          label: 'Service',
          value: service.name,
        ),
        if (priceOption != null)
          BookingSummaryTile(
            icon: Icons.payments_outlined,
            label: 'Amount',
            value: priceOption!.priceLabel,
          ),
        const SizedBox(height: 20),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Online payment is not available yet. The clinic will confirm your appointment and arrange payment with you.',
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.step, required this.title});
  final int step;
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (step <= 1) ...[
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [
                          step == 1 ? '✓  Service' : '01  Service',
                          '02  Therapist',
                          '03  Date & time',
                        ][i],
                        style: TextStyle(
                          fontSize: 10,
                          color: i <= step
                              ? const Color(0xFF4A5D3E)
                              : const Color(0xFF85867D),
                          fontWeight: i == step
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: i <= step
                              ? const Color(0xFF4A5D3E)
                              : const Color(0xFFE0DED3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ] else ...[
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i == 4 ? 0 : 6),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'STEP ${step + 1} OF 5',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ],
    ),
  );
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 42),
          const SizedBox(height: 12),
          const Text('Could not load booking options.'),
          Text(message, maxLines: 3, overflow: TextOverflow.ellipsis),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

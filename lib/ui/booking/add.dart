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
  bool _membershipLoaded = false;
  bool _isMember = false;
  String? _membershipError;
  bool _saving = false;
  String? _error;
  List<Category> _categoryItems = [];
  List<Service> _serviceItems = [];
  List<User> _therapistItems = [];
  Map<String, List<Service>> _servicesByTherapist = {};
  List<BookingPriceOption> _priceOptions = [];
  Map<int, List<BookingPriceOption>> _priceOptionsByService = {};
  List<Timeslot> _slotItems = [];
  int? _categoryId;
  Service? _service;
  User? _therapist;
  bool _anyTherapist = false;
  BookingPriceOption? _priceOption;
  BookingPriceOption? _extraTime;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  Timeslot? _slot;

  String? get _collectionName {
    final categoryId = _service?.categoryId;
    for (final category in _categoryItems) {
      if (category.id == categoryId) return category.name;
    }
    return null;
  }

  double? get _totalPrice {
    final option = _priceOption;
    if (option == null) return null;
    return _priceFor(option) +
        (_extraTime == null ? 0 : _priceFor(_extraTime!));
  }

  double _priceFor(BookingPriceOption option) =>
      _isMember ? option.membershipPrice ?? option.price : option.price;

  int? get _totalDuration {
    final base = _priceOption?.duration;
    if (base == null) return null;
    return base + (_extraTime?.duration ?? 0);
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCustomerMembership();
  }

  Future<void> _loadCustomerMembership() async {
    final customerId = Supabase.instance.client.auth.currentUser?.id;
    if (customerId == null) {
      if (mounted) setState(() => _membershipLoaded = true);
      return;
    }
    try {
      final profile = await Supabase.instance.client
          .from('user')
          .select('is_member')
          .eq('id', customerId)
          .maybeSingle();
      if (!mounted) return;
      setState(() {
        _isMember = profile?['is_member'] == true;
        _membershipError = null;
        _membershipLoaded = true;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _membershipError = error.toString();
          _error = 'Could not verify member pricing. Please retry.';
          _membershipLoaded = true;
        });
      }
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadCategories() async {
    try {
      final rows = await _categories.fetchCategories();
      final topLevel = _visibleCollections(rows);
      if (topLevel.isNotEmpty) {
        final services = await _services.fetchServices(
          categoryIds: _categoryIdsWithChildren(rows, topLevel.first.id),
        );
        final prices = await _fetchPriceOptions(services);
        if (!mounted) return;
        setState(() {
          _categoryItems = rows;
          _categoryId = topLevel.first.id;
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
        .select('service_id, duration, sessions, price, membership_price')
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

  List<int> _categoryIdsWithChildren(List<Category> categories, int id) => [
    id,
    for (final category in categories)
      if (category.parentId == id) category.id,
  ];

  // Offer groups packages and memberships but is not a bookable collection.
  List<Category> _visibleCollections(List<Category> categories) => [
    for (final category in categories)
      if (category.parentId == null &&
          category.name.trim().toLowerCase() != 'offer')
        category,
  ];

  Future<void> _selectCategory(Category category) async {
    setState(() {
      _loading = true;
      _error = null;
      _categoryId = category.id;
      _service = null;
      _priceOption = null;
      _extraTime = null;
      _therapist = null;
      _slot = null;
      _priceOptions = [];
      _servicesByTherapist = {};
    });
    try {
      final rows = await _services.fetchServices(
        categoryIds: _categoryIdsWithChildren(_categoryItems, category.id),
      );
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
    // Cached prices update instantly; only therapist filtering stays async.
    final cached = loadedOptions != null;
    setState(() {
      if (!cached) _loading = true;
      _error = null;
      _service = service;
      _therapist = null;
      _anyTherapist = false;
      _slot = null;
      _priceOptions = loadedOptions ?? [];
      _priceOption = loadedOptions == null || loadedOptions.isEmpty
          ? null
          : loadedOptions.first;
    });
    try {
      final attrs =
          loadedOptions ??
          (await Supabase.instance.client
                  .from('service_attribute')
                  .select('duration, sessions, price, membership_price')
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
      if (!mounted || _service?.id != service.id) return;
      final availableTherapists = therapists
          .where(
            (therapist) =>
                mappings[therapist.id]?.any((item) => item.id == service.id) ??
                false,
          )
          .toList();
      setState(() {
        _priceOptions = attrs;
        _priceOption ??= attrs.isEmpty ? null : attrs.first;
        _therapistItems = availableTherapists;
        _servicesByTherapist = mappings;
        _therapist = availableTherapists.isEmpty
            ? null
            : availableTherapists.first;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || _service?.id != service.id) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _selectTherapist(User therapist) async {
    setState(() {
      _therapist = therapist;
      _anyTherapist = false;
      _slot = null;
    });
  }

  void _selectAnyTherapist() {
    setState(() {
      _therapist = null;
      _anyTherapist = true;
      _slot = null;
    });
  }

  Future<void> _loadSlots() async {
    if (_therapist == null && !_anyTherapist) return;
    try {
      final rows = await _timeslots.fetchTimeslots(
        date: _dateKey(_date),
        therapistId: _therapist?.id,
        anyTherapistIds: _anyTherapist
            ? [for (final therapist in _therapistItems) therapist.id]
            : null,
        availableOnly: true,
        requiredMinutes: _totalDuration,
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

  Future<User?> _findFreeTherapist() async {
    final slot = _slot;
    if (slot == null) return null;
    final bookings = await Supabase.instance.client
        .from('booking')
        .select('therapist_id, start_time, end_time')
        .eq('booking_date', slot.date)
        .inFilter('status', ['booked', 'pending']);
    int minutes(String time) {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final start = minutes(slot.startTime);
    final end = minutes(slot.endTime);
    final busy = <String>{};
    for (final row in bookings as List) {
      final values = Map<String, dynamic>.from(row);
      final therapistId = values['therapist_id']?.toString();
      if (therapistId == null) continue;
      final bookingStart = minutes(values['start_time'].toString());
      final bookingEnd = minutes(values['end_time'].toString());
      if (bookingStart < end && start < bookingEnd) busy.add(therapistId);
    }
    for (final therapist in _therapistItems) {
      if (!busy.contains(therapist.id)) return therapist;
    }
    return null;
  }

  bool get _canContinue => switch (_step) {
    0 => _service != null && (_priceOptions.isEmpty || _priceOption != null),
    1 => _therapist != null || _anyTherapist,
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
    if (_service == null || _slot == null) return;
    if (_therapist == null && !_anyTherapist) return;
    setState(() => _saving = true);
    try {
      final bookingTherapist = _anyTherapist
          ? await _findFreeTherapist()
          : _therapist;
      if (!mounted) return;
      if (bookingTherapist == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That time was just taken. Please pick another.'),
          ),
        );
        return;
      }
      final booking = await _bookings.createBooking(
        customerId: customerId,
        therapistId: bookingTherapist.id,
        bookingDate: _slot!.date,
        startTime: _slot!.startTime,
        endTime: _slot!.endTime,
        serviceId: _service!.id,
        duration: _totalDuration == null ? null : '$_totalDuration minutes',
        price: _totalPrice,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PaymentPage(
            bookingId: booking.id,
            service: _service!,
            therapistName: bookingTherapist.name,
            totalPrice: _totalPrice,
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
            ? Image.asset(
                'assets/enso-logo.png',
                height: 34,
                fit: BoxFit.contain,
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
            child: _loading || !_membershipLoaded
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _ErrorPanel(message: _error!, onRetry: _retry)
                : _buildStep(),
          ),
          if (!_loading && _membershipLoaded && _error == null) _bottomBar(),
        ],
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
    0 => BookingStep1(
      categories: _visibleCollections(_categoryItems),
      categoryId: _categoryId,
      services: _serviceItems,
      priceOptionsByService: _priceOptionsByService,
      selectedService: _service,
      selectedPrice: _priceOption,
      isMember: _isMember,
      selectedExtraTime: _extraTime,
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
      onExtraTimeSelected: (option) =>
          setState(() => _extraTime = _extraTime == option ? null : option),
    ),
    1 => BookingStep2(
      service: _service,
      collectionName: _collectionName,
      priceOption: _priceOption,
      extraTime: _extraTime,
      therapists: _therapistItems,
      servicesByTherapist: _servicesByTherapist,
      selectedTherapist: _therapist,
      anyTherapist: _anyTherapist,
      onSelected: _selectTherapist,
      onAnySelected: _selectAnyTherapist,
      onEditService: () => setState(() => _step = 0),
    ),
    2 => BookingStep3(
      service: _service,
      collectionName: _collectionName,
      priceOption: _priceOption,
      extraTime: _extraTime,
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
      extraTime: _extraTime,
      totalPrice: _totalPrice,
    ),
    _ => BookingStep5(
      service: _service!,
      therapist: _therapist!,
      date: _date,
      slot: _slot!,
      priceOption: _priceOption,
      extraTime: _extraTime,
      totalPrice: _totalPrice,
    ),
  };

  Future<void> _retry() async {
    if (_membershipError != null) {
      setState(() {
        _loading = true;
        _membershipLoaded = false;
        _error = null;
      });
      await _loadCustomerMembership();
      if (mounted && _membershipError == null) return _loadCategories();
      return;
    }
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
      final price = _totalPrice;
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
                          _isMember
                              ? 'Member total'
                              : isTherapistStep
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
                              : '\$${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF30372B),
                          ),
                        ),
                        if (_extraTime != null)
                          const Text(
                            'Includes extra time',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF77796E),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isTherapistStep && (_therapist != null || _anyTherapist))
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
                        _anyTherapist ? 'No preference' : _therapist!.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4A5D3E),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (isTherapistStep) ...[
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _step = 0),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A5D3E),
                          side: const BorderSide(color: Color(0xFF4A5D3E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _saving
                            ? null
                            : (_canContinue ? _next : null),
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
                  ),
                ],
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
    required this.therapistName,
    required this.totalPrice,
  });
  final int bookingId;
  final Service service;
  final String therapistName;
  final double? totalPrice;

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
          'Request #$bookingId is pending confirmation with $therapistName.',
        ),
        const SizedBox(height: 20),
        BookingSummaryTile(
          icon: Icons.spa_outlined,
          label: 'Service',
          value: service.name,
        ),
        if (totalPrice != null)
          BookingSummaryTile(
            icon: Icons.payments_outlined,
            label: 'Amount',
            value: '\$${totalPrice!.toStringAsFixed(0)}',
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

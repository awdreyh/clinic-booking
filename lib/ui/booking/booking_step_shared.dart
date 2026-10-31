import 'package:flutter/material.dart';

import '../../data/model/category.dart';
import '../../data/model/service.dart';
import '../../data/model/timeslot.dart';

class BookingPriceOption {
  const BookingPriceOption({
    this.duration,
    this.sessions,
    required this.price,
    this.membershipPrice,
  });

  final int? duration;
  final int? sessions;
  final double price;
  final double? membershipPrice;

  String get label => duration != null
      ? '$duration minutes'
      : sessions != null
          ? '$sessions sessions'
          : 'Standard';
  String get priceLabel => '\$${price.toStringAsFixed(0)}';

  factory BookingPriceOption.fromJson(Map<String, dynamic> json) =>
      BookingPriceOption(
        duration: (json['duration'] as num?)?.toInt(),
        sessions: (json['sessions'] as num?)?.toInt(),
        price: (json['price'] as num).toDouble(),
        membershipPrice: (json['membership_price'] as num?)?.toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      other is BookingPriceOption &&
      other.duration == duration &&
      other.sessions == sessions &&
      other.price == price &&
      other.membershipPrice == membershipPrice;

  @override
  int get hashCode => Object.hash(duration, sessions, price, membershipPrice);
}

class BookingServiceSummary extends StatelessWidget {
  const BookingServiceSummary({
    super.key,
    required this.service,
    this.collectionName,
    this.priceOption,
    this.extraTime,
    this.onEdit,
  });

  final Service? service;
  final String? collectionName;
  final BookingPriceOption? priceOption;
  final BookingPriceOption? extraTime;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF0EEE5),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.spa_outlined, color: Color(0xFF4A5D3E)),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service?.name ?? 'Selected treatment',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF30372B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                [
                  if (collectionName?.isNotEmpty == true) collectionName!,
                  if (priceOption != null)
                    priceOption!.duration != null
                        ? '${priceOption!.duration} min'
                        : priceOption!.label,
                  if (extraTime != null)
                    '+${extraTime!.duration ?? 0} min extra time',
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF797A6F)),
              ),
            ],
          ),
        ),
        if (onEdit != null)
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4A5D3E),
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 11,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    ),
  );
}

String formatBookingTimeRange(BuildContext context, Timeslot slot) {
  String format(String value) {
    final parts = value.split(':');
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
  }

  return '${format(slot.startTime)} - ${format(slot.endTime)}';
}

class BookingCategoryButton extends StatelessWidget {
  const BookingCategoryButton({
    super.key,
    required this.category,
    required this.index,
    required this.onTap,
  });

  final Category category;
  final int index;
  final VoidCallback onTap;

  static const _icons = [
    Icons.spa_outlined,
    Icons.self_improvement_outlined,
    Icons.health_and_safety_outlined,
    Icons.spa,
  ];

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              height: 142,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: category.image?.isNotEmpty == true
                        ? Image.network(
                            category.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/enso-bg.jpg',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset('assets/enso-bg.jpg', fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .48),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(_icons[index % _icons.length],
                            size: 36, color: Colors.white),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                              if (category.description?.isNotEmpty == true)
                                Text(
                                  category.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.white70),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class BookingImageOrIcon extends StatelessWidget {
  const BookingImageOrIcon({
    super.key,
    required this.url,
    required this.icon,
    required this.size,
  });

  final String? url;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url?.isNotEmpty != true) return Icon(icon, size: 28);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(icon, size: 28),
      ),
    );
  }
}

class BookingSummaryTile extends StatelessWidget {
  const BookingSummaryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(label, style: Theme.of(context).textTheme.bodySmall),
        subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
      );
}

class BookingEmptyState extends StatelessWidget {
  const BookingEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(child: Text(message, textAlign: TextAlign.center)),
      );
}

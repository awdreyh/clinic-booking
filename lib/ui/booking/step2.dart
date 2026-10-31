import 'package:flutter/material.dart';

import '../../data/model/service.dart';
import '../../data/model/user.dart';
import 'booking_step_shared.dart';

class BookingStep2 extends StatelessWidget {
  const BookingStep2({
    super.key,
    required this.service,
    required this.collectionName,
    required this.priceOption,
    required this.extraTime,
    required this.therapists,
    required this.servicesByTherapist,
    required this.selectedTherapist,
    required this.anyTherapist,
    required this.onSelected,
    required this.onAnySelected,
    required this.onEditService,
  });

  final Service? service;
  final String? collectionName;
  final BookingPriceOption? priceOption;
  final BookingPriceOption? extraTime;
  final List<User> therapists;
  final Map<String, List<Service>> servicesByTherapist;
  final User? selectedTherapist;
  final bool anyTherapist;
  final ValueChanged<User> onSelected;
  final VoidCallback onAnySelected;
  final VoidCallback onEditService;

  static const _ink = Color(0xFF30372B);
  static const _olive = Color(0xFF4A5D3E);
  static const _muted = Color(0xFF797A6F);

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
    children: [
      const Text(
        'IN CARING HANDS',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .6,
          color: _olive,
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        'Find your therapist',
        style: TextStyle(
          fontSize: 30,
          height: 1.12,
          fontFamily: 'serif',
          color: _ink,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Expert care, with a personal connection.',
        style: TextStyle(fontSize: 13, color: _muted),
      ),
      const SizedBox(height: 20),
      BookingServiceSummary(
        service: service,
        collectionName: collectionName,
        priceOption: priceOption,
        extraTime: extraTime,
        onEdit: onEditService,
      ),
      const SizedBox(height: 20),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Text(
              'Our specialists',
              style: TextStyle(fontFamily: 'serif', fontSize: 22, color: _ink),
            ),
          ),
          Text(
            '${therapists.length} available',
            style: const TextStyle(fontSize: 10, color: _muted),
          ),
        ],
      ),
      const SizedBox(height: 10),
      if (therapists.isEmpty)
        const BookingEmptyState(
          message: 'No therapists currently provide this service.',
        )
      else
        for (final therapist in therapists)
          _TherapistCard(
            therapist: therapist,
            services: servicesByTherapist[therapist.id] ?? const [],
            selected: therapist.id == selectedTherapist?.id,
            onTap: () => onSelected(therapist),
          ),
      _NoPreferenceCard(selected: anyTherapist, onTap: onAnySelected),
      const SizedBox(height: 8),
      const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2, right: 10),
            child: Icon(Icons.verified_user_outlined, size: 18, color: _olive),
          ),
          Expanded(
            child: Text(
              'Every therapist is carefully chosen to help you feel your best.',
              style: TextStyle(fontSize: 11, height: 1.5, color: _muted),
            ),
          ),
        ],
      ),
    ],
  );
}

class _NoPreferenceCard extends StatelessWidget {
  const _NoPreferenceCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFEEF1E7) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: selected ? const Color(0xFF526447) : const Color(0xFFDDDCCF),
        width: selected ? 1.4 : 1,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF1E7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shuffle,
                color: Color(0xFF4A5D3E),
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No preference',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF30372B),
                    ),
                  ),
                  Text(
                    "We'll match you with an available therapist.",
                    style: TextStyle(fontSize: 11, color: Color(0xFF797A6F)),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4A5D3E),
                size: 20,
              ),
          ],
        ),
      ),
    ),
  );
}

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({
    required this.therapist,
    required this.services,
    required this.selected,
    required this.onTap,
  });

  final User therapist;
  final List<Service> services;
  final bool selected;
  final VoidCallback onTap;

  String? _metadataText(List<String> keys) {
    final metadata = therapist.meta;
    if (metadata == null) return null;
    for (final key in keys) {
      final value = metadata[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final experience = _metadataText([
      'years_of_experience',
      'experience_years',
      'yearsExperience',
    ]);
    final rating = _metadataText(['rating', 'average_rating']);
    final reviews = _metadataText(['review_count', 'reviews', 'rating_count']);
    final photoUrl = therapist.photoUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEEF1E7) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFF526447) : const Color(0xFFDDDCCF),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: SizedBox(
                      width: 66,
                      height: 78,
                      child: photoUrl?.isNotEmpty == true
                          ? Image.network(
                              photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const _TherapistPlaceholder(),
                            )
                          : const _TherapistPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          therapist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 21,
                            height: 1.1,
                            color: Color(0xFF30372B),
                          ),
                        ),
                        if (therapist.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            therapist.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF797A6F),
                            ),
                          ),
                        ],
                        if (services.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Services · ${services.map((service) => service.name).join(' · ')}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.3,
                              color: Color(0xFF4A5D3E),
                            ),
                          ),
                        ],
                        if (experience != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$experience years of practice',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF797A6F),
                            ),
                          ),
                        ],
                        if (rating != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_border,
                                size: 14,
                                color: Color(0xFF8A6A2D),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$rating${reviews == null ? '' : '  ($reviews reviews)'}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF30372B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 22,
                    color: selected
                        ? const Color(0xFF4A5D3E)
                        : const Color(0xFFDDDCCF),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 9),
                child: Divider(height: 1, color: Color(0xFFD8D7CA)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TherapistPlaceholder extends StatelessWidget {
  const _TherapistPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFE4E8DD),
    alignment: Alignment.center,
    child: const Icon(Icons.person_outline, size: 30, color: Color(0xFF68745E)),
  );
}

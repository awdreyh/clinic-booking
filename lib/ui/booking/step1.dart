import 'package:flutter/material.dart';

import '../../data/model/category.dart';
import '../../data/model/service.dart';
import 'booking_step_shared.dart';

class BookingStep1 extends StatelessWidget {
  const BookingStep1({
    super.key,
    required this.categories,
    required this.categoryId,
    required this.services,
    required this.priceOptionsByService,
    required this.selectedService,
    required this.selectedPrice,
    required this.isMember,
    required this.onCategorySelected,
    required this.onServiceSelected,
    required this.onPriceSelected,
    required this.selectedExtraTime,
    required this.onExtraTimeSelected,
  });

  final List<Category> categories;
  final int? categoryId;
  final List<Service> services;
  final Map<int, List<BookingPriceOption>> priceOptionsByService;
  final Service? selectedService;
  final BookingPriceOption? selectedPrice;
  final bool isMember;
  final BookingPriceOption? selectedExtraTime;
  final ValueChanged<Category> onCategorySelected;
  final ValueChanged<Service> onServiceSelected;
  final void Function(Service service, BookingPriceOption option)
  onPriceSelected;
  final ValueChanged<BookingPriceOption> onExtraTimeSelected;

  static const _ink = Color(0xFF30372B);
  static const _olive = Color(0xFF4A5D3E);

  @override
  Widget build(BuildContext context) {
    Service? extraTimeService;
    for (final service in services) {
      if (service.name.trim().toLowerCase() == 'extra time') {
        extraTimeService = service;
        break;
      }
    }
    final treatments = services
        .where((service) => service.name.trim().toLowerCase() != 'extra time')
        .toList();
    final extraTimeOptions = extraTimeService == null
        ? const <BookingPriceOption>[]
        : priceOptionsByService[extraTimeService.id] ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const Text(
          'YOUR MOMENT OF CALM',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: .7,
            color: _olive,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Choose your ritual',
          style: TextStyle(
            fontSize: 30,
            height: 1.12,
            fontFamily: 'serif',
            color: _ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Find your collection, then select a treatment.',
          style: TextStyle(fontSize: 13, color: Color(0xFF797A6F)),
        ),
        const SizedBox(height: 20),
        if (categories.isEmpty)
          const BookingEmptyState(
            message: 'No service collections are available yet.',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 166,
            ),
            itemBuilder: (context, index) => _CollectionCard(
              category: categories[index],
              selected: categories[index].id == categoryId,
              onTap: () => onCategorySelected(categories[index]),
            ),
          ),
        if (categoryId != null) ...[
          const SizedBox(height: 18),
          Text(
            '${categories.firstWhere((category) => category.id == categoryId, orElse: () => categories.first).name} services',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          if (treatments.isEmpty)
            const BookingEmptyState(
              message: 'No treatments in this collection.',
            )
          else
            for (final service in treatments)
              _ServiceCard(
                service: service,
                selected: selectedService?.id == service.id,
                options: priceOptionsByService[service.id] ?? const [],
                selectedPrice: selectedService?.id == service.id
                    ? selectedPrice
                    : null,
                isMember: isMember,
                onTap: () => onServiceSelected(service),
                onPriceSelected: (option) => onPriceSelected(service, option),
              ),
          if (extraTimeOptions.isNotEmpty) ...[
            const SizedBox(height: 15),
            const Text(
              'A little more time',
              style: TextStyle(fontFamily: 'serif', fontSize: 22, color: _ink),
            ),
            const SizedBox(height: 5),
            const Text(
              'Add a little extra time to your visit.',
              style: TextStyle(fontSize: 12, color: Color(0xFF797A6F)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final option in extraTimeOptions)
                  _ExtraTime(
                    option: option,
                    selected: option == selectedExtraTime,
                    onTap: () => onExtraTimeSelected(option),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 3, right: 12),
                child: Icon(Icons.spa_outlined, color: _olive, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A little more than a treatment',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'A personal consultation and a calming herbal tea are included with every ritual.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF797A6F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });
  final Category category;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFEEF1E7) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: selected ? const Color(0xFF8C9A7D) : const Color(0xFFDDDCCF),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: category.image?.isNotEmpty == true
                ? Image.network(
                    category.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Image.asset('assets/enso-bg.jpg', fit: BoxFit.cover),
                  )
                : Image.asset('assets/enso-bg.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 8, 10, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    height: 1.1,
                    color: Color(0xFF30372B),
                  ),
                ),
                if (category.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    category.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF73766C),
                    ),
                  ),
                ],
                if (selected)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'SELECTED COLLECTION',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3,
                        color: Color(0xFF4A5D3E),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.selected,
    required this.options,
    required this.selectedPrice,
    required this.isMember,
    required this.onTap,
    required this.onPriceSelected,
  });
  final Service service;
  final bool selected;
  final List<BookingPriceOption> options;
  final BookingPriceOption? selectedPrice;
  final bool isMember;
  final VoidCallback onTap;
  final ValueChanged<BookingPriceOption> onPriceSelected;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFEEF1E7) : Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: selected ? const Color(0xFF99A48D) : const Color(0xFFDDDCCF),
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: service.image?.isNotEmpty == true
                        ? Image.network(
                            service.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.spa_outlined,
                              color: Color(0xFF4A5D3E),
                            ),
                          )
                        : const Icon(
                            Icons.spa_outlined,
                            color: Color(0xFF4A5D3E),
                          ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF30372B),
                        ),
                      ),
                      if (service.description?.isNotEmpty == true)
                        Text(
                          service.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF797A6F),
                          ),
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
            if (options.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final option in options)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _PriceOption(
                          option: option,
                          selected: option == selectedPrice,
                          isMember: isMember,
                          onTap: () => onPriceSelected(option),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _PriceOption extends StatelessWidget {
  const _PriceOption({
    required this.option,
    required this.selected,
    required this.isMember,
    required this.onTap,
  });
  final BookingPriceOption option;
  final bool selected;
  final bool isMember;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(5),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: selected ? const Color(0xFF4A5D3E) : const Color(0xFFD9D9CE),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF4A5D3E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Text(
                option.duration == null
                    ? option.label
                    : '${option.duration} min',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isMember && option.membershipPrice != null
                        ? '\$${option.membershipPrice!.toStringAsFixed(0)}'
                        : option.priceLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isMember ? FontWeight.w700 : FontWeight.w400,
                      color: isMember
                          ? const Color(0xFF4A5D3E)
                          : const Color(0xFF394633),
                    ),
                  ),
                  if (!isMember && option.membershipPrice != null) ...[
                    const Text(
                      ' | ',
                      style: TextStyle(fontSize: 10, color: Color(0xFFB9BBAE)),
                    ),
                    const Icon(
                      Icons.card_membership,
                      size: 10,
                      color: Color(0xFF4A5D3E),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '\$${option.membershipPrice!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A5D3E),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ExtraTime extends StatelessWidget {
  const _ExtraTime({
    required this.option,
    required this.selected,
    required this.onTap,
  });
  final BookingPriceOption option;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFEEF1E7) : Colors.white,
    borderRadius: BorderRadius.circular(5),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF4A5D3E) : const Color(0xFFD9D9CE),
            width: selected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${option.duration ?? 0} min',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFF4A5D3E)
                        : const Color(0xFF394633),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check, size: 11, color: Color(0xFF4A5D3E)),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '+${option.priceLabel}',
              style: TextStyle(
                fontSize: 9,
                color: selected
                    ? const Color(0xFF4A5D3E)
                    : const Color(0xFF73766C),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

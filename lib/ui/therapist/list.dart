import 'package:flutter/material.dart';

import '../../data/model/service.dart';
import '../../data/model/user.dart';
import '../../data/repository/therapist.dart';
import 'detail.dart';

class TherapistListPage extends StatefulWidget {
  const TherapistListPage({super.key});

  @override
  State<TherapistListPage> createState() => _TherapistListPageState();
}

class _TherapistListPageState extends State<TherapistListPage> {
  final _repository = TherapistRepository();
  late Future<_TherapistDirectory> _directory;

  @override
  void initState() {
    super.initState();
    _directory = _loadDirectory();
  }

  Future<_TherapistDirectory> _loadDirectory() async {
    final users = await _repository.fetchTherapists();
    final services = await _repository.fetchServicesByTherapist(
      users.map((user) => user.id).toList(),
    );
    return _TherapistDirectory(users, services);
  }

  Future<void> _refresh() async {
    final future = _loadDirectory();
    setState(() => _directory = future);
    await future;
  }

  void _openTherapist(User therapist, List<Service> services) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            TherapistDetailPage(therapist: therapist, services: services),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Therapists')),
        body: FutureBuilder<_TherapistDirectory>(
          future: _directory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load therapists.'),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              );
            }
            final directory = snapshot.data ??
                const _TherapistDirectory([], <String, List<Service>>{});
            final therapists = directory.users;
            if (therapists.isEmpty) {
              return const Center(child: Text('No therapists available yet.'));
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: therapists.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final therapist = therapists[index];
                  final services =
                      directory.services[therapist.id] ?? const <Service>[];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openTherapist(
                        therapist,
                        directory.services[therapist.id] ?? const [],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TherapistPhoto(url: therapist.photoUrl),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(therapist.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  if (services.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      services
                                          .map((service) => service.name)
                                          .join(' · '),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 16),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          therapist.phone,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
}

class _TherapistDirectory {
  const _TherapistDirectory(this.users, this.services);

  final List<User> users;
  final Map<String, List<Service>> services;
}

class _TherapistPhoto extends StatelessWidget {
  const _TherapistPhoto({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 88,
          height: 88,
          child: url == null || url!.isEmpty
              ? Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.person, size: 42),
                )
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.person, size: 42),
                  ),
                ),
        ),
      );
}

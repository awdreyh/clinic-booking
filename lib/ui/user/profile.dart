import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/locale_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.role});

  final String role;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _phoneController = TextEditingController();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _savingPhone = false;
  bool _joining = false;
  String? _loadError;

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _loading = false;
        _loadError = 'Please sign in again.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final row = await _supabase
          .from('user')
          .select('name, email, phone, role, is_member, member_since, membership_expires')
          .eq('id', userId)
          .maybeSingle();
      if (!mounted) return;
      if (row == null) {
        setState(() {
          _loading = false;
          _loadError = 'Profile not found.';
        });
        return;
      }
      setState(() {
        _profile = Map<String, dynamic>.from(row);
        _phoneController.text = row['phone']?.toString() ?? '';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load your profile.';
      });
    }
  }

  Future<void> _savePhone() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    setState(() => _savingPhone = true);
    try {
      await _supabase.from('user').update({
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      if (!mounted) return;
      _showMessage('Phone number saved.');
      await _loadProfile();
    } catch (_) {
      if (mounted) _showMessage('Could not save the phone number.');
    } finally {
      if (mounted) setState(() => _savingPhone = false);
    }
  }

  Future<void> _joinMembership() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text('Join membership', '加入会员')),
        content: Text(_text(
          'Join Enso membership for member pricing and priority booking?',
          '加入 Enso 会员，享受会员价格和优先预约？',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_text('Cancel', '取消')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_text('Join', '加入')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _joining = true);
    final now = DateTime.now();
    try {
      await _supabase.from('user').update({
        'is_member': true,
        'member_since': now.toIso8601String(),
        'membership_expires': now.add(const Duration(days: 365)).toIso8601String(),
        'updated_at': now.toIso8601String(),
      }).eq('id', userId);
      if (!mounted) return;
      _showMessage(_text('Membership activated.', '会员资格已启用。'));
      await _loadProfile();
    } catch (_) {
      if (mounted) _showMessage(_text('Could not join membership.', '无法加入会员。'));
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      if (mounted) _showMessage(_text('Could not sign out.', '无法退出登录。'));
    }
  }

  String _text(String english, String chinese) =>
      Localizations.localeOf(context).languageCode == 'zh' ? chinese : english;

  String _date(Object? value) {
    if (value == null) return _text('Not available', '暂无');
    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return _text('Not available', '暂无');
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final profile = _profile;
    final isMember = profile?['is_member'] == true;
    final expires = profile?['membership_expires'];
    final membershipActive = isMember &&
        (expires == null || DateTime.tryParse(expires.toString())?.isAfter(DateTime.now()) == true);

    return Scaffold(
      appBar: AppBar(title: Text(_text('Profile', '个人资料'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!),
                      TextButton(onPressed: _loadProfile, child: Text(l10n.retry)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                        title: Text(profile?['name']?.toString() ?? ''),
                        subtitle: Text(profile?['email']?.toString() ?? ''),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_text('Phone number', '电话号码'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: _text('Add a phone number', '添加电话号码'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _savingPhone ? null : _savePhone,
                        child: _savingPhone
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.save),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(l10n.language),
                            trailing: DropdownButton<String>(
                              value: locale,
                              underline: const SizedBox.shrink(),
                              items: [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text(l10n.languageEnglish),
                                ),
                                DropdownMenuItem(
                                  value: 'zh',
                                  child: Text(l10n.languageChinese),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<LocaleProvider>().setLocale(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.role == 'customer') ...[
                      const SizedBox(height: 24),
                      Text(_text('Membership', '会员信息'),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Card(
                        color: AppColors.accentLight,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    membershipActive ? Icons.verified : Icons.spa_outlined,
                                    color: AppColors.accentDark,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      membershipActive
                                          ? _text('Enso member', 'Enso 会员')
                                          : _text('Not a member', '尚未加入会员'),
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(_text(
                                'Member pricing and priority booking.',
                                '享受会员价格和优先预约。',
                              )),
                              if (membershipActive) ...[
                                const SizedBox(height: 12),
                                Text('${_text('Member since', '加入日期')}: ${_date(profile?['member_since'])}'),
                                Text('${_text('Expires', '到期日期')}: ${_date(expires)}'),
                              ] else ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: _joining ? null : _joinMembership,
                                    child: _joining
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(_text('Join member', '加入会员')),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.signOut),
                    ),
                  ],
                ),
    );
  }
}

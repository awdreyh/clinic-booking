import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialSignUp = false});

  final bool initialSignUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isSignUp;
  bool _isLoading = false;

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialSignUp;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final isSignUp = _isSignUp;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(l10n.tr('Please enter email and password.'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isSignUp) {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );
        _showSnackBar(
          response.session != null
              ? l10n.tr('Account created successfully.')
              : l10n.tr('Account created. Check your inbox for a confirmation link.'),
        );
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        // AuthGate reacts to the new session and returns to the dashboard.
      }
    } on AuthException catch (error) {
      debugPrint('${isSignUp ? 'Sign-up' : 'Login'} failed: ${error.message}');
      _showSnackBar(error.message);
    } catch (error, stackTrace) {
      debugPrint('${isSignUp ? 'Sign-up' : 'Login'} failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showSnackBar(l10n.tr('An unexpected error occurred.'));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? l10n.signUp : l10n.signIn)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration:  InputDecoration(labelText: l10n.email),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: l10n.password),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isSignUp ? l10n.signUp : l10n.signIn),
                  ),
            TextButton(
              onPressed: () {
                setState(() => _isSignUp = !_isSignUp);
              },
              child: Text(
                _isSignUp
                    ? l10n.tr('Already have an account? Sign In')
                    : l10n.tr("Don't have an account? Sign Up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

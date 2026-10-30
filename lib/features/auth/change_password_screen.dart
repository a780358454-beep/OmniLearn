import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/i18n/app_translations.dart';
import '../../core/design/design_tokens.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final i18n = I18nService.instance;
    if (_loading) return;

    if (_newController.text != _confirmController.text) {
      setState(() => _error = i18n.t('passwords_dont_match'));
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    final result = await AppStateService.instance.changeOwnPassword(
      _oldController.text,
      _newController.text,
    );

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.t('password_changed_success'))),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        _loading = false;
        _error = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final i18n = I18nService.instance;
    final mustChange =
        AppStateService.instance.currentUser.mustChangePassword;

    return Scaffold(
      appBar: AppBar(title: Text(i18n.t('change_password'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (mustChange)
                Container(
                  padding: const EdgeInsets.all(Space.md),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(RadiusTokens.card),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: cs.onTertiaryContainer),
                      const SizedBox(width: Space.sm),
                      Expanded(
                        child: Text(
                          i18n.t('must_change_pass_alert'),
                          style: TextStyle(color: cs.onTertiaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: Space.lg),

              TextField(
                controller: _oldController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: i18n.t('current_password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _newController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: i18n.t('new_password'),
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _confirmController,
                obscureText: _obscure,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: i18n.t('confirm_password'),
                  prefixIcon: const Icon(Icons.check_circle_outline),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: Space.md),
                Container(
                  padding: const EdgeInsets.all(Space.md),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(RadiusTokens.field),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: cs.onErrorContainer),
                      const SizedBox(width: Space.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: cs.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: Space.xl),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(i18n.t('save_changes')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
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
    if (_loading) return;

    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'كلمتا السر الجديدتان غير متطابقتين');
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
        const SnackBar(content: Text('تم تغيير كلمة السر بنجاح')),
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
    final mustChange =
        AppStateService.instance.currentUser.mustChangePassword;

    return Scaffold(
      appBar: AppBar(title: const Text('تغيير كلمة السر')),
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
                          'أنت تستخدم كلمة سر افتراضية. غيّرها الآن.',
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
                decoration: const InputDecoration(
                  labelText: 'كلمة السر الحالية',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _newController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'كلمة السر الجديدة',
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
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة السر الجديدة',
                  prefixIcon: Icon(Icons.check_circle_outline),
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
                      : const Text('حفظ كلمة السر'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

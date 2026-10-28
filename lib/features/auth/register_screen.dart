import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/design/design_tokens.dart';
import '../learner/learner_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    if (_passController.text != _confirmController.text) {
      setState(() => _error = 'كلمتا السر غير متطابقتين');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    final result = await AppStateService.instance.register(
      name: _nameController.text,
      email: _emailController.text,
      username: _userController.text,
      password: _passController.text,
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LearnerHomeScreen()),
        (route) => false,
      );
      return;
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

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'أنشئ حسابك وابدأ التعلّم فورًا.',
                style: AppTypography.bodySmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.xl),

              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _userController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم (إنجليزي وأرقام)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _passController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'كلمة السر',
                  prefixIcon: const Icon(Icons.lock_outline),
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
                  labelText: 'تأكيد كلمة السر',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
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
                      : const Text('إنشاء الحساب والدخول'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

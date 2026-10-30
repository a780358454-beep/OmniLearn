import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/app_state_service.dart';
import 'core/i18n/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/learner/learner_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // التهيئة تُنتظر قبل أول إطار — هذا ما يمنع شاشة التحميل الأبدية
  try {
    await AppStateService.instance
        .ensureInitialized()
        .timeout(const Duration(seconds: 8));
  } catch (_) {
    // لا نمنع الإقلاع مهما حدث؛ البوابة ستتعامل مع الحالة
  }

  runApp(const MasraApp());
}

class MasraApp extends StatelessWidget {
  const MasraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    final i18n = I18nService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([state, i18n]),
      builder: (context, _) {
        final branding = state.branding;
        final primary = Color(branding.primaryColorValue);
        final accent = Color(branding.accentColorValue);

        return MaterialApp(
          title: branding.appName,
          debugShowCheckedModeBanner: false,
          locale: i18n.locale,
          supportedLocales: const [
            Locale('ar', ''),
            Locale('en', ''),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.light(primary: primary, accent: accent),
          darkTheme: AppTheme.dark(primary: primary, accent: accent),
          // الاتجاه هنا فوق الـNavigator حتى تشمله كل الشاشات والحوارات
          builder: (context, child) => Directionality(
            textDirection: i18n.textDirection,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const RootGate(),
        );
      },
    );
  }
}

/// بوابة الإقلاع: تحميل → دخول → التطبيق.
/// لا تعرض دائرة إلى ما لا نهاية: بعد مهلة تظهر شاشة خطأ بزر إعادة المحاولة.
class RootGate extends StatefulWidget {
  const RootGate({Key? key}) : super(key: key);

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  bool _timedOut = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      if (!AppStateService.instance.isReady) {
        setState(() => _timedOut = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _retry() async {
    setState(() => _timedOut = false);
    await AppStateService.instance.ensureInitialized();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // نستمع للخدمة هنا مباشرة.
    // السبب: RootGate يُنشأ كـ const، والـ const canonicalized — فحين يعيد
    // الأب البناء يُعدّ الـ widget "نفسه" ولا يُعاد بناء الشجرة، فلا تنتقل
    // الشاشة بعد تسجيل الدخول إلا بإعادة تشغيل التطبيق.
    return AnimatedBuilder(
      animation: AppStateService.instance,
      builder: (context, _) => _buildGate(context),
    );
  }

  Widget _buildGate(BuildContext context) {
    final state = AppStateService.instance;

    if (state.isReady) {
      return state.isAuthenticated
          ? const LearnerHomeScreen()
          : const LoginScreen();
    }

    if (_timedOut) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'تعذّر تحميل البيانات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  state.startupError ?? 'حدث خطأ غير متوقع أثناء بدء التشغيل.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

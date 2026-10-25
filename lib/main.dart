import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/app_state_service.dart';
import 'core/i18n/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/learner/learner_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OmniLearnApp());
}

class OmniLearnApp extends StatelessWidget {
  const OmniLearnApp({Key? key}) : super(key: key);

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

/// بوابة الإقلاع: تحميل → دخول → التطبيق
class RootGate extends StatelessWidget {
  const RootGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;

    if (!state.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return state.isAuthenticated
        ? const LearnerHomeScreen()
        : const LoginScreen();
  }
}

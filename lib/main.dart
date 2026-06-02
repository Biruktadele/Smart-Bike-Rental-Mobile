import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'core/onboarding/onboarding_service.dart';
import 'core/auth/auth_service.dart';
import 'theme.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smbk/l10n/app_localizations.dart';
import 'core/localization/locale_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('smbkMapStore').manage.create();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: VelocityApp()));
}

class VelocityApp extends ConsumerWidget {
  const VelocityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Velocity',
      debugShowCheckedModeBanner: false,
      theme: velocityLightTheme(),
      darkTheme: velocityDarkTheme(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('am', ''),
      ],
      builder: (context, child) {
        return Builder(
          builder: (innerContext) {
            final brightness = Theme.of(innerContext).brightness;
            // Sync brightness into both static field and reactive provider
            VelocityColors.isDark = (brightness == Brightness.dark);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(brightnessProvider.notifier).update(brightness);
            });
            return child!;
          },
        );
      },
      home: const OnboardingGate(),
    );
  }
}

/// Gates the app - shows onboarding only once, then shows auth screens
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final hasCompleted = await OnboardingService.hasCompletedOnboarding();
    if (!mounted) return;

    if (hasCompleted) {
      // Onboarding completed, check if user is logged in
      _checkLoginStatus();
    } else {
      // Show onboarding for the first time
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => OnboardingScreen(
            onSignup: (context) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const SignupScreen(),
                  transitionsBuilder: (_, anim, _, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
            onLogin: (context) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const LoginScreen(),
                  transitionsBuilder: (_, anim, _, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
          ),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      // User is already logged in, go to home screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const HomeScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // User is not logged in, go to signup screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const SignupScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

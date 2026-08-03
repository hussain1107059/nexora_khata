import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/theme/app_theme.dart';
import 'core/config/theme/app_colors.dart';
import 'core/config/theme/app_typography.dart';
import 'core/router/app_router.dart';
import 'core/services/app_state_scope.dart';
import 'core/services/app_strings.dart';
import 'core/services/database_helper.dart';
import 'core/services/notification_service.dart';
import 'di/injection_container.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'generated/l10n/app_localizations.dart';

final ProviderContainer _appContainer = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppStateScope.bind(_appContainer);

  try {
    await initializeDependencies();
  } catch (e, stack) {
    debugPrint('initializeDependencies FAILED: $e');
    FlutterError.reportError(FlutterErrorDetails(
      exception: e,
      stack: stack,
      context: ErrorDescription('Database initialization failed'),
    ));
  }

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(
    UncontrolledProviderScope(
      container: _appContainer,
      child: const NexoraKhataApp(),
    ),
  );
}

class NexoraKhataApp extends ConsumerWidget {
  const NexoraKhataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Nexora Khata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('bn', 'BD');
      },
      builder: (context, child) {
        AppStrings.current = AppLocalizations.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor:
                isDark ? const Color(0xFF0F1115) : AppColors.white,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
          child: _AppInitializer(child: child),
        );
      },
    );
  }
}

class _AppInitializer extends ConsumerStatefulWidget {
  final Widget? child;
  const _AppInitializer({this.child});

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer>
    with WidgetsBindingObserver {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncNotifications();
    }
  }

  Future<void> _init() async {
    try {
      DatabaseHelper db;
      try {
        db = getIt<DatabaseHelper>();
      } catch (_) {
        db = DatabaseHelper();
        getIt.registerSingleton<DatabaseHelper>(db);
      }
      if (!db.isInitialized) {
        try {
          await db.open();
        } catch (e) {
          _error = 'DB open: $e';
        }
      }
      _initNotifications();
    } catch (e) {
      _error = 'Init: $e';
    }
    if (mounted) {
      if (_error != null) {
        debugPrint('_AppInitializer ERROR: $_error');
      } else {
        setState(() => _ready = true);
      }
    }
  }

  Future<void> _initNotifications() async {
    try {
      final service = getIt<NotificationService>();
      await service.init();
      if (authUserNotifier.value != null) {
        await service.syncSchedules();
      }
    } catch (e) {
      debugPrint('Notification init FAILED: $e');
    }
  }

  Future<void> _syncNotifications() async {
    try {
      if (authUserNotifier.value != null) {
        await getIt<NotificationService>().syncSchedules();
      }
    } catch (e) {
      debugPrint('Notification sync FAILED: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the auth state only once the database is ready, so the session is
    // validated on the splash screen (not before) and the router then goes
    // straight to Dashboard for an authenticated user with no Login flash.
    var authRestoring = false;
    if (_ready) {
      authRestoring = ref.watch(authStateProvider).isLoading;
    }
    if (!_ready || authRestoring) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/NexoraKhata.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.s.appTitle,
                style: AppTypography.heading4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _error!,
                    style: AppTypography.caption.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => _ready = true),
                  child: Text(AppStrings.s.splashContinue),
                ),
              ] else ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return widget.child ?? const SizedBox.shrink();
  }
}

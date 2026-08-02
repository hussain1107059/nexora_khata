import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/theme/app_theme.dart';
import 'core/config/theme/app_colors.dart';
import 'core/config/theme/app_typography.dart';
import 'core/router/app_router.dart';
import 'core/services/database_helper.dart';
import 'di/injection_container.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    const ProviderScope(
      child: NexoraKhataApp(),
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
      supportedLocales: const [
        Locale('bn', 'BD'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('bn', 'BD');
      },
      builder: (context, child) {
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

class _AppInitializerState extends ConsumerState<_AppInitializer> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
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

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'নেক্সোরা খাতা',
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
                  child: const Text('যাইহোক চালু করুন'),
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

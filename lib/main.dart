import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/sync_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/global_notification_listener.dart';
import 'core/services/fcm_service.dart';
import 'features/settings/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.url,
    // ignore: deprecated_member_use
    anonKey: SupabaseConstants.anonKey,
  );

  // Initialize Firebase Core
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(const ProviderScope(child: OmarApp()));
}

class OmarApp extends ConsumerStatefulWidget {
  const OmarApp({super.key});

  @override
  ConsumerState<OmarApp> createState() => _OmarAppState();
}

class _OmarAppState extends ConsumerState<OmarApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize notification service & permissions once
      ref.read(notificationTapHandlerProvider).initialize();

      // Initialize global notification listener once
      ref.read(globalNotificationListenerProvider);

      // Initialize Firebase Cloud Messaging (FCM) once
      ref.read(fcmServiceProvider).initialize();

      // Start sync service once
      ref.read(syncServiceProvider).startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SAMI MARKET',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Localization
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Routing
      onGenerateRoute: AppRouter.generateRoute,
      home: const AuthWrapper(),
    );
  }
}

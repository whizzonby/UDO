import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'shared/widgets/app_scaffold_messenger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final dsn = AppConstants.sentryDsn;
  if (dsn.isEmpty) {
    runApp(const ProviderScope(child: UdoApp()));
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(const ProviderScope(child: UdoApp())),
  );
}

class UdoApp extends ConsumerWidget {
  const UdoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.read(apiClientProvider).onUnauthorized = () => ref.read(authProvider.notifier).forceLogout();
    ref.read(apiClientProvider).onLimitReached =
        (message) => router.push('/paywall', extra: message);
    return MaterialApp.router(
      title: 'Udo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      routerConfig: router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';

void main() {
  runApp(const ProviderScope(child: PacePulseApp()));
}

class PacePulseApp extends ConsumerWidget {
  const PacePulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PacePulse',
      theme: ppLightTheme(),
      darkTheme: ppDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

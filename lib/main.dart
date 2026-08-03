import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'core/theme/theme.dart';
import 'dev/gallery/gallery.dart';

void main() {
  runApp(const PacePulseApp());
}

class PacePulseApp extends StatelessWidget {
  const PacePulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PacePulse',
      theme: ppLightTheme(),
      darkTheme: ppDarkTheme(),
      themeMode: ThemeMode.dark, // dark is the brand default
      home: const _BootScreen(),
    );
  }
}

/// Temporary home until the router lands (the Flow 5 splash owns this spot).
class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PacePulse', style: theme.textTheme.headlineLarge),
            const SizedBox(height: PPSpacing.s2),
            Text(
              'Theme wired — token showcase next',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: pp.onSurfaceFaint),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: PPSpacing.s6),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const GalleryScreen()),
                ),
                child: const Text('Open component gallery'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

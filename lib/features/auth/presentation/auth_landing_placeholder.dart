import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../dev/gallery/gallery.dart';

class AuthLandingPlaceholder extends StatelessWidget {
  const AuthLandingPlaceholder({super.key});

  static const path = '/auth';

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
              'Sign-in arrives with the auth slice',
              style: theme.textTheme.bodySmall?.copyWith(
                color: pp.onSurfaceFaint,
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: PPSpacing.s6),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GalleryScreen(),
                  ),
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

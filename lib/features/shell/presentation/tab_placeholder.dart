import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(PPSpacing.padScreen),
            child: Text(
              '$title — coming',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
}

abstract final class HistoryScreen {
  static const path = '/history';
  static const title = 'History';
}

abstract final class ChallengesScreen {
  static const path = '/challenges';
  static const title = 'Challenges';
}

abstract final class ProfileScreen {
  static const path = '/profile';
  static const title = 'Profile';
}

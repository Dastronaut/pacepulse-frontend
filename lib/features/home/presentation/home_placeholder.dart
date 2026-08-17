import 'package:flutter/material.dart';

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  static const path = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Home — Flow 1 coming',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

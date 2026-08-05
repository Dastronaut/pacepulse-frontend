import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'pages/actions_page.dart';
import 'pages/data_page.dart';
import 'pages/foundations_page.dart';
import 'pages/inputs_page.dart';
import 'pages/status_page.dart';

export 'pages/foundations_page.dart';

/// Debug-only component gallery. Pages are registered per family as the
/// kit grows; ordering mirrors the D1 sheet.
final Map<String, WidgetBuilder> galleryPages = {
  'Foundations': (_) => const FoundationsGalleryPage(),
  'Actions': (_) => const ActionsGalleryPage(),
  'Status': (_) => const StatusGalleryPage(),
  'Data': (_) => const DataGalleryPage(),
  'Inputs': (_) => const InputsGalleryPage(),
};

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _dark = true;
  bool _reducedMotion = false;
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final page = _selected;
    return Theme(
      data: _dark ? ppDarkTheme() : ppLightTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(page ?? 'PacePulse gallery'),
          leading: page == null
              ? null
              : BackButton(onPressed: () => setState(() => _selected = null)),
          actions: [
            IconButton(
              tooltip: 'Toggle theme',
              icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _dark = !_dark),
            ),
            IconButton(
              tooltip: 'Toggle reduced motion',
              icon: Icon(_reducedMotion
                  ? Icons.motion_photos_off
                  : Icons.motion_photos_on),
              onPressed: () =>
                  setState(() => _reducedMotion = !_reducedMotion),
            ),
          ],
        ),
        body: page == null
            ? ListView(
                children: [
                  for (final name in galleryPages.keys)
                    ListTile(
                      title: Text(name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => setState(() => _selected = name),
                    ),
                ],
              )
            : GalleryFrame(
                dark: _dark,
                reducedMotion: _reducedMotion,
                child: Builder(builder: galleryPages[page]!),
              ),
      ),
    );
  }
}

/// Applies theme + reduced-motion to a gallery page's subtree.
class GalleryFrame extends StatelessWidget {
  const GalleryFrame({
    super.key,
    required this.dark,
    required this.reducedMotion,
    required this.child,
  });

  final bool dark;
  final bool reducedMotion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: dark ? ppDarkTheme() : ppLightTheme(),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
        child: ColoredBox(
          color: dark
              ? ppDarkColorScheme.surface
              : ppLightColorScheme.surface,
          child: child,
        ),
      ),
    );
  }
}

/// Titled block used by every gallery page.
class GallerySection extends StatelessWidget {
  const GallerySection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          PPSpacing.padScreen, PPSpacing.s4, PPSpacing.padScreen, PPSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: theme.textTheme.labelSmall),
          const SizedBox(height: PPSpacing.s3),
          child,
        ],
      ),
    );
  }
}

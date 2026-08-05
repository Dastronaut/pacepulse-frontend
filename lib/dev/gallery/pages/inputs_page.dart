import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../gallery.dart';

class InputsGalleryPage extends StatefulWidget {
  const InputsGalleryPage({super.key});

  @override
  State<InputsGalleryPage> createState() => _InputsGalleryPageState();
}

class _InputsGalleryPageState extends State<InputsGalleryPage> {
  final TextEditingController _defaultController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _errorController = TextEditingController();

  @override
  void dispose() {
    _defaultController.dispose();
    _hintController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GallerySection(
          title: 'PPTextField - Default',
          child: Column(
            spacing: PPSpacing.s3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PPTextField(
                label: 'Email',
                controller: _defaultController,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'PPTextField - With Hint',
          child: Column(
            spacing: PPSpacing.s3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PPTextField(
                label: 'Username',
                controller: _hintController,
                hint: 'Enter your username',
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'PPTextField - Error State',
          child: Column(
            spacing: PPSpacing.s3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PPTextField(
                label: 'Password',
                controller: _errorController,
                errorText: 'At least 8 characters — add a few more.',
                obscureText: true,
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'PPTextField - Disabled',
          child: Column(
            spacing: PPSpacing.s3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PPTextField(
                label: 'Locked Field',
                enabled: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

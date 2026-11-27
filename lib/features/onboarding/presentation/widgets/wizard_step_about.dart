import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/profile_draft.dart';
import '../wizard_controller.dart';
import 'wizard_field_label.dart';
import 'wizard_step_scaffold.dart';

class WizardStepAbout extends ConsumerStatefulWidget {
  const WizardStepAbout({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<WizardStepAbout> createState() => _WizardStepAboutState();
}

class _WizardStepAboutState extends ConsumerState<WizardStepAbout> {
  late final TextEditingController _name;
  late final TextEditingController _birthYear;

  static const _bodyOptions = [
    WizardCopy.bodyFemale,
    WizardCopy.bodyMale,
    WizardCopy.bodyUnspecified,
  ];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(wizardControllerProvider).draft;
    _name = TextEditingController(text: draft.name);
    _birthYear = TextEditingController(text: draft.birthYear?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _birthYear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(wizardControllerProvider).draft;
    final notifier = ref.read(wizardControllerProvider.notifier);

    return WizardStepScaffold(
      overline: WizardCopy.step1Overline,
      title: WizardCopy.step1Title,
      body: WizardCopy.step1Body,
      fields: [
        PPTextField(
          label: WizardCopy.nameLabel,
          controller: _name,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.givenName],
          onChanged: notifier.nameChanged,
        ),
        PPTextField(
          label: WizardCopy.birthYearLabel,
          controller: _birthYear,
          keyboardType: TextInputType.number,
          tabularFigures: true,
          textInputAction: TextInputAction.done,
          onChanged: notifier.birthYearChanged,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardFieldLabel(text: WizardCopy.bodyLabel),
            const SizedBox(height: PPSpacing.s2),
            PPChoicePills(
              options: _bodyOptions,
              selectedIndex: draft.body?.index,
              onChanged: (i) => notifier.bodyChanged(BodyOption.values[i]),
            ),
          ],
        ),
      ],
      footer: PPButton(
        key: const Key('wizard_step1_continue'),
        label: WizardCopy.continueLabel,
        size: PPButtonSize.lg,
        fullWidth: true,
        onPressed: widget.onContinue,
      ),
    );
  }
}

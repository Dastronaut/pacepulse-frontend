import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Text input (D1-C1). Focus and selection borders grow 1px -> 2px; the
/// horizontal content padding shrinks 16 -> 14 in compensation so the
/// text never shifts.
class PPTextField extends StatefulWidget {
  const PPTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  State<PPTextField> createState() => _PPTextFieldState();
}

class _PPTextFieldState extends State<PPTextField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus;

    final borderColor = hasError
        ? scheme.error
        : focused
            ? pp.accentText
            : scheme.outline;
    final borderWidth =
        (hasError || focused) ? PPBorders.strong : PPBorders.hairline;
    final hPad = (hasError || focused) ? 14.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium!.copyWith(
            color: focused && !hasError
                ? pp.accentText
                : scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: PPSpacing.s2),
        AnimatedContainer(
          key: const Key('pp_field_box'),
          duration: PPMotion.instant,
          height: 52,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          decoration: BoxDecoration(
            color: !widget.enabled
                ? scheme.outlineVariant
                : dark
                    ? scheme.surfaceContainer
                    : scheme.surface,
            borderRadius: BorderRadius.circular(PPRadius.sm),
            border: widget.enabled
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
          ),
          child: Center(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              cursorColor: pp.accentText,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: widget.enabled
                    ? scheme.onSurface
                    : pp.onSurfaceDisabled,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: theme.textTheme.bodyMedium!
                    .copyWith(color: pp.onSurfaceFaint),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: PPSpacing.s2),
          Text(
            widget.errorText!,
            style:
                theme.textTheme.labelMedium!.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
  }
}

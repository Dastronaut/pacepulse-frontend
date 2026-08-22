import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Text input (D1-C1). Focus and selection borders grow 1px -> 2px; the
/// horizontal content padding shrinks to maintain constant 16 effective inset
/// (padding = 16 − border width; Container merges border dimensions into padding).
/// Dark theme fields at rest are borderless (D1-C1 spec); light theme fields
/// keep hairline outline. Effective horizontal inset is constant 16 across all
/// states — zero content shift on focus/error.
/// (h 52, constant 16 inset; human ruling 2026-08-03: spec literals with documented provenance)
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
    this.helperText,
    this.trailing,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  final String? helperText;

  final Widget? trailing;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  @override
  State<PPTextField> createState() => _PPTextFieldState();
}

class _PPTextFieldState extends State<PPTextField> {
  FocusNode? _ownedFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownedFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void didUpdateWidget(PPTextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownedFocus)?.removeListener(_onFocusChange);
      _focus.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _ownedFocus?.dispose();
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
    final double borderWidth = !widget.enabled
        ? 0
        : (hasError || focused)
        ? PPBorders
              .strong // 2
        : dark
        ? 0 // D1-C1: dark rest = filled, no border
        : PPBorders.hairline; // 1 (light rest keeps hairline outline)
    final border = borderWidth == 0
        ? null
        : Border.all(color: borderColor, width: borderWidth);
    final hPad = 16.0 - borderWidth; // effective inset always 16 — zero shift

    // The visible label is a sibling Text, not a semantic label owner, so
    // the collapsed TextField exposes no accessible name on its own.
    // Wrapping the field in a plain Semantics(label:) (no container/merge
    // overrides) attaches the name without shadowing the inner TextField's
    // own editable-value node (final-review finding #3). Errors are
    // appended so they're announced alongside the field's name.
    return Semantics(
      label: hasError ? '${widget.label}, ${widget.errorText}' : widget.label,
      child: Column(
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
              border: border,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focus,
                      enabled: widget.enabled,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      onSubmitted: widget.onSubmitted,
                      autofillHints: widget.autofillHints,
                      onChanged: widget.onChanged,
                      cursorColor: pp.accentText,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: widget.enabled
                            ? scheme.onSurface
                            : pp.onSurfaceDisabled,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: theme.textTheme.bodyMedium!.copyWith(
                          color: pp.onSurfaceFaint,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
          if (hasError || widget.helperText != null) ...[
            const SizedBox(height: PPSpacing.s2),
            Text(
              hasError ? widget.errorText! : widget.helperText!,
              style: theme.textTheme.labelMedium!.copyWith(
                color: hasError ? scheme.error : pp.onSurfaceFaint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

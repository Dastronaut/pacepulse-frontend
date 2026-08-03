import 'package:flutter/widgets.dart';

/// Single switch every hero animation consults. Static fallbacks are
/// specced per component (movement -> static emphasis).
bool ppReducedMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

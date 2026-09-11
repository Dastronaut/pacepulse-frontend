import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Online/offline for the whole app. The stub always reports online; the real
/// detector lands with Flow 2, where a request can actually fail.
// TODO(flow2): back this with connectivity_plus once a real request exists.
final connectivityProvider = StreamProvider<bool>(
  (ref) => Stream<bool>.value(true),
);

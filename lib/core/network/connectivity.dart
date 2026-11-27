import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity.g.dart';

/// Online/offline for the whole app. The stub always reports online; the real
/// detector lands with Flow 2, where a request can actually fail.
// TODO(flow2): back this with connectivity_plus once a real request exists.
@Riverpod(keepAlive: true)
Stream<bool> connectivity(Ref ref) => Stream<bool>.value(true);

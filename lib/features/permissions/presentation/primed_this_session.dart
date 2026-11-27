import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/permission_kind.dart';

part 'primed_this_session.g.dart';

@Riverpod(keepAlive: true)
class PrimedThisSession extends _$PrimedThisSession {
  @override
  Set<PermissionKind> build() => const {};

  void mark(PermissionKind kind) => state = {...state, kind};
}

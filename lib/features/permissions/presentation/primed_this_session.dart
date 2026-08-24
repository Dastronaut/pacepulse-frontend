import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/permission_kind.dart';

class PrimedThisSession extends Notifier<Set<PermissionKind>> {
  @override
  Set<PermissionKind> build() => const {};

  void mark(PermissionKind kind) => state = {...state, kind};
}

final primedThisSessionProvider =
    NotifierProvider<PrimedThisSession, Set<PermissionKind>>(
      PrimedThisSession.new,
    );

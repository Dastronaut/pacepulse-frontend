import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/features/home/data/stub_home_repository.dart';
import 'package:pacepulse/features/home/domain/home_repository.dart';
import 'package:pacepulse/features/home/domain/home_summary.dart';
import 'package:pacepulse/features/home/presentation/home_controller.dart';

ProviderContainer containerWith(HomeRepository repo) {
  final container = ProviderContainer.test(
    overrides: <dynamic>[
      homeRepositoryProvider.overrideWithValue(repo),
    ].cast(),
  );
  return container;
}

/// Succeeds on its first call (so `build()` always gets data) and throws
/// [nextThrows] on any later call — the only way to get "first load
/// succeeds, then refresh fails" out of a repository, since a repo that
/// fails at construction also fails the initial load.
class _FlakyRepository implements HomeRepository {
  _FlakyRepository(this._summary);

  final HomeSummary _summary;
  var calls = 0;
  Object? nextThrows;

  @override
  Future<HomeSummary> load() async {
    calls++;
    if (calls > 1 && nextThrows != null) {
      final error = nextThrows!;
      nextThrows = null;
      throw error;
    }
    return _summary;
  }
}

void main() {
  test('a successful load lands in data', () async {
    final container =
        containerWith(const StubHomeRepository(latency: Duration.zero));

    expect(container.read(homeControllerProvider).isLoading, isTrue);
    final summary = await container.read(homeControllerProvider.future);

    expect(summary.displayName, 'Dana');
    expect(summary.initials, 'DN');
    expect(container.read(homeControllerProvider).hasValue, isTrue);
  });

  test('a failing load lands in error', () async {
    final container = containerWith(
      StubHomeRepository(latency: Duration.zero, failWith: StateError('boom')),
    );

    await expectLater(
      container.read(homeControllerProvider.future),
      throwsStateError,
    );
    expect(container.read(homeControllerProvider).hasError, isTrue);
  });

  test('an initial load slower than the timeout becomes an error', () async {
    final container = containerWith(
      const StubHomeRepository(latency: Duration(seconds: 30)),
    );

    await expectLater(
      container.read(homeControllerProvider.future),
      throwsA(isA<TimeoutException>()),
    );
  }, timeout: const Timeout(Duration(seconds: 10)));

  test('a failed refresh keeps the data already on screen', () async {
    final repo = _FlakyRepository(StubHomeFixtures.populated);
    final container = containerWith(repo);
    await container.read(homeControllerProvider.future);

    final controller = container.read(homeControllerProvider.notifier);
    repo.nextThrows = StateError('refresh failed');

    await controller.refresh();

    final state = container.read(homeControllerProvider);
    expect(state.hasValue, isTrue,
        reason: 'a failed refresh must not blank the dashboard');
    expect(state.value!.displayName, 'Dana');
    expect(controller.lastRefreshError, isA<StateError>());
  });

  test('a successful refresh replaces the summary', () async {
    final container = containerWith(
      const StubHomeRepository(latency: Duration.zero),
    );
    await container.read(homeControllerProvider.future);

    await container.read(homeControllerProvider.notifier).refresh();

    expect(container.read(homeControllerProvider).hasValue, isTrue);
    expect(container.read(homeControllerProvider).value, isA<HomeSummary>());
  });
}

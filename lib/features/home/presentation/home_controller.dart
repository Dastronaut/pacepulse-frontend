import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/stub_home_repository.dart';
import '../domain/home_summary.dart';

final homeControllerProvider =
    AsyncNotifierProvider.autoDispose<HomeController, HomeSummary>(
      HomeController.new,
    );

class HomeController extends AsyncNotifier<HomeSummary> {
  static const initialTimeout = Duration(seconds: 3);

  Object? lastRefreshError;

  @override
  Future<HomeSummary> build() =>
      ref.read(homeRepositoryProvider).load().timeout(initialTimeout);

  Future<void> refresh() async {
    final link = ref.keepAlive();
    try {
      final summary = await ref.read(homeRepositoryProvider).load();
      lastRefreshError = null;
      state = AsyncData(summary);
    } catch (error) {
      lastRefreshError = error;
    } finally {
      link.close();
    }
  }
}

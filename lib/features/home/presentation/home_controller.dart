import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/stub_home_repository.dart';
import '../domain/home_summary.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
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

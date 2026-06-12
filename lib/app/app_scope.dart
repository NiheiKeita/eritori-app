import 'package:flutter/widgets.dart';

import '../data/repositories/eri_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../state/progress_controller.dart';

/// アプリ全体の依存性を配布する InheritedWidget（既存規約: コンストラクタ注入）。
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.progressRepository,
    required this.progressController,
    required this.eriRepository,
    required super.child,
  });

  final ProgressRepository progressRepository;
  final ProgressController progressController;
  final EriRepository eriRepository;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) =>
      progressRepository != oldWidget.progressRepository ||
      progressController != oldWidget.progressController ||
      eriRepository != oldWidget.eriRepository;
}

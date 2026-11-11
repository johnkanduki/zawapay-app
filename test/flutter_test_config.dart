import 'dart:async';

import 'test_data.dart';

/// Every test starts with the test-only accounts loaded.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  useTestAccounts();
  await testMain();
}

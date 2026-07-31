import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionProvider = Provider<AsyncValue<void>>((ref) {
  return const AsyncData(null);
});

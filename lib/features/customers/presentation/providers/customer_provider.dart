import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerProvider = Provider<AsyncValue<void>>((ref) {
  return const AsyncData(null);
});

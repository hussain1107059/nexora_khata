import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/dashboard/domain/entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardSummary>> getDashboardSummary();
}

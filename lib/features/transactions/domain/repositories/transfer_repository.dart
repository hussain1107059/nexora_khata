import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/transactions/domain/entities/transfer.dart';

abstract class TransferRepository {
  Future<Either<Failure, List<Transfer>>> getAll();

  Future<Either<Failure, Transfer>> create(Transfer transfer);

  Future<Either<Failure, void>> delete(int id);
}

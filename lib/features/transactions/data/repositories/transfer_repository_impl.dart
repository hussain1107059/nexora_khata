import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transfer_datasource.dart';
import 'package:nexora_khata/features/transactions/data/models/transfer_model.dart';
import 'package:nexora_khata/features/transactions/domain/entities/transfer.dart';
import 'package:nexora_khata/features/transactions/domain/repositories/transfer_repository.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferDataSource dataSource;

  TransferRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Transfer>>> getAll() async {
    try {
      final models = await dataSource.getAll();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transfer>> create(Transfer transfer) async {
    try {
      final model = TransferModel(
        id: 0,
        businessId: transfer.businessId,
        fromType: transfer.fromType,
        fromCashAccountId: transfer.fromCashAccountId,
        fromBankAccountId: transfer.fromBankAccountId,
        toType: transfer.toType,
        toCashAccountId: transfer.toCashAccountId,
        toBankAccountId: transfer.toBankAccountId,
        amount: transfer.amount,
        description: transfer.description,
        reference: transfer.reference,
        transferDate: transfer.transferDate,
        fee: transfer.fee,
        status: transfer.status,
        createdAt: transfer.createdAt,
        updatedAt: transfer.updatedAt,
      );
      final created = await dataSource.create(model.toMap());
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await dataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

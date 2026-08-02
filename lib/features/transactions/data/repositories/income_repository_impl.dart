import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';
import 'package:nexora_khata/features/transactions/data/repositories/transaction_repository_base.dart';
import 'package:nexora_khata/features/transactions/domain/entities/income.dart';
import 'package:nexora_khata/features/transactions/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl extends TransactionRepositoryBase<IncomeModel>
    implements IncomeRepository {
  IncomeRepositoryImpl(super.dataSource);

  @override
  Future<Either<Failure, Income>> create(Income income) async {
    try {
      final model = IncomeModel(
        id: 0,
        businessId: income.businessId,
        customerId: income.customerId,
        cashAccountId: income.cashAccountId,
        bankAccountId: income.bankAccountId,
        categoryId: income.categoryId,
        amount: income.amount,
        description: income.description,
        reference: income.reference,
        imagePath: income.imagePath,
        incomeDate: income.incomeDate,
        paymentMethod: income.paymentMethod,
        isRecurring: income.isRecurring,
        status: income.status,
        createdAt: income.createdAt,
        updatedAt: income.updatedAt,
      );
      final created = await dataSource.create(model.toMap());
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Income>> update(Income income) async {
    try {
      final model = IncomeModel(
        id: income.id,
        businessId: income.businessId,
        customerId: income.customerId,
        cashAccountId: income.cashAccountId,
        bankAccountId: income.bankAccountId,
        categoryId: income.categoryId,
        amount: income.amount,
        description: income.description,
        reference: income.reference,
        imagePath: income.imagePath,
        incomeDate: income.incomeDate,
        paymentMethod: income.paymentMethod,
        isRecurring: income.isRecurring,
        status: income.status,
        createdAt: income.createdAt,
        updatedAt: income.updatedAt,
      );
      final updated = await dataSource.update(income.id, model.toMap());
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

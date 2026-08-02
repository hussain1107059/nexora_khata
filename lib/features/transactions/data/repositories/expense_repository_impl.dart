import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';
import 'package:nexora_khata/features/transactions/data/repositories/transaction_repository_base.dart';
import 'package:nexora_khata/features/transactions/domain/entities/expense.dart';
import 'package:nexora_khata/features/transactions/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl extends TransactionRepositoryBase<ExpenseModel>
    implements ExpenseRepository {
  ExpenseRepositoryImpl(super.dataSource);

  @override
  Future<Either<Failure, Expense>> create(Expense expense) async {
    try {
      final model = ExpenseModel(
        id: 0,
        businessId: expense.businessId,
        supplierId: expense.supplierId,
        cashAccountId: expense.cashAccountId,
        bankAccountId: expense.bankAccountId,
        categoryId: expense.categoryId,
        amount: expense.amount,
        description: expense.description,
        reference: expense.reference,
        imagePath: expense.imagePath,
        expenseDate: expense.expenseDate,
        paymentMethod: expense.paymentMethod,
        isRecurring: expense.isRecurring,
        status: expense.status,
        createdAt: expense.createdAt,
        updatedAt: expense.updatedAt,
      );
      final created = await dataSource.create(model.toMap());
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> update(Expense expense) async {
    try {
      final model = ExpenseModel(
        id: expense.id,
        businessId: expense.businessId,
        supplierId: expense.supplierId,
        cashAccountId: expense.cashAccountId,
        bankAccountId: expense.bankAccountId,
        categoryId: expense.categoryId,
        amount: expense.amount,
        description: expense.description,
        reference: expense.reference,
        imagePath: expense.imagePath,
        expenseDate: expense.expenseDate,
        paymentMethod: expense.paymentMethod,
        isRecurring: expense.isRecurring,
        status: expense.status,
        createdAt: expense.createdAt,
        updatedAt: expense.updatedAt,
      );
      final updated = await dataSource.update(expense.id, model.toMap());
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

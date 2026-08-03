import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/loans/data/datasources/loan_datasource.dart';
import 'package:nexora_khata/features/loans/data/models/loan_contact_model.dart';
import 'package:nexora_khata/features/loans/data/models/loan_transaction_model.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_contact.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_transaction.dart';
import 'package:nexora_khata/features/loans/domain/repositories/loan_repository.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanDataSource dataSource;

  LoanRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<LoanContact>>> getContacts() async {
    try {
      final models = await dataSource.getContacts();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoanContact?>> getContact(int id) async {
    try {
      final model = await dataSource.getContact(id);
      return Right(model);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoanContact>> createContact(LoanContact contact) async {
    try {
      final model = LoanContactModel(
        id: 0,
        businessId: contact.businessId,
        name: contact.name,
        phone: contact.phone,
        note: contact.note,
        createdAt: contact.createdAt,
        updatedAt: contact.updatedAt,
      );
      final created = await dataSource.createContact(model.toMap());
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoanContact>> updateContact(LoanContact contact) async {
    try {
      final model = LoanContactModel(
        id: contact.id,
        businessId: contact.businessId,
        name: contact.name,
        phone: contact.phone,
        note: contact.note,
        createdAt: contact.createdAt,
        updatedAt: contact.updatedAt,
      );
      final updated = await dataSource.updateContact(contact.id, model.toMap());
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContact(int id) async {
    try {
      await dataSource.deleteContact(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LoanTransaction>>> getTransactions(
    int contactId,
  ) async {
    try {
      final models = await dataSource.getTransactions(contactId);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LoanTransaction>>> getAllTransactions() async {
    try {
      final models = await dataSource.getAllTransactions();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoanTransaction>> createTransaction(
    LoanTransaction transaction,
  ) async {
    try {
      final model = LoanTransactionModel(
        id: 0,
        businessId: transaction.businessId,
        contactId: transaction.contactId,
        type: transaction.type,
        repayType: transaction.repayType,
        amount: transaction.amount,
        date: transaction.date,
        note: transaction.note,
        paymentMethod: transaction.paymentMethod,
        cashAccountId: transaction.cashAccountId,
        bankAccountId: transaction.bankAccountId,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
      );
      final created = await dataSource.createTransaction(model.toMap());
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoanTransaction>> updateTransaction(
    LoanTransaction transaction,
  ) async {
    try {
      final model = LoanTransactionModel(
        id: transaction.id,
        businessId: transaction.businessId,
        contactId: transaction.contactId,
        type: transaction.type,
        repayType: transaction.repayType,
        amount: transaction.amount,
        date: transaction.date,
        note: transaction.note,
        paymentMethod: transaction.paymentMethod,
        cashAccountId: transaction.cashAccountId,
        bankAccountId: transaction.bankAccountId,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
      );
      final updated = await dataSource.updateTransaction(
        transaction.id,
        model.toMap(),
      );
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(int id) async {
    try {
      await dataSource.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

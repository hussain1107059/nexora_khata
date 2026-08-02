import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_contact.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_transaction.dart';

abstract class LoanRepository {
  Future<Either<Failure, List<LoanContact>>> getContacts();

  Future<Either<Failure, LoanContact?>> getContact(int id);

  Future<Either<Failure, LoanContact>> createContact(LoanContact contact);

  Future<Either<Failure, LoanContact>> updateContact(LoanContact contact);

  Future<Either<Failure, void>> deleteContact(int id);

  Future<Either<Failure, List<LoanTransaction>>> getTransactions(int contactId);

  Future<Either<Failure, List<LoanTransaction>>> getAllTransactions();

  Future<Either<Failure, LoanTransaction>> createTransaction(
    LoanTransaction transaction,
  );

  Future<Either<Failure, void>> deleteTransaction(int id);
}

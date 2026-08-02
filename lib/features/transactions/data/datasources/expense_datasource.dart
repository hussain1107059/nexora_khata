import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transaction_datasource.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';

class ExpenseDataSource extends TransactionDataSource<ExpenseModel> {
  ExpenseDataSource(DatabaseHelper dbHelper)
      : super(
          dbHelper,
          const TransactionTableConfig<ExpenseModel>(
            table: 'expenses',
            alias: 'e',
            dateColumn: 'expense_date',
            categoryTable: 'expense_categories',
            categoryAlias: 'ec',
            partnerTable: 'suppliers',
            partnerAlias: 's',
            partnerColumn: 'supplier_id',
            partnerNameColumn: 'supplier_name',
            fromMap: ExpenseModel.fromMap,
          ),
        );
}

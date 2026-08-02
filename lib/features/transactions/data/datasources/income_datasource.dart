import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transaction_datasource.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';

class IncomeDataSource extends TransactionDataSource<IncomeModel> {
  IncomeDataSource(DatabaseHelper dbHelper)
      : super(
          dbHelper,
          const TransactionTableConfig<IncomeModel>(
            table: 'incomes',
            alias: 'i',
            dateColumn: 'income_date',
            categoryTable: 'income_categories',
            categoryAlias: 'ic',
            partnerTable: 'customers',
            partnerAlias: 'c',
            partnerColumn: 'customer_id',
            partnerNameColumn: 'customer_name',
            fromMap: IncomeModel.fromMap,
          ),
        );
}

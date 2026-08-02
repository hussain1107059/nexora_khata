# AGENTS.md

## Architecture conventions

- **State management**: Riverpod plain providers (no codegen). `StateNotifierProvider` for forms, `FutureProvider` for reads, `StateProvider` for filters.
- **DI**: `get_it` singletons registered in `lib/di/injection_container.dart`; providers read them via `getIt<T>()`.
- **Layering**: `presentation` (pages/widgets/providers) → `domain` (entities/repositories) → `data` (datasources/repositories/models). No usecases layer — providers call repositories directly, consistently across all features. Do not introduce a usecases layer.
- **Data access**: `DatabaseHelper` (raw sqflite). Shared generic `TransactionDataSource<T>` + `TransactionRepositoryBase<T>` in `lib/features/transactions/data/` cover income/expense list, filters, search, month summaries, and CRUD. New transaction queries should reuse these before adding raw SQL.
- **Shared widgets**: prefer `lib/core/widgets/` (e.g. `CoreCard`, `AppTextField`, `AppSearchField`) and `lib/features/transactions/presentation/widgets/` (e.g. `TransactionCard`, `TransactionFilterBar`, `TransactionDetailView`, `TransactionFormFields`, `TransactionCategoriesPage`). Keep income/expense pages thin wrappers.
- **CSV/export**: use `CsvExportService` (`lib/core/services/csv_export_service.dart`) instead of duplicating share_plus/path_provider logic.
- **Logging**: use `log` from `lib/core/services/logger.dart` (package:logger). No `print()`.

## Verification

- `flutter analyze` is the compile check (JAVA_HOME is not set on this machine, so `flutter build apk` fails; `flutter test` only runs placeholder `test/widget_test.dart`).
- Keep analyzer at 0 errors / 0 warnings.

## Bengali text

Do not edit Bengali strings via PowerShell string replacement (encoding silently corrupts). Use the edit tool.

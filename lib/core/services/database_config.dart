abstract final class DatabaseConfig {
  DatabaseConfig._();

  static const String dbName = 'nexora_khata.db';
  static const int dbVersion = 10;

  static const bool foreignKeys = true;
  static const String journalMode = 'WAL';
  static const String synchronous = 'NORMAL';
  static const int cacheSize = -64000;
  static const int busyTimeout = 5000;

  static const int pageSize = 20;
  static const int batchSize = 500;
}

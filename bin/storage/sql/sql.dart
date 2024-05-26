import 'package:postgres/postgres.dart';
class PostgresSettings {
  // 1 : Docker dan postgres yuklab olinadi
  // 2 : docker-compose.yml to'g'rilanadi
  // 3 : docker-compose up -d ishga tushuriladi
  // 4 : localhost dan adminerga kirib  postgresga ulanib ko'riladi
  // 5 : va ko'd orqali tekshiriladi

  late final Connection _connection;

  PostgresSettings._();

  factory PostgresSettings() => _instance;

  static final _instance = PostgresSettings._();

  Future<void> init() async {
    _connection = await Connection.open(
      Endpoint(
        host: "185.251.90.108",
        port: 5432,
        database: "dart",
        username: "postgres",
        password: "dart",
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  bool get isConnected => _connection.isOpen;

  void close() async {
    await _connection.close();
  }

  Future<Result> execute(
    Object query, {
    Object? parameters,
    bool ignoreRows = false,
    QueryMode? queryMode,
    Duration? timeout,
  }) async {
    if(_connection.isOpen) {
      return _connection.execute(
        query,
        parameters: parameters,
        ignoreRows: ignoreRows,
        queryMode: queryMode,
        timeout: timeout,
      );
    }else {
      await init();
      return _connection.execute(
        query,
        parameters: parameters,
        ignoreRows: ignoreRows,
        queryMode: queryMode,
        timeout: timeout,
      );
    }
  }
}

import 'package:postgres/postgres.dart';

class PostgresSettings {
  // 1 : Docker dan postgres yuklab olinadi
  // 2 : docker-compose.yml to'g'rilanadi
  // 3 : docker-compose up -d ishga tushuriladi
  // 4 : localhost dan adminerga kirib  postgresga ulanib ko'riladi
  // 5 : va ko'd orqali tekshiriladi

  static late Connection _connection;

  PostgresSettings._();

  factory PostgresSettings() => _instance;

  static final _instance = PostgresSettings._();

  Future<void> init() async {

    print("Connecting... SQL SERVER");
    _connection = await Connection.open(
      Endpoint(
        host: "192.168.0.11",
        // host: "82.215.78.34",
        port: 25060,
        // port: 63219,
        database: "tg_bot",
        username: "tg_bot",
        password: "GreenL1gh7",
      ),
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
        queryTimeout: Duration(minutes: 1),
        connectTimeout: Duration(minutes: 1),
      ),
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
    try {
      if (_connection.isOpen) {
        final qy = await _connection.prepare(query);
        return qy.run(parameters, timeout: Duration(minutes: 1));
      } else {
        print("Connection Closing...");
        await _connection.close();
        print("Connection Closed...");
        await Future.delayed(Duration(seconds: 2));
        print("Reconnecting...");
        await init();
        return _connection.execute(
          query,
          parameters: parameters,
          ignoreRows: ignoreRows,
          queryMode: queryMode,
          timeout: Duration(minutes: 1),
        );
      }
    } catch (e, s) {
      print("Sql Excute Qila olmadi Nimadir hatolik ketti ko'rib chiqish zarur !");
      print(e);
      print(s);
      return Result(rows: [], affectedRows: 0, schema: ResultSchema([]));
    }
  }
}


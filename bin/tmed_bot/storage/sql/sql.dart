import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

final env = DotEnv(includePlatformEnvironment: true)..load();

class PostgresSettings {
  // 1 : Docker dan postgres yuklab olinadi
  // 2 : docker-compose.yml to'g'rilanadi
  // 3 : docker-compose up -d ishga tushuriladi
  // 4 : localhost dan adminerga kirib  postgresga ulanib ko'riladi
  // 5 : va ko'd orqali tekshiriladi

  static Connection? _connection;
  static bool _isConnecting = false;

  PostgresSettings._();

  factory PostgresSettings() => _instance;

  static final _instance = PostgresSettings._();

  /// Database ulanishini yaratish (retry bilan)
  Future<void> init() async {
    if (_connection != null && _connection!.isOpen) {
      print("✅ Database allaqachon ulangan");
      return;
    }

    const maxRetries = 5;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        print("🔄 Database ulanish urinish [${retryCount + 1}/$maxRetries]...");
        print("   Host: ${env['db_host'] ?? '0.0.0.0'}");
        print("   Port: ${env['db_port'] ?? '5432'}");
        print("   Database: ${env['db_database'] ?? 'tg_bot'}");

        _connection = await Connection.open(
          Endpoint(
            host: env['db_host'] ?? "0.0.0.0",
            port: int.tryParse(env['db_port'] ?? '5432') ?? 5432,
            database: env['db_database'] ?? "tg_bot",
            username: env['db_username'] ?? "app_user",
            password: env['db_password'] ?? "",
          ),
          settings: ConnectionSettings(
            sslMode: SslMode.disable,
            queryTimeout: Duration(seconds: 30),
            connectTimeout: Duration(seconds: 30),
          ),
        );

        print("✅ Database muvaffaqiyatli ulandi!");
        return;

      } catch (e, s) {
        retryCount++;
        print("❌ Database ulanish xatosi [$retryCount/$maxRetries]: $e");
        
        if (retryCount >= maxRetries) {
          print("⚠️ Database $maxRetries urinishdan keyin ulanmadi");
          print(s);
          rethrow;
        }
        
        // Kutish va qayta urinish
        final waitSeconds = retryCount * 3;
        print("⏳ $waitSeconds soniya kutilmoqda...");
        await Future.delayed(Duration(seconds: waitSeconds));
      }
    }
  }

  bool get isConnected => _connection?.isOpen ?? false;

  /// Database ulanishini yopish
  Future<void> close() async {
    if (_connection != null && _connection!.isOpen) {
      await _connection!.close();
      _connection = null;
    }
  }

  /// Qayta ulanish
  Future<void> _reconnect() async {
    if (_isConnecting) {
      // Boshqa thread allaqachon ulanmoqda, kutamiz
      while (_isConnecting) {
        await Future.delayed(Duration(milliseconds: 500));
      }
      return;
    }

    _isConnecting = true;
    try {
      print("🔄 Database qayta ulanmoqda...");
      await close();
      await Future.delayed(Duration(seconds: 2));
      await init();
    } finally {
      _isConnecting = false;
    }
  }

  /// Query bajarish (xatolikka chidamli)
  Future<Result> execute(
    Object query, {
    Object? parameters,
    bool ignoreRows = false,
    QueryMode? queryMode,
    Duration? timeout,
  }) async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        // Ulanish tekshirish
        if (_connection == null || !_connection!.isOpen) {
          await _reconnect();
        }

        // Query bajarish
        final result = await _connection!.execute(
          query,
          parameters: parameters,
          ignoreRows: ignoreRows,
          queryMode: queryMode,
          timeout: timeout ?? Duration(seconds: 30),
        );
        
        return result;

      } catch (e, s) {
        retryCount++;
        print("❌ SQL xatosi [$retryCount/$maxRetries]: $e");

        if (retryCount >= maxRetries) {
          print("⚠️ SQL query $maxRetries urinishdan keyin bajarilmadi");
          print("Query: $query");
          print(s);
          return Result(rows: [], affectedRows: 0, schema: ResultSchema([]));
        }

        // Ulanish muammosi bo'lsa, qayta ulanamiz
        if (e.toString().contains('connection') || 
            e.toString().contains('closed') ||
            e.toString().contains('timeout')) {
          await _reconnect();
        }

        await Future.delayed(Duration(seconds: retryCount));
      }
    }

    return Result(rows: [], affectedRows: 0, schema: ResultSchema([]));
  }
}

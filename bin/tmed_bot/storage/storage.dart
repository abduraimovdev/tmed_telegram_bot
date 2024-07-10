import '../models/file_model.dart';
import '../models/user_model.dart';
import 'sql/sql.dart';
import 'sql/query.dart';
import '../../tmed_bot/main.dart';

class Storage {
  static const String boxName = "box";
  static const String files = "files";
  static const String users = "users";
  static final sql = PostgresSettings();

  static Future<void> initStorage() async {
    await sql.init();
    await UserModel.createDB();
    await FileModel.createDB();
  }

  static void saveFile(String fileUrl, String phone) async {
    final model = FileModel(phone: phone, fileUrl: fileUrl);
    await sql.execute(QueryBuilder.i.insertInto(tableName: files, values: model.values, columns: model.columns).build());
    print("Saved $model");
  }

  static Future<List<FileModel>> getFiles() async {
    final result = await sql.execute(QueryBuilder.i.selectAll().from(files).build());
    return result.map<FileModel>((element) => FileModel.fromSql(element)).toList();
  }

  static Future<List<FileModel>> getUserFiles(int chatId) async {
    try {
      final usersResult = (await sql.execute(QueryBuilder.i.selectAll().from(users).where().add('id').equal(chatId).build())).map<UserModel>((element) => UserModel.fromSql(element)).toList();
      if (usersResult.isEmpty) {
        return [];
      }

      final result = await sql.execute(QueryBuilder.i.selectAll().from(files).where().add('phone').equal(usersResult.first.phone).build());
      return result.map<FileModel>((element) => FileModel.fromSql(element)).toList();
    } catch (e, s) {
      print(e);
      print(s);
      return [];
    }
  }

  static Future<void> saveUser(int chatId, String number, String firstName, String lastName) async {
    final model = UserModel(id: chatId, phone: number, firstName: injectionFilter(firstName), lastName: injectionFilter(lastName));
    await sql.execute(QueryBuilder.i.insertInto(tableName: users, values: model.values, columns: model.columns).build());
    print("Saved $model");
  }

  static Future<List<UserModel>> getUsers() async {
    final result = await sql.execute(QueryBuilder.i.selectAll().from(users).build());
    return result.map<UserModel>((element) => UserModel.fromSql(element)).toList();
  }

  static Future<bool> checkUser(int chatId) async {
    final result = await sql.execute(QueryBuilder.i.selectAll().from(users).where().add("id").equal(chatId).build());
    return result.map<UserModel>((element) => UserModel.fromSql(element)).toList().isNotEmpty;
  }

  static String injectionFilter(String text) {
    String newText = text.replaceAll("`", "");
    newText = text.replaceAll("'", "");
    newText = text.replaceAll("*", "");
    newText = text.replaceAll(".", "");
    return newText;
  }
}

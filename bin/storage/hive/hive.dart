// import 'dart:convert';
//
// import 'package:hive/hive.dart';
//
// import '../models/file_model.dart';
// import '../models/user_model.dart';
//
// class Storage {
//   static late final Box box;
//   static const String boxName = "box";
//   static const String files = "files";
//   static const String users = "users";
//   static const String path = "./box";
//
//   static Future<void> initStorage() async {
//     Hive.init(path);
//
//     if (Hive.isBoxOpen(boxName)) {
//       box = Hive.box(boxName);
//     } else {
//       box = await Hive.openBox(boxName, path: path);
//     }
//   }
//
//   static void saveFile(String fileUrl, String phone) async {
//     final model = FileModel(number: phone, fileUrl: fileUrl);
//     final filesModel = await getFiles();
//     await box.put(files, jsonEncode([...filesModel.map((e) => e.toJson()), model.toJson()]));
//     print("Saved $model");
//   }
//
//   static Future<List<FileModel>> getFiles() async {
//     final result = box.get(files, defaultValue: jsonEncode([]));
//     return (jsonDecode(result) as List).map((e) => FileModel.fromJson(e)).toList();
//   }
//
//   static Future<List<FileModel>> getUserFiles(String chatId) async {
//     try {
//       final users = await getUsers();
//       final user = users.firstWhere((element) => element.id == chatId);
//       final files = await getFiles();
//       return files.where((e) => e.number == user.phone).toList();
//     } catch (e) {
//       return [];
//     }
//   }
//
//   static Future<void> saveUser(String chatId, String number, String firstName, String lastName) async {
//     final model = UserModel(id: chatId, phone: number, firstName: firstName, lastName: lastName);
//     final usersModel = await getUsers();
//     await box.put(users, jsonEncode([...usersModel.map((e) => e.toJson()), model.toJson()]));
//     print("Saved $model");
//   }
//
//   static Future<List<UserModel>> getUsers() async {
//     final result = box.get(users, defaultValue: jsonEncode([]));
//     print(result);
//     return (jsonDecode(result) as List).map((e) => UserModel.fromJson(e)).toList();
//   }
//
//   static Future<bool> checkUser(String chatId) async {
//     final result = await getUsers();
//     return result.where((element) => element.id == chatId).toList().isNotEmpty;
//   }
// }

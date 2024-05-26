import 'package:postgres/postgres.dart';

import '../../bin/storage/sql/sql.dart';

class UserModel {
  final int id;
  final String phone;
  final String firstName;
  final String lastName;

  const UserModel({
    this.id = 0,
    this.phone = '',
    this.firstName = '-',
    this.lastName = '-',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      phone: json['phone'] as String,
      firstName: (json['first_name'] as String).isEmpty ? "--" : json['first_name'] as String,
      lastName: (json['last_name'] as String).isEmpty ? "--" : json['last_name'] as String,
    );
  }

  static Future<void> createDB() async {
    await PostgresSettings().execute("""
    CREATE TABLE IF NOT EXISTS users(
    id bigint primary key,
    phone text,
    first_name text,
    last_name text
    )
  """);
  }

  List<String> get columns => [
        'id',
        'phone',
        'first_name',
        'last_name',
      ];

  List<Object> get values => [
        id,
        phone,
        firstName,
        lastName,
      ];

  factory UserModel.fromSql(ResultRow row) {
    return UserModel(
      id: row[0] as int,
      phone: row[1] as String,
      firstName: row[2] as String,
      lastName: row[3] as String,
    );
  }
}

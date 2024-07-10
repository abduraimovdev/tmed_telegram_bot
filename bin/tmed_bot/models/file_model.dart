import 'dart:io';

import 'package:postgres/postgres.dart';

import '../storage/sql/sql.dart';

class FileModel {
  final String phone;
  final String fileUrl;

  const FileModel({
    required this.phone,
    required this.fileUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'file_url': fileUrl,
    };
  }

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      phone: json['phone'] as String,
      fileUrl: json['file_url'] as String,
    );
  }

  List<String> get columns => [
        'phone',
        'file_url',
      ];

  List<String> get values => [
        phone,
        fileUrl,
      ];

  factory FileModel.fromSql(ResultRow row) {
    return FileModel(
      phone: row[0] as String,
      fileUrl: row[1] as String,
    );
  }

  @override
  String toString() {
    return 'FileModel{number: $phone, fileUrl: $fileUrl}';
  }

  static Future<void> createDB() async {
    await PostgresSettings().execute("""
    CREATE TABLE IF NOT EXISTS files(
    phone text,
    file_url text
    )
  """);
  }
}

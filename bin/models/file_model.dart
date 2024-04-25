class FileModel {
  final String number;
  final String fileUrl;

  const FileModel({
    required this.number,
    required this.fileUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'file_url': fileUrl,
    };
  }

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      number: json['number'] as String,
      fileUrl: json['file_url'] as String,
    );
  }

  @override
  String toString() {
    return 'FileModel{number: $number, fileUrl: $fileUrl}';
  }
}

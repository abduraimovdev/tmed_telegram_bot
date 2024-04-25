class UserModel {
  final String id;
  final String phone;
  final String firstName;
  final String lastName;

  const UserModel({
    this.id = '',
    this.phone = '',
    this.firstName = '',
    this.lastName = '',
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
      id: json['id'] as String,
      phone: json['phone'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }
}
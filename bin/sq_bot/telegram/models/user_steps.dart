
class UserSteps {
  final String name;
  final String lastName;
  final int step;
  final String text;
  final String phone;

  const UserSteps({
    this.name = '',
    this.lastName = '',
    this.step = 0,
    this.text = '',
    this.phone = '',
  });

  UserSteps copyWith({
    String? name,
    String? lastName,
    int? step,
    String? text,
    String? phone,
  }) {
    return UserSteps(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      step: step ?? this.step,
      text: text ?? this.text,
      phone: phone ?? this.phone,
    );
  }
}

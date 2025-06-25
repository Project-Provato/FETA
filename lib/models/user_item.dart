class UserItem {
  final String username;
  final int age;
  final String gender;
  final String extraInfo;

  UserItem({
    required this.username,
    required this.age,
    required this.gender,
    required this.extraInfo,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      username: json['username'],
      age: json['age'],
      gender: json['gender'],
      extraInfo: json['extra_info'],
    );
  }
}

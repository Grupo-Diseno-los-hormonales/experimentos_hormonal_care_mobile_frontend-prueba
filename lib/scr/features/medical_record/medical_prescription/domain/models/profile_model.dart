
class Profile {
  int id;
  String fullName;
  String gender;
  String phoneNumber;
  String image;
  String birthday;
  int userId;

  Profile({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.phoneNumber,
    required this.image,
    required this.birthday,
    required this.userId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['fullName'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      image: json['image'],
      birthday: json['birthday'],
      userId: json['userId'],
    );
  }
}
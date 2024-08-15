class UserModel {
  final String id, username, session, age, profile;

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        session = json['session'],
        age = json['age'],
        profile = json['profile'];
}

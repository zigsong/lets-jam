class UserProfileModel {
  final String image, phoneNo, email, bio, archive;

  UserProfileModel.fromJson(Map<String, dynamic> json)
      : image = json['image'],
        phoneNo = json['phoneNo'],
        email = json['email'],
        bio = json['bio'],
        archive = json['archive'];
}

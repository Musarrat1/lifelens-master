class UserModel {
  final String uid;
  final String name;
  final String email;
  final String password; // Encrypted password
  final String? facebookId; // Optional field
  final String? bloodGroup; // Optional field

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    this.facebookId,
    this.bloodGroup,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password, // Store encrypted password
      'facebookId': facebookId, // Include facebookId
      'bloodGroup': bloodGroup, // Include bloodGroup
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      facebookId: map['facebookId'], // Map facebookId
      bloodGroup: map['bloodGroup'], // Map bloodGroup
    );
  }
}
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String password; // Encrypted password

  UserModel({required this.uid, required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password, // Store encrypted password
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }
}

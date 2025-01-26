import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Secret Key for Encryption (Do NOT expose this in production)
  final key = encrypt.Key.fromLength(32); // 256-bit key
  final iv = encrypt.IV.fromLength(16); // 16-byte IV

  String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.encrypt(password, iv: iv).base64;
  }

  // Sign Up Function
  Future<String?> signUp(String name, String email, String password) async {
    try {
      // Create User in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Encrypt password before storing
      String encryptedPassword = encryptPassword(password);

      // Store user data in Firestore
      UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        password: encryptedPassword, // Store encrypted password
      );
      await _firestore.collection('users_info').doc(uid).set(newUser.toMap());

      return "User registered successfully!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An error occurred: $e";
    }
  }

  // Sign In Function
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An error occurred: $e";
    }
  }

  // Fetch User Data
  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users_info').doc(uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Sign Out Function
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  //kayıt yapmak için
  Future<void> signUp({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        throw Exception("Zayıf parola");
      } else if (e.code == "email-already-in-use") {
        throw Exception("Bu e-posta için hesap zaten var.");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

//giriş yapmak için
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        throw Exception("Bu e-posta için kullanıcı bulunamadı.");
      } else if (e.code == "wrong-password") {
        throw Exception("Hatalı Şifre");
      }
    }
  }

//çıkış yapmak için
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }
}

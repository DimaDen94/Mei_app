import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<String> signUpWithFB();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  FacebookLogin fbLogin = new FacebookLogin();

  @override
  Future<String> signUpWithFB() async {
    final facebookLoginResult = await fbLogin.logInWithReadPermissions(['email', 'public_profile']);
    print(facebookLoginResult.toString());
    FacebookAccessToken myToken = facebookLoginResult.accessToken;
    print(myToken.toString());

    AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: myToken.token);
    print(credential.toString());

    FirebaseUser firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
    print(firebaseUser.toString());

    return firebaseUser.uid;
  }
}

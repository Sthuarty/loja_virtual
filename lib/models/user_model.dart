import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser firebaseUser;
  Map<String, dynamic> userData = Map();

  bool isLoading = false;

  void signUp(
      {@required Map<String, dynamic> userData,
      @required String pass,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) {
    isLoading = true;
    notifyListeners();

    _auth
        .createUserWithEmailAndPassword(
      email: userData["email"],
      password: pass,
    )
        .then((auth) async {
      firebaseUser = auth.user;
/*A versão 0.14.0 do firebase_auth mudou o comportamento deste código

Antes o código era assim.

    _auth
        .createUserWithEmailAndPassword(
      email: userData["email"],
      password: pass,
    )
        .then((user) async {
      firebaseUser = user;


Agora ele deve ser assim:

    _auth
        .createUserWithEmailAndPassword(
      email: userData["email"],
      password: pass,
    )
        .then((auth) async {
      firebaseUser = auth.user;

Resumindo, anteriormente a função createUserWithEmailAndPassword, retornava um FirebaseUser.
Agora ela retorna um AuthResult e dentro dele pegamos o usuário no .user*/

      await _saveUserData(userData);

      onSuccess();
      isLoading = false;
      notifyListeners();
    }).catchError((onError) {
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  void signIn() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 3));

    isLoading = false;
    notifyListeners();
  }

  void recoverPassword() {}

  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .setData(userData);
  }
}

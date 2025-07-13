import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;

  AuthService() {
    FirebaseAuth.instance.authStateChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<void> login(String email, String pass) =>
      FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);

  Future<void> register(String email, String pass) =>
      FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);

  Future<void> saveProfile(Map<String, dynamic> data) async {
    final uid = user!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
  }

  Future<Map<String, dynamic>?> loadProfile() async {
    if (user == null) return null;
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    return doc.data();
  }

  Future<void> logout() => FirebaseAuth.instance.signOut();
}

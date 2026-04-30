import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { solicitante, aprobador }

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Registro con rol
  Future<void> register({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _db.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Usuario creado: ${cred.user!.uid}');
    } catch (e) {
      print('Error al registrar: $e');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserRole> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return UserRole.solicitante;
    return doc.data()!['role'] == 'aprobador'
        ? UserRole.aprobador
        : UserRole.solicitante;
  }

  Future<void> logout() async => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}

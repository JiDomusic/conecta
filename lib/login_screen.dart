import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final dniController = TextEditingController();
  final barrioController = TextEditingController();
  final bioController = TextEditingController();
  final preferenciasController = TextEditingController();

  bool isLogin = true;
  bool loading = false;
  String? errorMsg;

  Future<void> _submit() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    final email = emailController.text.trim();
    final pass = passwordController.text;

    if (!email.contains('@') || pass.length < 6) {
      setState(() {
        loading = false;
        errorMsg = 'Email o contraseña inválida';
      });
      return;
    }

    try {
      UserCredential cred;
      if (isLogin) {
        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );

        // ✅ Verificar si ya tiene perfil en Firestore
        final docRef = FirebaseFirestore.instance.collection('users').doc(cred.user!.uid);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({
            'email': email,
            'uid': cred.user!.uid,
            'rating y posible match': 0,
          });
        }
      } else {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );

        // Guardar información del usuario en Firestore
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'email': email,
          'nombre': nombreController.text.trim(),
          'apellido': apellidoController.text.trim(),
          'dni': dniController.text.trim(),
          'barrio zona': barrioController.text.trim(),
          'bio': bioController.text.trim(),
          'preferencias': preferenciasController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          'rating y posible match': 0,
          'uid': cred.user!.uid,
        });
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = e.message;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Error inesperado: $e';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Iniciar sesión' : 'Registrarse')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
            if (!isLogin) ...[
              TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: apellidoController, decoration: const InputDecoration(labelText: 'Apellido')),
              TextField(controller: dniController, decoration: const InputDecoration(labelText: 'DNI')),
              TextField(controller: barrioController, decoration: const InputDecoration(labelText: 'Barrio/Zona')),
              TextField(controller: bioController, decoration: const InputDecoration(labelText: 'Bio')),
              TextField(
                controller: preferenciasController,
                decoration: const InputDecoration(
                  labelText: 'Preferencias (separadas por coma)',
                  hintText: 'ej: amistad, charlar, eventos...',
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (errorMsg != null)
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submit,
              child: Text(isLogin ? 'Entrar' : 'Crear cuenta'),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? '¿No tienes cuenta? Registrate' : '¿Ya tienes cuenta? Inicia sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

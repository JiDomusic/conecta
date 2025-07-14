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

    if (!email.contains('@')) {
      setState(() {
        loading = false;
        errorMsg = 'Ingresa un email válido';
      });
      return;
    }
    if (pass.length < 6) {
      setState(() {
        loading = false;
        errorMsg = 'La contraseña debe tener al menos 6 caracteres';
      });
      return;
    }

    try {
      UserCredential cred;
      if (isLogin) {
        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      } else {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'nombre': 'pepa',
          'apellido': 'arias',
          'dni': '123456',
          'barrio zona': 'rosario centro',
          'bio': 'bla bla bla',
          'preferencias': ['hablar', 'encuentros grupales', 'citas', 'reuniones ', 'charlar'],
          'rating y posible match': 0,
        });
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/profile');

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            if (errorMsg != null) Text(errorMsg!, style: const TextStyle(color: Colors.red)),
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

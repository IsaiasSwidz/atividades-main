import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFirestoreRegisterPage extends StatefulWidget {
  const FirebaseFirestoreRegisterPage({super.key});

  @override
  State<FirebaseFirestoreRegisterPage> createState() => _FirebaseFirestoreRegisterPageState();
}

class _FirebaseFirestoreRegisterPageState extends State<FirebaseFirestoreRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _message;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _message = 'Usuário cadastrado com sucesso!';
      });
      _nameController.clear();
      _emailController.clear();
    } catch (e) {
      setState(() {
        _message = 'Erro ao cadastrar: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário (Firestore)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o e-mail' : null,
              ),
              const SizedBox(height: 20),
              if (_loading) const CircularProgressIndicator(),
              if (!_loading)
                ElevatedButton(
                  onPressed: _registerUser,
                  child: const Text('Cadastrar'),
                ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(_message!, style: TextStyle(color: Colors.green)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
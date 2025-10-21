import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenSecureStoragePage extends StatefulWidget {
  const TokenSecureStoragePage({super.key});

  @override
  State<TokenSecureStoragePage> createState() => _TokenSecureStoragePageState();
}

class _TokenSecureStoragePageState extends State<TokenSecureStoragePage> {
  final _storage = const FlutterSecureStorage();
  final _controller = TextEditingController();
  String? _storedToken;

  @override
  void initState() {
    super.initState();
    _readToken(); // Lê o token salvo ao abrir a página
  }

  Future<void> _saveToken() async {
    final token = _controller.text;
    if (token.isNotEmpty) {
      await _storage.write(key: 'token', value: token);
      setState(() {
        _storedToken = token;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Token salvo com sucesso!')));
    }
  }

  Future<void> _readToken() async {
    final token = await _storage.read(key: 'token');
    setState(() {
      _storedToken = token;
    });
  }

  Future<void> _deleteToken() async {
    await _storage.delete(key: 'token');
    setState(() {
      _storedToken = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Token apagado!')));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Token Storage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Digite o token'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _saveToken,
                  child: const Text('Salvar Token'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _readToken,
                  child: const Text('Ler Token'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _deleteToken,
                  child: const Text('Apagar Token'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _storedToken == null
                  ? 'Nenhum token salvo'
                  : 'Token salvo: $_storedToken',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListaProdutosPage extends StatefulWidget {
  const ListaProdutosPage({super.key});

  @override
  State<ListaProdutosPage> createState() => _ListaProdutosPageState();
}

class _ListaProdutosPageState extends State<ListaProdutosPage> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final res = await Supabase.instance.client
          .from('products')
          .select()
          .order('id', ascending: false); // v2: sem .execute()
      // res pode ser List<dynamic> ou Map, adaptar conforme retorno
      final list = (res as List).cast<Map<String, dynamic>>();
      setState(() => _products = list);
    } catch (e) {
      debugPrint('Supabase error: $e');
      // mostrar snackbar, etc.
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addProduct() async {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0;
    if (name.isEmpty) return;
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.from('products').insert({
        'name': name,
        'price': price,
        'created_at': DateTime.now().toIso8601String(),
      }); // v2: sem .execute()
      _nameCtrl.clear();
      _priceCtrl.clear();
      await _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await Supabase.instance.client.from('products').delete().eq('id', id); // sem .execute()
      await _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao deletar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos (Supabase)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nome do produto')),
            TextField(controller: _priceCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Preço')),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton(onPressed: _loading ? null : _addProduct, child: const Text('Cadastrar')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _loading ? null : _loadProducts, child: const Text('Atualizar')),
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (_, i) {
                          final p = _products[i];
                          final id = p['id'] as int?;
                          final name = p['name']?.toString() ?? '';
                          final price = p['price']?.toString() ?? '';
                          return ListTile(
                            title: Text(name),
                            subtitle: Text('Preço: $price'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: id == null ? null : () => _deleteProduct(id),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
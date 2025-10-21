import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tokensecurestorage.dart';
import 'sqlitetasks.dart';
import 'firebasefirestone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'listaprodutos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase (se ainda for necessário)
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://itposvhgumoslvxgndfn.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '<anon-key>',
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  runApp(MyApp(isDark: isDark));
}

class MyApp extends StatefulWidget {
  final bool isDark;
  const MyApp({super.key, required this.isDark});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  void _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        isDark: _isDark,
        onDarkModeChanged: _toggleDarkMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final bool isDark;
  final ValueChanged<bool> onDarkModeChanged;

  const MyHomePage({
    super.key,
    required this.title,
    required this.isDark,
    required this.onDarkModeChanged,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _toggleDarkMode() {
    widget.onDarkModeChanged(!widget.isDark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Dark mode: ${widget.isDark}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleDarkMode,
              child: Text(
                widget.isDark ? 'Desativar Dark Mode' : 'Ativar Dark Mode',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TokenSecureStoragePage(),
                  ),
                );
              },
              child: const Text('Ir para Secure Token Storage'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SQLiteTasksPage()),
                );
              },
              child: const Text('Ir para Tarefas com SQLite'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FirebaseFirestoreRegisterPage(),
                  ),
                );
              },
              child: const Text('Ir para Cadastro Firebase Firestore'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ListaProdutosPage()),
                );
              },
              child: const Text('Ir para Produtos (Supabase)'),
            ),
          ],
        ),
      ),
    );
  }
}

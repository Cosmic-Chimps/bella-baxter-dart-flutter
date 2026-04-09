import 'dart:async';

import 'package:bella_baxter/bella_client.dart';
import 'package:bella_baxter_flutter/bella_baxter_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Look Ma, No Secrets!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SecretsPage(),
    );
  }
}

class SecretsPage extends StatefulWidget {
  const SecretsPage({super.key});

  @override
  State<SecretsPage> createState() => _SecretsPageState();
}

class _SecretsPageState extends State<SecretsPage> {
  // Secrets are read from platform env (injected by `bella run`) or
  // fetched via the SDK when BELLA_BAXTER_API_KEY is set.
  late final BellaClient _client;
  Map<String, String> _secrets = {};
  bool _loading = true;
  String? _error;
  StreamSubscription<Map<String, String>>? _sub;

  @override
  void initState() {
    super.initState();
    _client = BellaClient(BellaClientOptions(
      // API key injected by `bella run` or `bella exec`.
      apiKey: const String.fromEnvironment('BELLA_API_KEY'),
      // Cache secrets across app launches using flutter_secure_storage.
      cache: FlutterSecureSecretCache(),
    ));
    _startPolling();
  }

  void _startPolling() {
    _sub = _client
        .watchSecrets(interval: const Duration(minutes: 5))
        .listen((secrets) {
      setState(() {
        _secrets = secrets;
        _loading = false;
        _error = null;
      });
    }, onError: (Object e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secrets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () async {
              setState(() => _loading = true);
              try {
                final s = await _client.pullSecrets();
                setState(() {
                  _secrets = s;
                  _loading = false;
                  _error = null;
                });
              } catch (e) {
                setState(() {
                  _error = e.toString();
                  _loading = false;
                });
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (_secrets.isEmpty) {
      return const Center(child: Text('No secrets found.'));
    }
    return ListView.separated(
      itemCount: _secrets.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final key = _secrets.keys.elementAt(i);
        return ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(key, style: const TextStyle(fontFamily: 'monospace')),
          subtitle: const Text('••••••••'),
        );
      },
    );
  }
}

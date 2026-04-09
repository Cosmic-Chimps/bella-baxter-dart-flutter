/// Example: cache Bella Baxter secrets securely on-device with Flutter.
///
/// This example shows how to use [FlutterSecureSecretCache] to cache
/// secrets fetched from Bella Baxter in flutter_secure_storage so your
/// app doesn't need to call the network on every startup.
///
/// Prerequisites:
/// 1. Add bella_baxter and bella_baxter_flutter to your pubspec.yaml
/// 2. Set BELLA_API_KEY via your CI/CD or `bella run` tooling
///
/// See the full Flutter app in example/05-flutter-app/
library;

import 'package:bella_baxter/bella_client.dart';
import 'package:bella_baxter_flutter/bella_baxter_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bella Baxter Flutter Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Bella Baxter')),
        body: FutureBuilder<Map<String, String>>(
          future: _loadSecrets(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!.entries
                    .map((e) => ListTile(title: Text(e.key), subtitle: const Text('***')))
                    .toList(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<Map<String, String>> _loadSecrets() async {
    // Use FlutterSecureSecretCache to cache secrets in flutter_secure_storage.
    // On first run, secrets are fetched from Bella Baxter and stored encrypted.
    // On subsequent runs, they are read from the secure cache.
    final client = BellaClient(BellaClientOptions(
      apiKey: const String.fromEnvironment('BELLA_API_KEY'),
      cache: FlutterSecureSecretCache(),
    ));
    return client.pullSecrets();
  }
}


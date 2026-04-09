/// Flutter integration for the Bella Baxter Dart SDK.
///
/// Provides [FlutterSecureSecretCache] — a [SecretCache] implementation
/// backed by `flutter_secure_storage` for encrypted on-device caching.
///
/// ## Quick start
///
/// ```dart
/// import 'package:bella_baxter/bella_client.dart';
/// import 'package:bella_baxter_flutter/bella_baxter_flutter.dart';
///
/// final client = BellaClient(BellaClientOptions(
///   apiKey: const String.fromEnvironment('BELLA_API_KEY'),
///   cache: FlutterSecureSecretCache(),
/// ));
///
/// // Returns cached secrets when offline; fetches fresh when online.
/// final secrets = await client.pullSecrets();
/// ```
library bella_baxter_flutter;

export 'package:bella_baxter_flutter/src/flutter_secure_secret_cache.dart';

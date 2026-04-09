import 'dart:convert';

import 'package:bella_baxter/bella_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A [SecretCache] backed by [FlutterSecureStorage] for encrypted on-device
/// caching of Bella Baxter secrets.
///
/// Secrets are serialised as a single JSON object and stored under
/// [storageKey] in the platform's secure storage:
/// - Android: EncryptedSharedPreferences
/// - iOS / macOS: Keychain
/// - Linux: libsecret
/// - Windows: Windows Credential Manager
/// - Web: AES-encrypted localStorage
///
/// ## Usage
///
/// ```dart
/// final client = BellaClient(BellaClientOptions(
///   apiKey: Platform.environment['BELLA_API_KEY']!,
///   cache: FlutterSecureSecretCache(),
/// ));
///
/// // Fetches from Bella Baxter on first call; returns cached value offline.
/// final secrets = await client.pullSecrets();
/// ```
///
/// Pass [storageKey] to namespace secrets per environment or project:
///
/// ```dart
/// FlutterSecureSecretCache(storageKey: 'bella_secrets_prod')
/// ```
class FlutterSecureSecretCache implements SecretCache {
  /// The key used to store the serialised secrets map in secure storage.
  final String storageKey;

  /// Platform-specific storage options forwarded to [FlutterSecureStorage].
  final AndroidOptions? androidOptions;

  /// Platform-specific storage options forwarded to [FlutterSecureStorage].
  final IOSOptions? iOSOptions;

  final FlutterSecureStorage _storage;

  /// Creates a [FlutterSecureSecretCache].
  ///
  /// - [storageKey] defaults to `'_bella_baxter_secrets'`.
  /// - [androidOptions] defaults to `AndroidOptions(encryptedSharedPreferences: true)`.
  FlutterSecureSecretCache({
    this.storageKey = '_bella_baxter_secrets',
    this.androidOptions,
    this.iOSOptions,
  }) : _storage = FlutterSecureStorage(
          aOptions: androidOptions ?? const AndroidOptions(),
          iOptions: iOSOptions ?? IOSOptions.defaultOptions,
        );

  /// Returns the last persisted secrets, or `null` if nothing is stored yet.
  @override
  Future<Map<String, String>?> read() async {
    final raw = await _storage.read(key: storageKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      // Corrupt cache — treat as empty.
      return null;
    }
  }

  /// Persists [secrets] to secure storage.
  ///
  /// Called automatically by [BellaClient.pullSecrets] after every successful
  /// fetch from the Bella Baxter API.
  @override
  Future<void> write(Map<String, String> secrets) async {
    await _storage.write(key: storageKey, value: jsonEncode(secrets));
  }

  /// Deletes the cached secrets from secure storage.
  ///
  /// Call this on logout, API key rotation, or whenever you want to force
  /// a fresh fetch on the next [BellaClient.pullSecrets] call.
  @override
  Future<void> clear() async {
    await _storage.delete(key: storageKey);
  }
}

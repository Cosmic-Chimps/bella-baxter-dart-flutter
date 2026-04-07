# bella_baxter_flutter

[![pub.dev](https://img.shields.io/pub/v/bella_baxter_flutter.svg)](https://pub.dev/packages/bella_baxter_flutter)

Flutter integration for the [Bella Baxter Dart SDK](https://pub.dev/packages/bella_baxter).

Provides `FlutterSecureSecretCache` — a `SecretCache` implementation backed by
[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) for
encrypted, on-device secret caching using the OS Keychain (iOS/macOS) or
EncryptedSharedPreferences (Android).

## Installation

```yaml
dependencies:
  bella_baxter: ^1.0.0
  bella_baxter_flutter: ^1.0.0
```

## Usage

```dart
import 'package:bella_baxter/bella_client.dart';
import 'package:bella_baxter_flutter/bella_baxter_flutter.dart';

final client = BellaClient(BellaClientOptions(
  baseUrl: const String.fromEnvironment('BELLA_BAXTER_URL'),
  apiKey:  const String.fromEnvironment('BELLA_BAXTER_API_KEY'),
  cache:   FlutterSecureSecretCache(),
));

// Secrets are fetched once and cached to the device keychain.
// Subsequent calls return the cached value until invalidated.
final secrets = await client.getSecrets(environmentId: 'my-env-id');
```

## Platform Support

| Android | iOS | macOS | Web |
|---------|-----|-------|-----|
| ✅ | ✅ | ✅ | ❌ |

Web is not supported because `flutter_secure_storage` requires a platform keystore.

## Bella Baxter

[Bella Baxter](https://bella-baxter.io) is a secret management gateway by
[Cosmic Chimps](https://cosmicchimps.io). One unified API for all your secret
providers — Vault, AWS Secrets Manager, Azure Key Vault, and GCP Secret Manager.

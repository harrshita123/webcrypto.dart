// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  Future<void> checkMessageSnapshot(
    Future<Uint8List> Function(List<int>) sign,
    Future<bool> Function(List<int>, List<int>) verify,
  ) async {
    final original = Uint8List.fromList([1, 2, 3]);
    final signature = await sign(original);

    final changed = Uint8List.fromList(original);
    final pending = verify(signature, changed);
    changed[0] ^= 0xff;

    expect(await pending, isTrue);
    expect(await verify(signature, changed), isFalse);

    final invalid = Uint8List.fromList(changed);
    final invalidPending = verify(signature, invalid);
    invalid[0] ^= 0xff;

    expect(await invalidPending, isFalse);
    expect(await verify(signature, invalid), isTrue);
  }

  test('HMAC verifyBytes snapshots message input', () async {
    final key = await HmacSecretKey.importRawKey(Uint8List(16), Hash.sha256);
    await checkMessageSnapshot(key.signBytes, key.verifyBytes);
  });

  test('ECDSA verifyBytes snapshots message input', () async {
    final keys = await EcdsaPrivateKey.generateKey(EllipticCurve.p256);
    await checkMessageSnapshot(
      (data) => keys.privateKey.signBytes(data, Hash.sha256),
      (signature, data) =>
          keys.publicKey.verifyBytes(signature, data, Hash.sha256),
    );
  });

  test('RSA-PSS verifyBytes snapshots message input', () async {
    final keys = await RsaPssPrivateKey.generateKey(
      1024,
      BigInt.from(65537),
      Hash.sha256,
    );
    await checkMessageSnapshot(
      (data) => keys.privateKey.signBytes(data, 32),
      (signature, data) => keys.publicKey.verifyBytes(signature, data, 32),
    );
  });

  test('RSASSA-PKCS1-v1_5 verifyBytes snapshots message input', () async {
    final keys = await RsassaPkcs1V15PrivateKey.generateKey(
      1024,
      BigInt.from(65537),
      Hash.sha256,
    );
    await checkMessageSnapshot(
      keys.privateKey.signBytes,
      keys.publicKey.verifyBytes,
    );
  });
}

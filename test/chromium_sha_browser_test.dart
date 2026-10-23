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

@TestOn('browser')
library;

import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

void main() {
  test('Chromium SHA vectors', () async {
    final channel = spawnHybridUri('chromium_vector_loader.dart');
    channel.sink.add('sha');
    final source = await channel.stream.first as String;
    await channel.sink.close();

    final json = source
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');
    final vectors = jsonDecode(json) as List<dynamic>;
    expect(vectors, isNotEmpty);

    for (final (index, value) in vectors.indexed) {
      final vector = value as Map<String, dynamic>;
      final hash = switch (vector['algorithm']) {
        'sha-1' => Hash.sha1,
        'sha-256' => Hash.sha256,
        'sha-384' => Hash.sha384,
        'sha-512' => Hash.sha512,
        final algorithm => throw FormatException(
          'Unsupported hash: $algorithm',
        ),
      };
      final input = hex.decode(vector['input'] as String);
      final output = hex.decode(vector['output'] as String);
      expect(
        await hash.digestBytes(input),
        output,
        reason: 'Chromium vector $index',
      );
      expect(
        await hash.digestStream(
          Stream.fromIterable([input.take(1).toList(), input.skip(1).toList()]),
        ),
        output,
        reason: 'Chromium vector $index',
      );
    }
  });
}

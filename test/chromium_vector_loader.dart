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

import 'dart:io';
import 'dart:isolate';

import 'package:stream_channel/stream_channel.dart';

Future<void> hybridMain(StreamChannel<Object?> channel) async {
  final name = await channel.stream.first;
  final path = switch (name) {
    'sha' => 'sha.json',
    'bad_ec_keys' => 'bad_ec_keys.json',
    _ => throw ArgumentError.value(name, 'name'),
  };
  final packageUri = Isolate.resolvePackageUriSync(
    Uri.parse('package:webcrypto/webcrypto.dart'),
  );
  if (packageUri == null) {
    throw StateError('Unable to locate package:webcrypto.');
  }
  final file = File.fromUri(
    packageUri.resolve('../third_party/chromium/$path'),
  );
  channel.sink.add(file.readAsStringSync());
  await channel.sink.close();
}

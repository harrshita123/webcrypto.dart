// Copyright 2020 Google LLC
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
import 'package:webcrypto/webcrypto.dart';
import '../utils/utils.dart';

void isAllZero(TypedData data) {
  data.buffer.asUint8List().forEach((b) => check(b == 0));
}

void isNotAllZero(TypedData data) {
  check(data.buffer.asUint8List().any((b) => b != 0));
}

void main() => tests().runTests();

/// Tests, exported for use in `../run_all_tests.dart`.
List<({String name, Future<void> Function() test})> tests() {
  final tests = <({String name, Future<void> Function() test})>[];
  void test(String name, Future<void> Function() test) =>
      tests.add((name: name, test: test));

  test('uuid: generates valid unique version 4 UUIDs', () async {
    final generated = <String>{};
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    for (var i = 0; i < 100; i++) {
      final value = uuid();
      check(pattern.hasMatch(value), 'invalid version 4 UUID: $value');
      check(generated.add(value), 'generated duplicate UUID: $value');
    }
  });

  test('fillRandomBytes: Uint8List', () async {
    final data = Uint8List(16 * 1024);
    isAllZero(data);
    fillRandomBytes(data);
    isNotAllZero(data);
  });

  test('fillRandomBytes: Uint16List', () async {
    final data = Uint16List(4 * 1024);
    isAllZero(data);
    fillRandomBytes(data);
    isNotAllZero(data);
  });

  test('fillRandomBytes: Uint32List', () async {
    final data = Uint32List(2 * 1024);
    isAllZero(data);
    fillRandomBytes(data);
    isNotAllZero(data);
  });

  test('fillRandomBytes: Int8List', () async {
    final data = Int8List(16 * 1024);
    isAllZero(data);
    fillRandomBytes(data);
    isNotAllZero(data);
  });

  test('fillRandomBytes: Int16List', () async {
    final data = Int16List(4 * 1024);
    isAllZero(data);
    fillRandomBytes(data);
    isNotAllZero(data);
  });

  test('fillRandomBytes: Int32List', () async {
    final data = Int32List(2 * 1024);
    isAllZero(data);
    fillRandomBytes(data);
    isNotAllZero(data);
  });

  test('fillRandomBytes: Maximum buffer', () async {
    final data = Uint8List(64 * 1024);
    isAllZero(data);
    fillRandomBytes(data);
    isNotAllZero(data);
  });

  return tests;
}

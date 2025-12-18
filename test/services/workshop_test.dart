import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wpeui/services/workshop.dart';
import 'package:path/path.dart' as path;

void main() {
  group('Workshop Service Tests', () {
    late Directory tempDir;

    setUp(() {
      // Create a temporary directory for testing
      tempDir = Directory.systemTemp.createTempSync('workshop_test_');
    });

    tearDown(() {
      // Clean up the temporary directory
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('getAllOfDirectory returns empty list for non-existent directory', () {
      final nonExistentPath = path.join(tempDir.path, 'non_existent');
      final items = Workshop.getAllOfDirectory(nonExistentPath);
      expect(items, isEmpty);
    });

    test('getAllOfDirectory returns correct items from directory', () {
      // Create dummy workshop item directories
      final item1Dir = Directory(path.join(tempDir.path, '12345'));
      item1Dir.createSync();

      final item2Dir = Directory(path.join(tempDir.path, '67890'));
      item2Dir.createSync();

      // Create a file to ensure it's ignored (since the code checks for Directory)
      final file = File(path.join(tempDir.path, 'not_a_directory.txt'));
      file.createSync();

      final items = Workshop.getAllOfDirectory(tempDir.path);

      expect(items.length, 2);

      // Verify item 1
      final item1 = items.firstWhere((item) => item.id == '12345');
      expect(item1.name, 'Workshop Item 12345');
      expect(item1.fullPath, item1Dir.path);

      // Verify item 2
      final item2 = items.firstWhere((item) => item.id == '67890');
      expect(item2.name, 'Workshop Item 67890');
      expect(item2.fullPath, item2Dir.path);
    });
  });
}

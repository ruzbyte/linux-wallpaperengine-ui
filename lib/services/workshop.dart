import 'dart:convert';
import 'dart:io';

import 'package:wpeui/models/workshop_metadata.dart';

class WorkshopItem {
  final String id;
  final String name;
  final String fullPath;
  final String preview;
  final WorkshopMetadata metadata;

  WorkshopItem({
    required this.id,
    required this.name,
    required this.fullPath,
    required this.metadata,
    required this.preview,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullPath': fullPath,
      'preview': preview,
      'metadata': metadata.toJson(),
    };
  }

  factory WorkshopItem.fromJson(Map<String, dynamic> json) {
    return WorkshopItem(
      id: json['id'],
      name: json['name'],
      fullPath: json['fullPath'],
      preview: json['preview'],
      metadata: WorkshopMetadata.fromJson(json['metadata']),
    );
  }
}

// example Workshop Path : /home/zaroc/.steam/steam/steamapps/workshop/content/431960

class Workshop {
  static List<WorkshopItem> items = [];

  static List<WorkshopItem> getAllOfDirectory(String directoryPath) {
    Directory dir = Directory(directoryPath);

    if (!dir.existsSync()) {
      return [];
    }

    List<WorkshopItem> workshopItems = [];

    List<FileSystemEntity> entities = dir.listSync();

    for (var entity in entities) {
      if (entity is Directory) {
        String id = entity.path.split(Platform.pathSeparator).last;

        final String metadataPath =
            '${entity.path}${Platform.pathSeparator}project.json';
        final File metadataFile = File(metadataPath);

        WorkshopMetadata metadata = WorkshopMetadata.fromJson(
          jsonDecode(metadataFile.readAsStringSync()),
        );

        workshopItems.add(
          WorkshopItem(
            id: id,
            name: metadata.title ?? 'Workshop Item $id',
            fullPath: entity.path,
            preview:
                '${entity.path}${Platform.pathSeparator}${metadata.preview}',
            metadata: metadata,
          ),
        );
      }
    }
    return workshopItems;
  }
}

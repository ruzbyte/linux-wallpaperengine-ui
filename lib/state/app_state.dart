import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wpeui/services/wpe.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;

  AppState._internal() {
    _loadConfig();
  }

  final Map<String, WpeLaunchOptions> _monitorConfigs = {};
  int _fps = 30;
  bool _silent = true;
  bool _noParallax = false;
  bool _hideWindowDecorations = false;
  String? _workshopPath;

  Map<String, WpeLaunchOptions> get monitorConfigs => _monitorConfigs;
  int get fps => _fps;
  bool get silent => _silent;
  bool get noParallax => _noParallax;
  bool get hideWindowDecorations => _hideWindowDecorations;
  String? get workshopPath => _workshopPath;

  String get _configPath {
    final home = Platform.environment['HOME'];
    return '$home/.config/wpeui/config.json';
  }

  Future<void> _loadConfig() async {
    try {
      final file = File(_configPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);

        if (json['fps'] != null) _fps = json['fps'];
        if (json['silent'] != null) _silent = json['silent'];
        if (json['noParallax'] != null) _noParallax = json['noParallax'];
        if (json['hideWindowDecorations'] != null) {
          _hideWindowDecorations = json['hideWindowDecorations'];
          _applyWindowDecorations();
        }
        if (json['workshopPath'] != null) {
          _workshopPath = json['workshopPath'];
        }

        if (json['monitors'] != null) {
          final monitors = json['monitors'] as Map<String, dynamic>;
          monitors.forEach((key, value) {
            _monitorConfigs[key] = WpeLaunchOptions.fromJson(value);
          });
        }

        if (_workshopPath == null) {
          _findWorkshopPath();
        }

        notifyListeners();
      } else {
        _findWorkshopPath();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading config: $e');
      }
    }
  }

  void _findWorkshopPath() {
    final home = Platform.environment['HOME'];
    final List<String> searchPaths = [
      '$home/.steam/steam/steamapps/workshop/content/431960',
      '$home/.local/share/Steam/steamapps/workshop/content/431960',
      '$home/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/workshop/content/431960',
      '$home/snap/steam/common/.local/share/Steam/steamapps/workshop/content/431960',
    ];

    for (final path in searchPaths) {
      if (Directory(path).existsSync()) {
        _workshopPath = path;
        _saveConfig();
        notifyListeners();
        return;
      }
    }
  }

  void setWorkshopPath(String path) {
    _workshopPath = path;
    _saveConfig();
    notifyListeners();
  }

  Future<void> _saveConfig() async {
    try {
      final file = File(_configPath);
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      final json = {
        'fps': _fps,
        'silent': _silent,
        'noParallax': _noParallax,
        'hideWindowDecorations': _hideWindowDecorations,
        'workshopPath': _workshopPath,
        'monitors': _monitorConfigs.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };

      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving config: $e');
      }
    }
  }

  void setGlobalOptions({
    int? fps,
    bool? silent,
    bool? noParallax,
    bool? hideWindowDecorations,
  }) {
    if (fps != null) _fps = fps;
    if (silent != null) _silent = silent;
    if (noParallax != null) _noParallax = noParallax;
    if (hideWindowDecorations != null) {
      _hideWindowDecorations = hideWindowDecorations;
      _applyWindowDecorations();
    }
    _saveConfig();
    notifyListeners();
  }

  Future<void> _applyWindowDecorations() async {
    try {
      if (_hideWindowDecorations) {
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      } else {
        await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      }
    } catch (e) {
      // Window manager might not be initialized yet or not supported
      if (kDebugMode) {
        print('Error setting window decorations: $e');
      }
    }
  }

  void setConfiguration(String monitor, WpeLaunchOptions options) {
    _monitorConfigs[monitor] = options;
    _saveConfig();
    notifyListeners();
  }

  void removeConfiguration(String monitor) {
    _monitorConfigs.remove(monitor);
    _saveConfig();
    notifyListeners();
  }

  void clearAll() {
    _monitorConfigs.clear();
    _saveConfig();
    notifyListeners();
  }
}

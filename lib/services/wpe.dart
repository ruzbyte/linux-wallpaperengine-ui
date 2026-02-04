import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:wpeui/services/workshop.dart';

enum WpeScaling { stretch, fit, fill }

class WpeLaunchOptions {
  final String wallpaperId;
  final String monitorName;
  final WpeScaling scaling;
  final WorkshopItem? item;

  WpeLaunchOptions({
    required this.wallpaperId,
    required this.monitorName,
    required this.scaling,
    this.item,
  });

  Map<String, dynamic> toJson() {
    return {
      'wallpaperId': wallpaperId,
      'monitorName': monitorName,
      'scaling': scaling.index,
      'item': item?.toJson(),
    };
  }

  factory WpeLaunchOptions.fromJson(Map<String, dynamic> json) {
    return WpeLaunchOptions(
      wallpaperId: json['wallpaperId'],
      monitorName: json['monitorName'],
      scaling: WpeScaling.values[json['scaling']],
      item: json['item'] != null ? WorkshopItem.fromJson(json['item']) : null,
    );
  }
}

List<int> wpeSupportedFps = [15, 30, 60];

class WpeCommandBuilder {
  String command = "";

  WpeCommandBuilder() {
    command = "linux-wallpaperengine ";
  }

  void withWallpaper(String wallpaperId) {
    command += " --bg $wallpaperId";
  }

  void withScaling(WpeScaling scaling) {
    switch (scaling) {
      case WpeScaling.stretch:
        command += " --scaling stretch";
        break;
      case WpeScaling.fit:
        command += " --scaling fit";
        break;
      case WpeScaling.fill:
        command += " --scaling fill";
        break;
    }
  }

  void withFPS(int fps) {
    if (!wpeSupportedFps.contains(fps)) {
      throw Exception("Unsupported FPS: $fps");
    }
    command += " --fps $fps";
  }

  void withMonitor(String monitorName) {
    command += " --screen-root $monitorName";
  }

  void withSilentMode(bool silent) {
    if (silent) {
      command += " --silent";
    }
  }

  void withNoParallax(bool noParallax) {
    if (noParallax) {
      command += " --disable-parallax";
    }
  }

  String build() {
    return command;
  }
}

Future<void> killWpe() async {
  // Use pkill with exact match to avoid killing unrelated processes
  // The -x flag matches the exact process name
  try {
    await Process.run('pkill', ['-x', 'linux-wallpaperengine']);
  } catch (_) {
    // Ignore errors if no process was found
  }
  // Give it a moment to terminate
  await Future.delayed(const Duration(milliseconds: 300));
}

/// Launches linux-wallpaperengine with the given options.
/// Returns the command that was executed (useful for debugging).
/// Throws an exception if the process fails to start.
Future<String> launchWpe(
  List<WpeLaunchOptions> options, {
  int fps = 30,
  bool silent = false,
  bool noParallax = false,
}) async {
  await killWpe();

  if (options.isEmpty) {
    throw Exception('No wallpaper configurations provided');
  }

  final builder = WpeCommandBuilder();

  // Global options (--fps, --silent, --disable-parallax apply to all monitors)
  builder.withFPS(fps);
  builder.withSilentMode(silent);
  builder.withNoParallax(noParallax);

  // Per-monitor options
  for (var option in options) {
    builder.withMonitor(option.monitorName);
    builder.withScaling(option.scaling);
    builder.withWallpaper(option.wallpaperId);
  }

  final command = builder.build();

  if (kDebugMode) {
    print("Launching WPE with command: $command");
  }

  // First check if linux-wallpaperengine exists
  final whichResult = await Process.run('which', ['linux-wallpaperengine']);
  if (whichResult.exitCode != 0) {
    throw Exception(
      'linux-wallpaperengine not found in PATH. '
      'Please install it from https://github.com/Almamu/linux-wallpaperengine',
    );
  }

  // Start the process detached so it survives if this app closes
  // Using Process.start with detached mode
  try {
    final parts = command.split(' ').where((s) => s.isNotEmpty).toList();
    final executable = parts.first;
    final args = parts.skip(1).toList();

    await Process.start(
      executable,
      args,
      mode: ProcessStartMode.detachedWithStdio,
    );
  } catch (e) {
    throw Exception('Failed to launch linux-wallpaperengine: $e');
  }

  // Give the process a moment to start
  await Future.delayed(const Duration(milliseconds: 300));

  if (kDebugMode) {
    print("WPE process started successfully");
  }

  return command;
}

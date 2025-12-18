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

void killWpe() {
  Process.run('pkill', ['-f', 'linux-wallpaperengine']);
}

void launchWpe(
  List<WpeLaunchOptions> options, {
  int fps = 30,
  bool silent = false,
  bool noParallax = false,
}) {
  killWpe();
  final builder = WpeCommandBuilder();

  // Apply global options first (or anywhere, order usually doesn't matter for flags,
  // but for clarity let's do it once if the tool supports it globally.
  // Based on "linux-wallpaperengine supports it via one command spawning one process for each monitor",
  // usually flags like --fps are global or per-process.
  // If we spawn one process per monitor via one command line, we might need to repeat flags
  // or put them at the start.
  // Assuming the tool parses arguments sequentially: [global options] [monitor1 options] [monitor2 options]
  // OR [monitor1 options] [monitor2 options] where options are repeated.
  // The user said "dispatching the command creates two or more processes... linux-wallpaperengine supports it via one command".
  // Typically this looks like: linux-wallpaperengine --screen-root DP-1 --bg 123 --screen-root DP-2 --bg 456
  // Global flags like --fps might apply to all if placed at start, or need repetition.
  // Let's assume global flags apply to the whole session or need to be repeated.
  // To be safe and consistent with previous logic, let's apply them for EACH monitor block if the tool requires it,
  // OR just once if it's a global setting for the daemon.
  // However, the user explicitly said "you can't declare --silent --fps --disable-parallax for each wallpaper".
  // This implies they ARE global. So we should append them ONCE.

  builder.withFPS(fps);
  builder.withSilentMode(silent);
  builder.withNoParallax(noParallax);

  for (var option in options) {
    builder.withMonitor(option.monitorName);
    builder.withScaling(option.scaling);
    builder.withWallpaper(option.wallpaperId);
  }

  final command = builder.build();
  if (kDebugMode) {
    print("Launching WPE with command: $command");
  }
  Process.start('bash', ['-c', command]);
}

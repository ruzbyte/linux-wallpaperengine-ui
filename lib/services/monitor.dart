import 'dart:convert';
import 'dart:io';

enum Compositor {
  hyprland,
  niri,
  sway,
  kde,
  cosmic,
  wlroots, // Generic wlroots-based (uses wlr-randr)
  unknown,
}

class Monitor {
  /// Detects the current compositor/DE based on environment variables
  static Compositor detectCompositor() {
    final env = Platform.environment;

    if (env.containsKey('HYPRLAND_INSTANCE_SIGNATURE')) {
      return Compositor.hyprland;
    }
    if (env.containsKey('NIRI_SOCKET')) {
      return Compositor.niri;
    }
    if (env.containsKey('SWAYSOCK')) {
      return Compositor.sway;
    }
    if (env.containsKey('COSMIC_SESSION_SOCK')) {
      return Compositor.cosmic;
    }
    if (env['XDG_CURRENT_DESKTOP']?.toLowerCase().contains('kde') == true ||
        env['KDE_FULL_SESSION'] == 'true') {
      return Compositor.kde;
    }
    // Check for generic wlroots-based compositors
    if (env.containsKey('WAYLAND_DISPLAY')) {
      return Compositor.wlroots;
    }

    return Compositor.unknown;
  }

  /// Gets monitor IDs as a list of strings, supporting multiple compositors
  static Future<List<String>> getMonitorNames() async {
    final compositor = detectCompositor();

    switch (compositor) {
      case Compositor.hyprland:
        return _getHyprlandMonitors();
      case Compositor.niri:
        return _getNiriMonitors();
      case Compositor.sway:
        return _getSwayMonitors();
      case Compositor.kde:
        return _getKdeMonitors();
      case Compositor.cosmic:
        return _getCosmicMonitors();
      case Compositor.wlroots:
        return _getWlrRandrMonitors();
      case Compositor.unknown:
        // Try fallback methods in order
        return _getFallbackMonitors();
    }
  }

  /// Hyprland: Uses hyprctl monitors -j
  static Future<List<String>> _getHyprlandMonitors() async {
    final result = await Process.run('bash', ['-c', 'hyprctl monitors -j']);

    if (result.exitCode != 0) {
      throw Exception('Failed to get Hyprland monitors: ${result.stderr}');
    }

    final List<dynamic> monitors = jsonDecode(result.stdout);
    return monitors.map<String>((m) => m['name'] as String).toList();
  }

  /// Niri: Uses niri msg --json outputs
  static Future<List<String>> _getNiriMonitors() async {
    final result = await Process.run('bash', ['-c', 'niri msg --json outputs']);

    if (result.exitCode != 0) {
      throw Exception('Failed to get Niri monitors: ${result.stderr}');
    }

    final Map<String, dynamic> outputs = jsonDecode(result.stdout);
    return outputs.keys.toList();
  }

  /// Sway: Uses swaymsg -t get_outputs
  static Future<List<String>> _getSwayMonitors() async {
    final result = await Process.run('bash', [
      '-c',
      'swaymsg -t get_outputs --raw',
    ]);

    if (result.exitCode != 0) {
      throw Exception('Failed to get Sway monitors: ${result.stderr}');
    }

    final List<dynamic> outputs = jsonDecode(result.stdout);
    return outputs.map<String>((o) => o['name'] as String).toList();
  }

  /// KDE: Uses kscreen-doctor -o (output list)
  static Future<List<String>> _getKdeMonitors() async {
    // Try kscreen-doctor first
    var result = await Process.run('bash', [
      '-c',
      'kscreen-doctor --json 2>/dev/null',
    ]);

    if (result.exitCode == 0) {
      try {
        final Map<String, dynamic> data = jsonDecode(result.stdout);
        if (data.containsKey('outputs')) {
          final List<dynamic> outputs = data['outputs'];
          return outputs.map<String>((o) => o['name'] as String).toList();
        }
      } catch (_) {
        // JSON parsing failed, try alternative
      }
    }

    // Fallback: parse kscreen-doctor text output
    result = await Process.run('bash', ['-c', 'kscreen-doctor -o']);

    if (result.exitCode != 0) {
      throw Exception('Failed to get KDE monitors: ${result.stderr}');
    }

    // Parse output like "Output: 1 DP-1 enabled..."
    final lines = (result.stdout as String).split('\n');
    final monitors = <String>[];
    for (final line in lines) {
      final match = RegExp(r'Output:\s*\d+\s+(\S+)').firstMatch(line);
      if (match != null) {
        monitors.add(match.group(1)!);
      }
    }

    if (monitors.isEmpty) {
      throw Exception('No KDE monitors found');
    }

    return monitors;
  }

  /// COSMIC: Uses cosmic-randr list --json
  static Future<List<String>> _getCosmicMonitors() async {
    // Try JSON output first
    var result = await Process.run('bash', [
      '-c',
      'cosmic-randr list --json 2>/dev/null',
    ]);

    if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
      try {
        final data = jsonDecode(result.stdout);
        if (data is List) {
          return data.map<String>((o) => o['name'] as String).toList();
        } else if (data is Map && data.containsKey('outputs')) {
          final List<dynamic> outputs = data['outputs'];
          return outputs.map<String>((o) => o['name'] as String).toList();
        }
      } catch (_) {
        // JSON parsing failed, try text parsing
      }
    }

    // Fallback: parse cosmic-randr text output
    result = await Process.run('bash', ['-c', 'cosmic-randr list']);

    if (result.exitCode != 0) {
      throw Exception('Failed to get COSMIC monitors: ${result.stderr}');
    }

    // Parse output - look for output names
    final lines = (result.stdout as String).split('\n');
    final monitors = <String>[];
    for (final line in lines) {
      // Match lines like "DP-1:" or "HDMI-A-1:"
      final match = RegExp(r'^([A-Za-z0-9\-]+):').firstMatch(line.trim());
      if (match != null) {
        monitors.add(match.group(1)!);
      }
    }

    if (monitors.isEmpty) {
      throw Exception('No COSMIC monitors found');
    }

    return monitors;
  }

  /// Generic wlroots: Uses wlr-randr
  static Future<List<String>> _getWlrRandrMonitors() async {
    final result = await Process.run('bash', [
      '-c',
      'wlr-randr --json 2>/dev/null',
    ]);

    if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
      try {
        final List<dynamic> outputs = jsonDecode(result.stdout);
        return outputs.map<String>((o) => o['name'] as String).toList();
      } catch (_) {
        // JSON not supported, parse text output
      }
    }

    // Fallback: parse wlr-randr text output
    final textResult = await Process.run('bash', ['-c', 'wlr-randr']);

    if (textResult.exitCode != 0) {
      throw Exception('Failed to get wlr-randr monitors: ${textResult.stderr}');
    }

    // Parse output like "DP-1 \"...\""
    final lines = (textResult.stdout as String).split('\n');
    final monitors = <String>[];
    for (final line in lines) {
      // Lines starting without whitespace are output names
      if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t')) {
        final name = line.split(' ').first;
        if (name.isNotEmpty) {
          monitors.add(name);
        }
      }
    }

    if (monitors.isEmpty) {
      throw Exception('No wlr-randr monitors found');
    }

    return monitors;
  }

  /// Fallback: Try multiple methods in order
  static Future<List<String>> _getFallbackMonitors() async {
    final methods = [_getWlrRandrMonitors, _getKdeMonitors, _getCosmicMonitors];

    for (final method in methods) {
      try {
        return await method();
      } catch (_) {
        // Try next method
      }
    }

    throw Exception(
      'Unable to detect monitors. Supported compositors: '
      'Hyprland, Niri, Sway, KDE Plasma, COSMIC, and wlroots-based (via wlr-randr)',
    );
  }

  // Legacy methods for backwards compatibility
  @Deprecated('Use getMonitorNames() directly instead')
  static Future<dynamic> getMonitors() async {
    final compositor = detectCompositor();

    switch (compositor) {
      case Compositor.hyprland:
        final result = await Process.run('bash', ['-c', 'hyprctl monitors -j']);
        if (result.exitCode != 0) {
          throw Exception('Failed to get monitors: ${result.stderr}');
        }
        return jsonDecode(result.stdout);

      case Compositor.niri:
        final result = await Process.run('bash', [
          '-c',
          'niri msg --json outputs',
        ]);
        if (result.exitCode != 0) {
          throw Exception('Failed to get monitors: ${result.stderr}');
        }
        return jsonDecode(result.stdout);

      default:
        // For other compositors, return a simple map structure
        final names = await getMonitorNames();
        return {
          for (final name in names) name: {'name': name},
        };
    }
  }

  @Deprecated('Use getMonitorNames() directly instead')
  static bool isOnHyprland() {
    return Platform.environment.containsKey('HYPRLAND_INSTANCE_SIGNATURE');
  }
}

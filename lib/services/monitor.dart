import 'dart:convert';
import 'dart:io';

class Monitor {
  static const String hyprCommand = "hyprctl monitors -j";
  static const String niriCommand = "niri msg --json outputs";

  static Future<dynamic> getMonitors() async {
    String command = isOnHyprland() ? hyprCommand : niriCommand;

    final result = await Process.run('bash', ['-c', command]);

    if (result.exitCode != 0) {
      throw Exception('Failed to get monitors: ${result.stderr}');
    }

    return jsonDecode(result.stdout);
  }

  static bool isOnHyprland() {
    return Platform.environment.containsKey('HYPRLAND_INSTANCE_SIGNATURE');
  }

  static List<String> getMonitorNames(dynamic monitorsJson) {
    return isOnHyprland()
        ? monitorsJson.map<String>((m) => m['name'] as String).toList()
        : monitorsJson["Outputs"].map((m) => m['name'] as String).toList();
  }
}

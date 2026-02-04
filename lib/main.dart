import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wpeui/services/workshop.dart';
import 'package:wpeui/services/wpe.dart';
import 'package:wpeui/services/monitor.dart';
import 'package:wpeui/state/app_state.dart';

Map<String, String> cliOptions = {
  "--help": "Show help information",
  "--nogui": "Run Wallpaper Engine without UI",
  "--apply": "Apply current configuration and exit",
  "--version": "Show application version",
};

void echoHelp() {
  stdout.writeln('Wallpaper Engine UI - Command Line Options:');
  cliOptions.forEach((option, description) {
    stdout.writeln('$option: $description');
  });
}

void echoVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  stdout.writeln('Wallpaper Engine UI - Version ${packageInfo.version}');
}

Future<void> applyNogui() async {
  final appState = AppState();

  // Wait for AppState to load configuration
  await appState.configLoaded;

  final configs = appState.monitorConfigs.values.toList();

  if (configs.isEmpty) {
    stderr.writeln('Error: No monitor configurations found to apply.');
    stderr.writeln('Please configure wallpapers using the GUI first.');
    exit(1);
  }

  try {
    final command = await launchWpe(
      configs,
      fps: appState.fps,
      silent: appState.silent,
      noParallax: appState.noParallax,
    );
    stdout.writeln('Wallpaper engine started successfully.');
    stdout.writeln('Command: $command');
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (args.contains('--help')) {
    echoHelp();
    exit(0);
  }

  if (args.contains('--version')) {
    echoVersion();
    exit(0);
  }

  if (args.contains("--nogui") || args.contains("--apply")) {
    await applyNogui();
    if (args.contains("--nogui")) {
      exit(0);
    }
  }

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper Engine UI',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Color(0xFF2D2D2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Colors.white10),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[WorkshopBrowser(), MonitorsTab()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor), label: 'Monitors'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MonitorsTab extends StatelessWidget {
  const MonitorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, child) {
        final appState = AppState();
        final configs = appState.monitorConfigs;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Monitor Configuration'),
            actions: [
              if (configs.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    appState.clearAll();
                  },
                  tooltip: 'Clear All',
                ),
            ],
          ),
          body: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Global Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('FPS:'),
                          const SizedBox(width: 16),
                          DropdownButton<int>(
                            value: appState.fps,
                            items: wpeSupportedFps.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                appState.setGlobalOptions(fps: newValue);
                              }
                            },
                          ),
                        ],
                      ),
                      SwitchListTile(
                        title: const Text('Silent Mode'),
                        value: appState.silent,
                        onChanged: (bool value) {
                          appState.setGlobalOptions(silent: value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Disable Parallax'),
                        value: appState.noParallax,
                        onChanged: (bool value) {
                          appState.setGlobalOptions(noParallax: value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Hide Window Decorations'),
                        value: appState.hideWindowDecorations,
                        onChanged: (bool value) {
                          appState.setGlobalOptions(
                            hideWindowDecorations: value,
                          );
                        },
                      ),
                      if (appState.workshopPath != null) ...[
                        const Divider(),
                        ListTile(
                          title: const Text('Workshop Path'),
                          subtitle: Text(
                            appState.workshopPath!,
                            style: const TextStyle(fontSize: 12),
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                child: configs.isEmpty
                    ? const Center(child: Text('No configurations set.'))
                    : ListView.builder(
                        itemCount: configs.length,
                        itemBuilder: (context, index) {
                          final monitorName = configs.keys.elementAt(index);
                          final config = configs[monitorName]!;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              leading: config.item != null
                                  ? Image.file(
                                      File(config.item!.preview),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.wallpaper),
                              title: Text('Monitor: $monitorName'),
                              subtitle: Text(
                                'Wallpaper: ${config.item?.name ?? config.wallpaperId}\nScaling: ${config.scaling.name}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  appState.removeConfiguration(monitorName);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: configs.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    try {
                      await launchWpe(
                        configs.values.toList(),
                        fps: appState.fps,
                        silent: appState.silent,
                        noParallax: appState.noParallax,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wallpaper applied successfully!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  },
                  label: const Text('Apply All'),
                  icon: const Icon(Icons.check),
                )
              : null,
        );
      },
    );
  }
}

class WorkshopBrowser extends StatefulWidget {
  const WorkshopBrowser({super.key});

  @override
  State<WorkshopBrowser> createState() => _WorkshopBrowserState();
}

class _WorkshopBrowserState extends State<WorkshopBrowser> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _lastWorkshopPath;
  Future<List<WorkshopItem>>? _workshopItemsFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, child) {
        final workshopPath = AppState().workshopPath;

        if (workshopPath != _lastWorkshopPath) {
          _lastWorkshopPath = workshopPath;
          if (workshopPath != null) {
            // Wrapping in a Future to allow UI to render initial state
            _workshopItemsFuture = Future(
              () => Workshop.getAllOfDirectory(workshopPath),
            );
          } else {
            _workshopItemsFuture = null;
          }
        }

        if (workshopPath == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Workshop Browser')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Wallpaper Engine Workshop path not found.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      String? selectedDirectory = await FilePicker.platform
                          .getDirectoryPath();
                      if (selectedDirectory != null) {
                        AppState().setWorkshopPath(selectedDirectory);
                      }
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Select Workshop Path'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select the folder containing "431960" or the "431960" folder itself.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Workshop Browser'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search wallpapers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.folder),
                tooltip: 'Change Workshop Path',
                onPressed: () async {
                  String? selectedDirectory = await FilePicker.platform
                      .getDirectoryPath();
                  if (selectedDirectory != null) {
                    AppState().setWorkshopPath(selectedDirectory);
                  }
                },
              ),
            ],
          ),
          body: FutureBuilder<List<WorkshopItem>>(
            future: _workshopItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No items found.'));
              }

              final allItems = snapshot.data!;
              final items = allItems.where((item) {
                return item.name.toLowerCase().contains(_searchQuery);
              }).toList();

              if (items.isEmpty) {
                return const Center(
                  child: Text('No matching wallpapers found.'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Adjust as needed
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return WorkshopItemCard(item: item);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class WorkshopItemCard extends StatelessWidget {
  final WorkshopItem item;

  const WorkshopItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkshopItemDetail(item: item),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.file(
                File(item.preview),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.name,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkshopItemDetail extends StatefulWidget {
  final WorkshopItem item;

  const WorkshopItemDetail({super.key, required this.item});

  @override
  State<WorkshopItemDetail> createState() => _WorkshopItemDetailState();
}

class _WorkshopItemDetailState extends State<WorkshopItemDetail> {
  List<String> _monitors = [];
  String? _selectedMonitor;
  WpeScaling _selectedScaling = WpeScaling.fill;
  bool _loadingMonitors = true;
  String? _monitorError;

  @override
  void initState() {
    super.initState();
    _loadMonitors();
  }

  Future<void> _loadMonitors() async {
    try {
      final names = await Monitor.getMonitorNames();
      if (mounted) {
        setState(() {
          _monitors = names;
          if (_monitors.isNotEmpty) {
            _selectedMonitor = _monitors.first;
          }
          _loadingMonitors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _monitorError = e.toString();
          _loadingMonitors = false;
        });
      }
    }
  }

  void _addToConfig() {
    if (_selectedMonitor == null) return;
    final options = WpeLaunchOptions(
      wallpaperId: widget.item.id,
      monitorName: _selectedMonitor!,
      scaling: _selectedScaling,
      item: widget.item,
    );
    AppState().setConfiguration(_selectedMonitor!, options);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added configuration for $_selectedMonitor')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.item.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Configure'),
              Tab(text: 'Info'),
              Tab(text: 'Raw Metadata'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildLaunchTab(), _buildInfoTab(context), _buildRawTab()],
        ),
      ),
    );
  }

  Widget _buildLaunchTab() {
    if (_loadingMonitors) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_monitorError != null) {
      return Center(child: Text('Error loading monitors: $_monitorError'));
    }
    if (_monitors.isEmpty) {
      return const Center(child: Text('No monitors found.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedMonitor,
            decoration: const InputDecoration(
              labelText: 'Monitor',
              border: OutlineInputBorder(),
            ),
            items: _monitors
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _selectedMonitor = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<WpeScaling>(
            value: _selectedScaling,
            decoration: const InputDecoration(
              labelText: 'Scaling',
              border: OutlineInputBorder(),
            ),
            items: WpeScaling.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedScaling = v!),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _addToConfig,
              icon: const Icon(Icons.save),
              label: const Text('Set for Monitor'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Image.file(
                File(widget.item.preview),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 100);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Title: ${widget.item.name}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('ID: ${widget.item.id}'),
          const SizedBox(height: 8),
          if (widget.item.metadata.description != null) ...[
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.item.metadata.description!),
            const SizedBox(height: 8),
          ],
          if (widget.item.metadata.tags != null) ...[
            Text('Tags:', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8.0,
              children: widget.item.metadata.tags!
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRawTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: SelectableText(widget.item.metadata.toJson().toString()),
    );
  }
}

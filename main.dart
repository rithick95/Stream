import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CloudStream',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0C111B),
          colorScheme: const ColorScheme.dark(primary: Color(0xFF1F80E0)),
        ),
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  final pages = const [
    HomePage(),
    Center(child: Text('Downloads')),
    Center(child: Text('Settings'))
  ];
  static const dests = [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.download), label: 'Downloads'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      body: Row(children: [
        if (wide)
          NavigationRail(
            selectedIndex: i,
            onDestinationSelected: (v) => setState(() => i = v),
            labelType: NavigationRailLabelType.all,
            destinations: dests
                .map((d) => NavigationRailDestination(
                    icon: d.icon, label: Text(d.label)))
                .toList(),
          ),
        Expanded(child: pages[i]),
      ]),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: i,
              onDestinationSelected: (v) => setState(() => i = v),
              destinations: dests),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final c = TextEditingController();
  String status = 'Paste a folder, channel or direct video link';

  String detect(String u) {
    if (u.contains('drive.google.com')) return 'Google Drive';
    if (u.contains('dropbox.com')) return 'Dropbox';
    if (u.contains('onedrive') || u.contains('1drv.ms')) return 'OneDrive';
    if (u.contains('mega.nz')) return 'Mega';
    if (u.contains('t.me')) return 'Telegram';
    if (RegExp(r'\.(mp4|mkv|m3u8|webm)(\?|$)').hasMatch(u)) {
      return 'Direct video';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CloudStream',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: c,
              decoration: const InputDecoration(
                  hintText: 'Paste link here', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton(
                onPressed: () =>
                    setState(() => status = 'Detected: ${detect(c.text.trim())}'),
                child: const Text('Load'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  final u = c.text.trim();
                  if (u.isEmpty) return;
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PlayerPage(url: u)));
                },
                child: const Text('Play test'),
              ),
            ]),
            const SizedBox(height: 20),
            Text(status),
          ]),
        ),
      );
}

class PlayerPage extends StatefulWidget {
  final String url;
  const PlayerPage({super.key, required this.url});
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(Media(widget.url));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Playing')),
        body: Video(controller: controller),
      );
}

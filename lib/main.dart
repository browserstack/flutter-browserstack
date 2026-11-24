import 'package:flutter/material.dart';

void main() => runApp(const SampleApp());

class SampleApp extends StatelessWidget {
  const SampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'BrowserStack Flutter sample', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 0;
  String _greeting = '';
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              key: const Key('details'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DetailsPage())),
              child: const Text('Open details'),
            ),
            Text('Count: $_count', key: const Key('count')),
            ElevatedButton(
              key: const Key('increment'),
              onPressed: () => setState(() => _count++),
              child: const Text('Increment'),
            ),
            TextField(
              key: const Key('name'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            ElevatedButton(
              key: const Key('greet'),
              onPressed: () => setState(() => _greeting = 'Hello, ${_name.text}'),
              child: const Text('Greet'),
            ),
            Text(_greeting, key: const Key('greeting')),
            // Accessibility issues on purpose, so the App Accessibility report has something to show:
            // a tappable icon with no label, and text too small to read.
            GestureDetector(key: const Key('unlabeled-icon'), onTap: () {}, child: const Icon(Icons.favorite, size: 48)),
            const Text('Tiny text', style: TextStyle(fontSize: 7)),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: const Center(child: Text('Details page body')),
    );
  }
}

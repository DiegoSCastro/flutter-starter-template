import 'package:flutter/material.dart';

/// Entry point scaffolded by `bin/create_from_template.sh`.
///
/// The original template's main wires up Firebase / ObjectBox / DI /
/// go_router / etc. To keep a freshly scaffolded project free of any
/// optional-service configuration, this minimal main is written instead.
/// Replace it with your real `runApp(const MyApp())` once you have
/// your feature tree in place.
void main() {
  runApp(const ScaffoldApp());
}

class ScaffoldApp extends StatelessWidget {
  const ScaffoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scaffold',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _ScaffoldHome(),
    );
  }
}

class _ScaffoldHome extends StatelessWidget {
  const _ScaffoldHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scaffold')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Project scaffolded from flutter-starter-template.'),
            SizedBox(height: 8),
            Text('Replace lib/main.dart with your real entry point.'),
          ],
        ),
      ),
    );
  }
}

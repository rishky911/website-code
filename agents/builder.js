import { Command } from 'commander';
import fs from 'fs-extra';
import path from 'path';

const program = new Command();

program
  .name('builder')
  .description('Template & Module Builder Agent')
  .version('1.0.0');

program
  .command('build <appName>')
  .option('-m, --modules <modules>', 'Comma-separated list of modules')
  .action(async (appName, options) => {
    console.log(`    🔨 Building ${appName} with modules: ${options.modules}`);

    const appDir = path.join('..', 'apps', appName);
    const modules = options.modules ? options.modules.split(',') : [];

    // 1. Create App Directory (Simulation of cloning template)
    await fs.ensureDir(appDir);

    // 2. Create pubspec.yaml
    const pubspecContent = `
name: ${appName}
description: Generated app ${appName}
version: 1.0.0+1
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
${modules.map(m => `  ${m}:\n    path: ../../modules/${m}`).join('\n')}

dev_dependencies:
  flutter_test:
    sdk: flutter
`;
    await fs.writeFile(path.join(appDir, 'pubspec.yaml'), pubspecContent.trim());

    // 3. Create main.dart
    const mainContent = `
import 'package:flutter/material.dart';
${modules.map(m => `import 'package:${m}/${m}.dart';`).join('\n')}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${appName.replace(/_/g, ' ')}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${appName}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ${appName}'),
            const SizedBox(height: 20),
            const Text('Modules Loaded:', style: TextStyle(fontWeight: FontWeight.bold)),
            ${modules.map(m => `const Text('✅ ${m}'),`).join('\n            ')}
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simulate module action
          print('Action triggered for ${appName}');
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
`;
    await fs.ensureDir(path.join(appDir, 'lib'));
    await fs.writeFile(path.join(appDir, 'lib', 'main.dart'), mainContent.trim());

    console.log(`    ✅ ${appName} assembled at ${appDir}`);
  });

program.parse();

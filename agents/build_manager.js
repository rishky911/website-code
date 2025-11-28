import { Command } from 'commander';
import fs from 'fs-extra';
import path from 'path';

const program = new Command();

program
  .name('build_manager')
  .description('Build & CI Pipeline Manager Agent')
  .version('1.0.0');

program
  .command('config <appName>')
  .action(async (appName) => {
    console.log(`    ⚙️  Configuring CI pipeline for ${appName}...`);

    const appDir = path.join('..', 'apps', appName);
    const workflowsDir = path.join(appDir, '.github', 'workflows');

    await fs.ensureDir(workflowsDir);

    const workflowContent = `
name: Build ${appName}

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
    - run: flutter pub get
    - run: flutter test
    - run: flutter build apk
    - uses: actions/upload-artifact@v4
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
`;
    await fs.writeFile(path.join(workflowsDir, 'main.yml'), workflowContent.trim());

    console.log(`    ✅ CI workflow created at ${workflowsDir}/main.yml`);
  });

program.parse();

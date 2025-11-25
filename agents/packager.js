import { Command } from 'commander';
import fs from 'fs-extra';
import path from 'path';

const program = new Command();

program
    .name('packager')
    .description('Publish & Handover Packager Agent')
    .version('1.0.0');

program
    .command('package <appName>')
    .action(async (appName) => {
        console.log(`    📦 Packaging handover for ${appName}...`);

        const appDir = path.join('..', 'apps', appName);
        const handoverDir = path.join(appDir, 'handover');
        await fs.ensureDir(handoverDir);

        // Simulate copying artifacts
        await fs.writeFile(path.join(handoverDir, 'app-release.apk'), 'DUMMY APK CONTENT');
        await fs.writeFile(path.join(handoverDir, 'instructions.txt'), 'Here is your app. Enjoy!');

        console.log(`    ✅ Handover package created at ${handoverDir}`);
    });

program.parse();

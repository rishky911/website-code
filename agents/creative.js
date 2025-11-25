import { Command } from 'commander';
import fs from 'fs-extra';
import path from 'path';

const program = new Command();

program
    .name('creative')
    .description('Asset & Creative Generator Agent')
    .version('1.0.0');

program
    .command('generate <appName>')
    .action(async (appName) => {
        console.log(`    🎨 Generating assets for ${appName}...`);

        const appDir = path.join('..', 'apps', appName);
        const assetsDir = path.join(appDir, 'assets');

        await fs.ensureDir(assetsDir);

        // Create dummy icons
        await fs.writeFile(path.join(assetsDir, 'icon_1024.png'), 'DUMMY ICON CONTENT');
        await fs.writeFile(path.join(assetsDir, 'icon_512.png'), 'DUMMY ICON CONTENT');

        // Create ASO metadata
        const asoContent = {
            title: appName.replace(/_/g, ' '),
            shortDescription: `The best ${appName} app ever.`,
            fullDescription: `Download this amazing ${appName} now. It features state of the art modules.`,
            keywords: [appName, 'flutter', 'demo']
        };

        await fs.writeFile(path.join(appDir, 'aso_metadata.json'), JSON.stringify(asoContent, null, 2));

        console.log(`    ✅ Assets generated in ${assetsDir}`);
    });

program.parse();

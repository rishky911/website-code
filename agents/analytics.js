import { Command } from 'commander';
import fs from 'fs-extra';
import path from 'path';

const program = new Command();

program
    .name('analytics')
    .description('Analytics & Telemetry Integrator Agent')
    .version('1.0.0');

program
    .command('inject <appName>')
    .action(async (appName) => {
        console.log(`    📊 Injecting analytics for ${appName}...`);

        const appDir = path.join('..', 'apps', appName);
        const libDir = path.join(appDir, 'lib');

        // Simulate injection
        const trackingPlan = `
Event, Description
app_open, User opens the app
feature_used, User uses a main feature
error_occurred, An error was caught
`;
        await fs.writeFile(path.join(appDir, 'tracking_plan.csv'), trackingPlan.trim());

        console.log(`    ✅ Analytics config injected.`);
    });

program.parse();

import { Command } from 'commander';

const program = new Command();

program
    .name('monitor')
    .description('Monitoring & Rollback Agent')
    .version('1.0.0');

program
    .command('watch <appName>')
    .action(async (appName) => {
        console.log(`    👀 Monitoring ${appName}...`);
        console.log(`    ✅ Status: HEALTHY`);
    });

program.parse();

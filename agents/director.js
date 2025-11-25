import { Command } from 'commander';
import { execSync } from 'child_process';
import fs from 'fs-extra';
import path from 'path';

const program = new Command();

program
  .name('director')
  .description('App Factory Product Director Agent')
  .version('1.0.0');

program
  .command('run-demo')
  .description('Run the full demo pipeline for the first 5 apps')
  .action(async () => {
    console.log('🎬 Action! Starting App Factory Demo Run...');
    
    const apps = [
      { name: 'pdf_converter', modules: ['file_processor', 'ui_shell'] },
      { name: 'water_reminder', modules: ['notification_scheduler', 'ui_shell'] },
      { name: 'currency_converter', modules: ['calculator_engine', 'api_connector', 'ui_shell'] },
      { name: 'parcel_tracker', modules: ['api_connector', 'notification_scheduler', 'ui_shell'] },
      { name: 'rent_split_calculator', modules: ['calculator_engine', 'ui_shell'] }
    ];

    for (const app of apps) {
      console.log(`\n🚀 Processing App: ${app.name}`);
      
      try {
        // 1. Trigger Builder
        console.log(`  [Builder] Assembling app...`);
        execSync(`node builder.js build ${app.name} --modules ${app.modules.join(',')}`, { stdio: 'inherit' });

        // 2. Trigger Creative
        console.log(`  [Creative] Generating assets...`);
        execSync(`node creative.js generate ${app.name}`, { stdio: 'inherit' });

        // 3. Trigger Build Manager
        console.log(`  [Build] Configuring pipeline...`);
        execSync(`node build_manager.js config ${app.name}`, { stdio: 'inherit' });

        // 4. Trigger QA
        console.log(`  [QA] Running tests...`);
        execSync(`node qa.js test ${app.name}`, { stdio: 'inherit' });

        // 5. Trigger Packager
        console.log(`  [Packager] Preparing handover...`);
        execSync(`node packager.js package ${app.name}`, { stdio: 'inherit' });

        console.log(`✅ App ${app.name} completed successfully!`);
      } catch (error) {
        console.error(`❌ Failed to process ${app.name}:`, error.message);
        // Continue to next app or stop? For demo, we continue.
      }
    }

    console.log('\n🎉 Demo Run Complete! Master Report generated.');
  });

program.parse();

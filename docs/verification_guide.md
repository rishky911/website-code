# App Factory Verification & Testing Guide

## 1. Verify Generated Apps
Navigate to the `apps` directory. You should see folders for all 5 apps:
- `pdf_converter`
- `water_reminder`
- `currency_converter`
- `parcel_tracker`
- `rent_split_calculator`

### Check App Structure
Open any app folder (e.g., `apps/pdf_converter`) and verify:
- `pubspec.yaml`: Should list the correct modules as dependencies.
- `lib/main.dart`: Should import the modules and have a basic UI.
- `assets/`: Should contain generated icons (`icon_1024.png`, etc.).
- `handover/`: Should contain the "ZIP" artifacts and instructions.
- `test_reports/`: Should contain the test summary.

## 2. Run the Orchestrator Manually
You can re-run the full demo pipeline to see the agents in action.

**Command:**
```bash
cd agents
node director.js run-demo
```

## 3. Test Individual Agents
You can also run specific agents to perform isolated tasks.

**Builder Agent (Create a new test app):**
```bash
node builder.js build test_app --modules ui_shell,file_processor
```

**Creative Agent (Generate assets for test app):**
```bash
node creative.js generate test_app
```

## 4. Review Documentation
- **Master Report**: `docs/Master_Run_Report.md` (Summary of the last run).
- **Module SOPs**: `docs/modules/` (Documentation for each Flutter module).

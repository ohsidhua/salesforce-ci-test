# Salesforce CI/CD Test Repository

[![Scheduled Salesforce Apex Tests](https://github.com/YOUR-USERNAME/salesforce-ci-test/actions/workflows/scheduled-apex-tests.yml/badge.svg)](https://github.com/YOUR-USERNAME/salesforce-ci-test/actions/workflows/scheduled-apex-tests.yml)

Automated Salesforce Apex testing with GitHub Actions and Slack notifications.

## 🚀 Features

- ⏰ **Scheduled Testing**: Automatic test runs every Monday at 8 AM UTC
- 📊 **Code Coverage Reports**: Detailed coverage analysis per class
- 💬 **Slack Integration**: Real-time notifications with test results
- 🔄 **CI/CD Ready**: GitHub Actions workflow for continuous testing
- 🎯 **Multi-Environment Support**: Configurable for different Salesforce orgs
- 📦 **Test Artifacts**: 30-day retention of test results and reports

## 📋 Quick Start

**New to this setup?** Follow the [**Quick Setup Guide**](SETUP_GUIDE.md) for step-by-step instructions (5 minutes).

**Already familiar with GitHub Actions?** See [**Workflow Documentation**](.github/workflows/README.md) for detailed configuration.

## 🛠️ Setup Overview

### 1. Prerequisites
- Salesforce org (currently configured for **DevOpsPOC**)
- Salesforce CLI installed
- GitHub repository access
- Slack workspace (optional)

### 2. Quick Setup Steps

```bash
# 1. Get your Salesforce auth URL
sf org display --target-org DevOpsPOC --verbose

# 2. Add SFDX_AUTH_URL secret to GitHub
# Go to: Settings → Secrets and variables → Actions → New repository secret

# 3. (Optional) Add SLACK_WEBHOOK_URL secret to GitHub
# Create webhook at: https://api.slack.com/apps

# 4. Push workflow to GitHub
git add .github/
git commit -m "Add scheduled Apex test workflow"
git push origin main

# 5. Test manually in GitHub Actions UI
# Go to: Actions → Scheduled Salesforce Apex Tests → Run workflow
```

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions.

## 📅 Schedule

Tests run automatically:
- **Every Monday at 8:00 AM UTC**
- Can be triggered manually via GitHub Actions UI
- Configurable schedule in workflow file

## 📊 What Gets Tested

- **Test Level**: `RunLocalTests` (default)
- **Tests Run**: All Apex tests in your org (excluding managed packages)
- **Code Coverage**: Generated for all Apex classes
- **Current Test Classes**: `SampleControllerTest`

## 🔔 Notifications

Test results are delivered via:

1. **GitHub Actions** (always)
   - Detailed logs
   - Test artifacts (JSON, text, coverage reports)
   - Pass/fail status with history

2. **Slack** (when configured)
   - Test summary (passed/failed/skipped)
   - Code coverage percentage
   - Execution time
   - Direct link to GitHub run

Example Slack notification:
```
✅ Salesforce Apex Tests - DevOpsPOC Org
Status: Passed
Total Tests: 5 | Passed: 5 | Failed: 0
Code Coverage: 85%
Execution Time: 12.5s
```

## 🧪 Testing Locally

Before pushing to GitHub, test locally:

```bash
# Run all local tests
sf apex run test --test-level RunLocalTests --code-coverage --target-org DevOpsPOC

# List available test classes
sf apex list test --target-org DevOpsPOC

# Check org status
sf org display --target-org DevOpsPOC
```

Or use the provided test script:
```bash
./scripts/test-local.sh
```

## 📁 Repository Structure

```
salesforce-ci-test/
├── .github/
│   └── workflows/
│       ├── scheduled-apex-tests.yml    # Main workflow
│       └── README.md                    # Workflow documentation
├── force-app/
│   └── main/
│       └── default/
│           └── classes/
│               ├── SampleController.cls
│               ├── SampleControllerTest.cls
│               └── ...
├── scripts/
│   └── test-local.sh                    # Local testing script
├── SETUP_GUIDE.md                       # Quick setup instructions
├── README.md                            # This file
├── sfdx-project.json                    # Salesforce project config
└── package.json                         # Node dependencies
```

## 🔧 Configuration

### Required GitHub Secrets

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `SFDX_AUTH_URL` | Salesforce org authentication | `sf org display --target-org DevOpsPOC --verbose` |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook (optional) | https://api.slack.com/apps |

### Workflow Configuration

Edit `.github/workflows/scheduled-apex-tests.yml` to customize:

- **Schedule**: Change cron expression
- **Test Level**: `RunLocalTests`, `RunAllTestsInOrg`, etc.
- **Target Org**: Change alias or add multiple orgs
- **Notifications**: Customize Slack message format

## 📈 Test Results

After each run, you can:

1. **View in GitHub Actions**
   - Go to Actions tab
   - Select the workflow run
   - View logs and download artifacts

2. **Download Artifacts** (available for 30 days)
   - `test-results.json`: Full test results in JSON format
   - `test-output.txt`: Human-readable test output
   - `coverage-report.md`: Detailed coverage per class

3. **Check Slack** (if configured)
   - Instant notification with summary
   - Link to full results in GitHub

## 🐛 Troubleshooting

### Authentication Issues
```bash
# Re-authenticate and update secret
sf org logout --target-org DevOpsPOC
sf org login web --alias DevOpsPOC --set-default
sf org display --target-org DevOpsPOC --verbose
# Copy new auth URL to GitHub secret
```

### No Tests Found
- Ensure test classes have `@isTest` annotation
- Check that classes are deployed to the org
- Verify test level is correct

### Slack Not Working
- Verify `SLACK_WEBHOOK_URL` secret is set
- Test webhook with curl:
```bash
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test message"}' \
  YOUR_WEBHOOK_URL
```

See [SETUP_GUIDE.md](SETUP_GUIDE.md#common-issues--solutions) for more troubleshooting tips.

## 📚 Documentation

- [Quick Setup Guide](SETUP_GUIDE.md) - Step-by-step setup instructions
- [Workflow Documentation](.github/workflows/README.md) - Detailed workflow reference
- [Salesforce CLI Docs](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

## 🎯 Current Configuration

- **Target Org**: DevOpsPOC
- **Test Level**: RunLocalTests
- **Schedule**: Every Monday at 8:00 AM UTC
- **API Version**: 65.0
- **Retention**: 30 days for test artifacts

## 🤝 Contributing

To add more test classes:

1. Create test class in `force-app/main/default/classes/`
2. Deploy to your org: `sf project deploy start --target-org DevOpsPOC`
3. Tests will run automatically on next scheduled run

## 📄 License

MIT

## 🔗 Resources

- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [Apex Testing Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_best_practices.htm)
- [GitHub Actions for Salesforce](https://github.com/marketplace?type=actions&query=salesforce)

---

**Ready to get started?** Follow the [Quick Setup Guide](SETUP_GUIDE.md) now!

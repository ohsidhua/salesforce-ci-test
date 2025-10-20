# Quick Reference Guide

Essential commands and information for working with the Salesforce scheduled test workflow.

## 🚀 Getting Started (First Time)

```bash
# 1. Get your auth URL
./scripts/get-auth-url.sh

# 2. Copy the auth URL and add to GitHub
# Go to: GitHub Repo → Settings → Secrets → Actions → New secret
# Name: SFDX_AUTH_URL
# Value: <paste auth URL>

# 3. (Optional) Add Slack webhook
# Name: SLACK_WEBHOOK_URL  
# Value: <your slack webhook URL>

# 4. Push to GitHub
git add .github/ scripts/ *.md .gitignore
git commit -m "Add scheduled test workflow"
git push origin main

# 5. Test manually
# Go to: GitHub → Actions → Scheduled Salesforce Apex Tests → Run workflow
```

## 🧪 Testing Commands

### Run Tests Locally
```bash
# Easy way (uses helper script)
./scripts/test-local.sh

# Full command
sf apex run test --test-level RunLocalTests --code-coverage --target-org DevOpsPOC
```

### List Available Tests
```bash
sf apex list test --target-org DevOpsPOC
```

### Check Org Status
```bash
sf org list
sf org display --target-org DevOpsPOC
```

## 🔐 Authentication

### Get Auth URL for GitHub
```bash
./scripts/get-auth-url.sh
```

### Login to Org
```bash
sf org login web --alias DevOpsPOC --set-default
```

### Logout and Re-authenticate
```bash
sf org logout --target-org DevOpsPOC
sf org login web --alias DevOpsPOC --set-default
```

### View Auth Details
```bash
sf org display --target-org DevOpsPOC --verbose
```

## 📊 GitHub Actions

### Manual Trigger
1. Go to GitHub repository
2. Click **Actions** tab
3. Select **Scheduled Salesforce Apex Tests**
4. Click **Run workflow**
5. Verify parameters and click **Run workflow**

### View Results
1. **Actions** tab → Select workflow run
2. Click on steps to see logs
3. Download artifacts at bottom of page

### Schedule
- **Default:** Every Monday at 8:00 AM UTC
- **Edit:** `.github/workflows/scheduled-apex-tests.yml`
- **Cron:** `0 8 * * 1`

### Common Schedules
```yaml
# Every day at 9 AM UTC
- cron: '0 9 * * *'

# Weekdays at 6 AM UTC  
- cron: '0 6 * * 1-5'

# Mon/Wed/Fri at 10 AM UTC
- cron: '0 10 * * 1,3,5'

# Twice a week (Mon & Thu) at 8 AM UTC
- cron: '0 8 * * 1,4'
```

## 💬 Slack Setup

### Create Webhook
1. Go to https://api.slack.com/apps
2. **Create New App** → **From scratch**
3. Name: `Salesforce Test Reporter`
4. Select workspace
5. **Incoming Webhooks** → Toggle On
6. **Add New Webhook to Workspace**
7. Select channel
8. Copy webhook URL

### Add to GitHub
1. GitHub Repo → **Settings**
2. **Secrets and variables** → **Actions**
3. **New repository secret**
4. Name: `SLACK_WEBHOOK_URL`
5. Value: `<paste webhook URL>`

### Test Webhook
```bash
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test message from Salesforce CI"}' \
  YOUR_WEBHOOK_URL
```

## 📁 File Locations

```
.github/workflows/scheduled-apex-tests.yml  # Main workflow
scripts/test-local.sh                       # Local test runner
scripts/get-auth-url.sh                     # Get auth URL helper
SETUP_GUIDE.md                              # Detailed setup guide
TESTING_CHECKLIST.md                        # Testing checklist
README.md                                   # Main documentation
```

## 🐛 Troubleshooting

### "Authentication failed"
```bash
# Regenerate auth URL
./scripts/get-auth-url.sh
# Update SFDX_AUTH_URL secret in GitHub
```

### "No tests found"
```bash
# Check test classes exist
sf apex list test --target-org DevOpsPOC

# Verify test annotation
# Test classes must have @isTest annotation
```

### "Tests failing locally"
```bash
# Run with detailed output
sf apex run test --test-level RunLocalTests --code-coverage --result-format human --target-org DevOpsPOC

# Check specific test class
sf apex run test --tests SampleControllerTest --code-coverage --target-org DevOpsPOC
```

### "Slack notification not received"
```bash
# Verify secret is set
# GitHub → Settings → Secrets → Check SLACK_WEBHOOK_URL exists

# Test webhook manually
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test"}' \
  YOUR_WEBHOOK_URL
```

### "Workflow not running on schedule"
- Verify cron syntax: https://crontab.guru/
- Check workflow file is on main/master branch
- Ensure repository is not archived
- GitHub Actions may have slight delays (±15 minutes)

## 📊 Test Results

### View in GitHub Actions
- **Actions** tab → Select run
- View logs for each step
- Download artifacts (30-day retention):
  - `test-results.json` - Full JSON results
  - `test-output.txt` - Human-readable output
  - `coverage-report.md` - Coverage details

### View Locally
```bash
# After running ./scripts/test-local.sh
cat local-test-results/summary.md
cat local-test-results/test-output.txt
cat local-test-results/test-results.json | jq
```

## 🔧 Configuration

### GitHub Secrets Required
| Secret | Description |
|--------|-------------|
| `SFDX_AUTH_URL` | Salesforce authentication (required) |
| `SLACK_WEBHOOK_URL` | Slack webhook URL (optional) |

### Test Levels
- `RunLocalTests` - All tests in your org (default, recommended)
- `RunAllTestsInOrg` - Include managed package tests
- `RunSpecifiedTests` - Specific test classes

### Workflow Parameters (Manual Run)
- **Target Org:** Default `DevOpsPOC`
- **Test Level:** Default `RunLocalTests`

## 📈 Code Coverage

### View Coverage
```bash
# In test output
sf apex run test --test-level RunLocalTests --code-coverage --target-org DevOpsPOC

# Look for:
# - Overall code coverage %
# - Per-class coverage
# - Uncovered lines
```

### Salesforce Requirements
- **Production Deployment:** 75% minimum
- **Best Practice:** 80%+ coverage
- **Recommendation:** 90%+ for critical classes

## 🔄 Deployment Workflow

```bash
# 1. Make changes to Apex code
vim force-app/main/default/classes/YourClass.cls

# 2. Deploy to org
sf project deploy start --target-org DevOpsPOC

# 3. Test locally
./scripts/test-local.sh

# 4. Commit and push
git add .
git commit -m "Add new feature"
git push origin main

# 5. Trigger GitHub Actions (or wait for schedule)
# Go to Actions → Run workflow
```

## 📞 Support Resources

- **Setup Guide:** [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Testing Checklist:** [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)
- **Workflow Docs:** [.github/workflows/README.md](.github/workflows/README.md)
- **Salesforce CLI:** https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/
- **GitHub Actions:** https://docs.github.com/en/actions
- **Slack Webhooks:** https://api.slack.com/messaging/webhooks
- **Cron Generator:** https://crontab.guru/

## 🎯 Common Tasks

### Add New Test Class
```bash
# 1. Create test class in force-app/main/default/classes/
# 2. Deploy to org
sf project deploy start --source-path force-app/main/default/classes/YourTestClass.cls --target-org DevOpsPOC

# 3. Verify it appears
sf apex list test --target-org DevOpsPOC

# 4. Test locally
./scripts/test-local.sh
```

### Change Schedule
```bash
# Edit workflow file
vim .github/workflows/scheduled-apex-tests.yml

# Find and modify cron expression
# schedule:
#   - cron: '0 8 * * 1'  # Change this line

# Commit and push
git add .github/workflows/scheduled-apex-tests.yml
git commit -m "Update test schedule"
git push origin main
```

### Update Slack Message Format
```bash
# Edit workflow file
vim .github/workflows/scheduled-apex-tests.yml

# Find "Send Slack Notification" step
# Modify SLACK_PAYLOAD section

# Commit and push
git add .github/workflows/scheduled-apex-tests.yml
git commit -m "Update Slack notification format"
git push origin main
```

### Rotate Auth URL (Security Best Practice)
```bash
# 1. Generate new auth URL
./scripts/get-auth-url.sh

# 2. Update GitHub secret
# GitHub → Settings → Secrets → SFDX_AUTH_URL → Update

# 3. Test workflow
# Actions → Run workflow → Verify success
```

## ⚡ Pro Tips

1. **Test locally first** - Always run `./scripts/test-local.sh` before pushing
2. **Check coverage** - Aim for >80% code coverage
3. **Monitor Slack** - Set up notifications in a dedicated channel
4. **Review artifacts** - Download and analyze failed test runs
5. **Rotate secrets** - Update auth URLs quarterly for security
6. **Use manual triggers** - Test changes before waiting for schedule
7. **Document failures** - Track and fix flaky tests
8. **Monitor execution time** - Optimize slow tests

## ✅ Daily Checklist

```
[ ] Tests passing locally
[ ] Code coverage > 75%
[ ] Changes committed and pushed
[ ] GitHub Actions green
[ ] Slack notifications working
```

---

**Need more help?** See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions.


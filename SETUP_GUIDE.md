# Quick Setup Guide: Salesforce Scheduled Tests with GitHub Actions

This guide will walk you through setting up automated Salesforce Apex tests that run every Monday and send results to Slack.

## Prerequisites

- ✅ A GitHub repository with Salesforce code
- ✅ A Salesforce org (sandbox or production) - in your case: **DevOpsPOC**
- ✅ Salesforce CLI installed locally (for initial setup)
- ✅ A Slack workspace where you can create webhooks (optional)

## Quick Start (5 Minutes)

### Step 1: Get Your Salesforce Auth URL (2 minutes)

Open your terminal and run these commands:

```bash
# Navigate to your project directory
cd /Users/supreet.singh/Documents/L&D/ci-test/salesforce-ci-test

# If not already authenticated, log in to your DevOpsPOC org
sf org login web --alias DevOpsPOC --set-default

# Get the authentication URL (you'll need this for GitHub)
sf org display --target-org DevOpsPOC --verbose
```

Look for the line that says **"Sfdx Auth Url"** and copy the entire URL. It will look something like:
```
force://PlatformCLI::5Aep861rRKUHQ6NOwPUvGxvKBImGW8i7qZRqVHZCfHHkZJDM...@brave-impala-abc123.my.salesforce.com
```

**🔒 Keep this URL secure - it's like a password!**

### Step 2: Add Secret to GitHub (1 minute)

1. Go to your GitHub repository: https://github.com/YOUR-USERNAME/YOUR-REPO
2. Click **Settings** (top menu)
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Name: `SFDX_AUTH_URL`
6. Value: Paste the auth URL you copied in Step 1
7. Click **Add secret**

### Step 3: Set Up Slack Webhook (2 minutes) - Optional

1. Go to https://api.slack.com/apps
2. Click **Create New App** → **From scratch**
3. App Name: `Salesforce Test Reporter`
4. Choose your workspace → **Create App**
5. In the left sidebar, click **Incoming Webhooks**
6. Toggle **Activate Incoming Webhooks** to **On**
7. Scroll down and click **Add New Webhook to Workspace**
8. Select the channel where you want notifications (e.g., `#salesforce-tests`)
9. Click **Allow**
10. Copy the **Webhook URL** (starts with `https://hooks.slack.com/services/...`)

Now add this to GitHub:
1. Back in your GitHub repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `SLACK_WEBHOOK_URL`
4. Value: Paste the webhook URL
5. Click **Add secret**

### Step 4: Push the Workflow to GitHub

```bash
# Make sure you're in your project directory
cd /Users/supreet.singh/Documents/L&D/ci-test/salesforce-ci-test

# Add the workflow files
git add .github/

# Commit the changes
git commit -m "Add scheduled Apex test workflow with Slack notifications"

# Push to GitHub
git push origin main
```

### Step 5: Test the Workflow (Manual Run)

1. Go to your GitHub repository
2. Click the **Actions** tab
3. In the left sidebar, click **Scheduled Salesforce Apex Tests**
4. Click the **Run workflow** button (right side)
5. Leave defaults as is:
   - Target Org: `DevOpsPOC`
   - Test Level: `RunLocalTests`
6. Click **Run workflow**

The workflow will start running! You can click on the workflow run to see live logs.

## What Happens Next?

### Automatic Scheduling
- Tests will run **every Monday at 8:00 AM UTC** automatically
- No manual intervention needed

### What Gets Tested
- All Apex test classes in your org (with `@isTest` annotation)
- Excludes managed package tests (for `RunLocalTests` level)

### Results
You'll get results in **two places**:

1. **GitHub Actions** (always):
   - View detailed logs
   - Download test artifacts (JSON, text, coverage reports)
   - See pass/fail status

2. **Slack** (if configured):
   - Test status (passed/failed)
   - Number of tests run, passed, failed
   - Code coverage percentage
   - Execution time
   - Direct link to GitHub Actions run

## Testing Your Setup Right Now

Want to test immediately? Here's how:

### Quick Test Command

```bash
# Verify you can run tests locally first
sf apex run test --test-level RunLocalTests --code-coverage --target-org DevOpsPOC
```

If this works locally, it will work in GitHub Actions!

### Check Your Test Classes

```bash
# See what test classes you have
sf apex list test --target-org DevOpsPOC
```

In your case, you should see:
- `SampleControllerTest`

### Manual GitHub Actions Test

Follow **Step 5** above to trigger a manual run and verify everything works.

## Common Issues & Solutions

### Issue: "No tests found"
**Cause**: No test classes in your org  
**Solution**: Ensure you have files like `SampleControllerTest.cls` with `@isTest` annotation

### Issue: "Authentication failed"
**Cause**: Invalid or expired auth URL  
**Solution**: 
```bash
# Re-authenticate and get new auth URL
sf org logout --target-org DevOpsPOC
sf org login web --alias DevOpsPOC --set-default
sf org display --target-org DevOpsPOC --verbose
# Update the SFDX_AUTH_URL secret in GitHub
```

### Issue: "Slack notification not sent"
**Cause**: Webhook URL not configured or invalid  
**Solution**: Verify the `SLACK_WEBHOOK_URL` secret is set correctly in GitHub

### Issue: "Code coverage below 75%"
**Cause**: Not enough test coverage in your Apex classes  
**Solution**: This is just a warning. Add more test methods to increase coverage. Salesforce requires 75% for production deployments.

## Customization

### Change the Schedule

Edit `.github/workflows/scheduled-apex-tests.yml`:

```yaml
schedule:
  - cron: '0 8 * * 1'  # Monday at 8 AM UTC
```

**Examples:**
- Every day at 9 AM: `'0 9 * * *'`
- Weekdays at 6 AM: `'0 6 * * 1-5'`
- Monday & Friday at 10 AM: `'0 10 * * 1,5'`

### Run Against Multiple Orgs

To test different environments (sandbox, UAT, production):

1. Get auth URLs for each org:
```bash
sf org display --target-org SANDBOX --verbose
sf org display --target-org UAT --verbose
```

2. Add separate secrets in GitHub:
   - `SFDX_AUTH_URL_SANDBOX`
   - `SFDX_AUTH_URL_UAT`
   - `SFDX_AUTH_URL_PRODUCTION`

3. Duplicate the workflow file or use matrix strategy

## Verifying Your Setup

### Checklist Before First Run

- [ ] Salesforce CLI installed locally
- [ ] Authenticated to DevOpsPOC org
- [ ] Copied SFDX Auth URL
- [ ] Added `SFDX_AUTH_URL` secret to GitHub
- [ ] (Optional) Created Slack webhook
- [ ] (Optional) Added `SLACK_WEBHOOK_URL` secret to GitHub
- [ ] Pushed workflow files to GitHub
- [ ] Test classes exist in your org

### Test Locally First

```bash
# Quick verification commands
sf org list
sf org display --target-org DevOpsPOC
sf apex run test --test-level RunLocalTests --target-org DevOpsPOC
```

If all three commands work, you're ready for GitHub Actions!

## What You'll See

### GitHub Actions Output
```
✅ Checkout code
✅ Setup Node.js  
✅ Install Salesforce CLI
✅ Authenticate to Salesforce Org
✅ Run Apex Tests
✅ Parse Test Results
   📊 Test Summary:
   Total Tests: 5
   Passed: 5
   Failed: 0
   Skipped: 0
   Code Coverage: 85%
✅ Generate Coverage Report
✅ Upload Test Results
✅ Send Slack Notification
```

### Slack Message
```
✅ Salesforce Apex Tests - DevOpsPOC Org
Scheduled test run completed

Status: Passed ✓
Test Level: RunLocalTests
Total Tests: 5
Passed: 5
Failed: 0
Code Coverage: 85%
Org-Wide Coverage: 82%
Execution Time: 12.5s
```

## Next Steps

1. **Run your first manual test** (Step 5 above)
2. **Check results in GitHub Actions**
3. **Verify Slack notification** (if configured)
4. **Wait for Monday** (or adjust schedule) for automatic run
5. **Add more tests** to increase coverage
6. **Customize** schedule or notifications as needed

## Need Help?

### Local Testing
```bash
# Check CLI version
sf version

# Check authenticated orgs
sf org list

# Run tests manually
sf apex run test --test-level RunLocalTests --target-org DevOpsPOC --code-coverage
```

### GitHub Actions
- Check the **Actions** tab in your repository
- View logs for each step
- Download artifacts for detailed results

### Resources
- [Salesforce CLI Commands](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Slack Webhooks](https://api.slack.com/messaging/webhooks)

## Success Criteria

Your setup is complete when:
- ✅ Manual workflow run completes successfully
- ✅ Test results appear in GitHub Actions
- ✅ Slack notification is received (if configured)
- ✅ Code coverage percentage is displayed
- ✅ Test artifacts are uploaded

**You're all set! Your tests will now run automatically every Monday.** 🎉


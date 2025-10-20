# GitHub Actions Workflows

## Scheduled Apex Tests Workflow

This workflow (`scheduled-apex-tests.yml`) automatically runs Salesforce Apex tests on a schedule and reports code coverage to Slack.

### Features

✅ **Scheduled Execution**: Runs every Monday at 8:00 AM UTC  
✅ **Manual Trigger**: Can be triggered manually via GitHub Actions UI  
✅ **Code Coverage**: Generates detailed code coverage reports  
✅ **Slack Integration**: Sends comprehensive test results to Slack  
✅ **Multiple Environments**: Configurable for different Salesforce orgs  
✅ **Test Result Artifacts**: Stores test results for 30 days  

### Setup Instructions

#### 1. Configure Salesforce Authentication

You need to set up the `SFDX_AUTH_URL` secret for your Salesforce org:

**Option A: Using an existing authenticated org**
```bash
# If you already have an authenticated org
sf org display --target-org DevOpsPOC --verbose

# Copy the "Sfdx Auth Url" value from the output
# It looks like: force://PlatformCLI::5Aep861...@myorg.my.salesforce.com
```

**Option B: Generate a new auth URL**
```bash
# Authenticate to your org (if not already authenticated)
sf org login web --alias DevOpsPOC --set-default

# Display and get the auth URL
sf org display --target-org DevOpsPOC --verbose

# The output will include "Sfdx Auth Url" - copy this entire URL
```

**Add the secret to GitHub:**
1. Go to your GitHub repository
2. Navigate to: Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `SFDX_AUTH_URL`
5. Value: Paste the entire auth URL (e.g., `force://PlatformCLI::5Aep861...@myorg.my.salesforce.com`)
6. Click "Add secret"

#### 2. Configure Slack Webhook (Optional but Recommended)

To receive test results in Slack:

**Create a Slack Webhook:**
1. Go to https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. Name your app (e.g., "Salesforce Test Reporter")
4. Select your workspace
5. Navigate to "Incoming Webhooks" in the left sidebar
6. Toggle "Activate Incoming Webhooks" to On
7. Click "Add New Webhook to Workspace"
8. Select the channel where you want notifications
9. Copy the Webhook URL (looks like: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX`)

**Add the webhook to GitHub:**
1. Go to your GitHub repository
2. Navigate to: Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `SLACK_WEBHOOK_URL`
5. Value: Paste the Slack webhook URL
6. Click "Add secret"

#### 3. Verify Workflow Configuration

Check that the workflow file is in the correct location:
```
.github/
  └── workflows/
      └── scheduled-apex-tests.yml
```

### Testing the Workflow

#### Manual Test Run

1. Go to your GitHub repository
2. Click on "Actions" tab
3. Select "Scheduled Salesforce Apex Tests" from the left sidebar
4. Click "Run workflow" button (top right)
5. Configure parameters (optional):
   - **Target Org**: DevOpsPOC (default)
   - **Test Level**: RunLocalTests (default) or RunAllTestsInOrg
6. Click "Run workflow"

The workflow will:
- Authenticate to your Salesforce org
- Run all local tests (tests in your org, excluding managed packages)
- Generate code coverage reports
- Send results to Slack
- Upload test artifacts

#### View Results

**In GitHub:**
- Go to Actions → Select the workflow run
- View logs for each step
- Download artifacts (test results, coverage reports)

**In Slack:**
- You'll receive a formatted message with:
  - Test status (Passed/Failed)
  - Number of tests (total, passed, failed, skipped)
  - Code coverage percentage
  - Org-wide coverage
  - Execution time
  - Link to GitHub Actions run

### Customization

#### Change Schedule

Edit the cron expression in `scheduled-apex-tests.yml`:

```yaml
schedule:
  - cron: '0 8 * * 1'  # Monday at 8 AM UTC
```

Common patterns:
- Every day at 9 AM UTC: `0 9 * * *`
- Every weekday at 6 AM UTC: `0 6 * * 1-5`
- Every Monday and Friday at 10 AM UTC: `0 10 * * 1,5`
- Twice a week (Mon & Thu) at 8 AM UTC: `0 8 * * 1,4`

Use [crontab.guru](https://crontab.guru/) to generate cron expressions.

#### Support Multiple Orgs

To run tests against multiple Salesforce environments:

1. Create separate auth URL secrets:
   - `SFDX_AUTH_URL_SANDBOX`
   - `SFDX_AUTH_URL_UAT`
   - `SFDX_AUTH_URL_PRODUCTION`

2. Modify the workflow to use a matrix strategy or duplicate the workflow file with different org configurations.

#### Customize Test Level

Available test levels:
- `RunLocalTests`: Run all tests in your org (excluding managed packages) - **Recommended**
- `RunAllTestsInOrg`: Run all tests including managed packages
- `RunSpecifiedTests`: Run specific test classes (requires modification to specify classes)

### Troubleshooting

#### Authentication Fails
```
Error: Invalid SFDX Auth URL
```
**Solution**: Verify your `SFDX_AUTH_URL` secret is correctly formatted and hasn't expired. Regenerate if needed.

#### Tests Not Running
```
Error: No tests found
```
**Solution**: Ensure you have test classes in your org with `@isTest` annotation.

#### Slack Notification Not Sent
```
SLACK_WEBHOOK_URL secret not configured
```
**Solution**: Add the `SLACK_WEBHOOK_URL` secret to your repository settings.

#### Low Code Coverage
```
Warning: Code coverage below 75%
```
**Solution**: This is informational. Salesforce requires 75% code coverage for production deployments. Add more test coverage to your Apex classes.

### Test Results Format

The workflow generates several outputs:

1. **test-output.txt**: Human-readable test output
2. **test-results.json**: Machine-readable JSON with full details
3. **coverage-report.md**: Markdown table with per-class coverage details

All files are available as artifacts for 30 days.

### Security Best Practices

- ✅ Never commit auth URLs or credentials to the repository
- ✅ Always use GitHub Secrets for sensitive data
- ✅ Regularly rotate auth URLs and webhooks
- ✅ Use sandbox environments for testing workflows
- ✅ Restrict repository access appropriately

### Example Slack Notification

You'll receive a message like this:

```
✅ Salesforce Apex Tests - DevOpsPOC Org
Scheduled test run completed

Status: Passed
Test Level: RunLocalTests
Total Tests: 5
Passed: 5
Failed: 0
Skipped: 0
Code Coverage: 85%
Org-Wide Coverage: 82%
Execution Time: 12.5s
Triggered By: github-actions
```

### Next Steps

1. ✅ Set up `SFDX_AUTH_URL` secret
2. ✅ Set up `SLACK_WEBHOOK_URL` secret (optional)
3. ✅ Run a manual test via GitHub Actions UI
4. ✅ Verify Slack notification is received
5. ✅ Review test results and coverage reports
6. ✅ Adjust schedule as needed
7. ✅ Add more test classes to improve coverage

### Support

For issues or questions:
- Check GitHub Actions logs for detailed error messages
- Verify secrets are correctly configured
- Test Salesforce CLI commands locally first
- Review Salesforce CLI documentation: https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/

### Resources

- [Salesforce CLI Documentation](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Slack Incoming Webhooks](https://api.slack.com/messaging/webhooks)
- [Cron Expression Generator](https://crontab.guru/)


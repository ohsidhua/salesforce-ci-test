# Testing Checklist for GitHub Actions Workflow

Use this checklist to verify your setup before and after deploying the scheduled Apex test workflow.

## Pre-Deployment Testing (Local)

### ✅ Environment Setup
- [ ] Salesforce CLI installed and up-to-date
  ```bash
  sf version
  # Should show version 2.x or later
  ```

- [ ] Authenticated to DevOpsPOC org
  ```bash
  sf org list
  # DevOpsPOC should appear in the list
  ```

- [ ] Can view org details
  ```bash
  sf org display --target-org DevOpsPOC
  # Should show org details without errors
  ```

### ✅ Test Classes Verification
- [ ] Test classes exist in the org
  ```bash
  sf apex list test --target-org DevOpsPOC
  # Should show SampleControllerTest and any other test classes
  ```

- [ ] Can run tests locally
  ```bash
  ./scripts/test-local.sh
  # OR
  sf apex run test --test-level RunLocalTests --code-coverage --target-org DevOpsPOC
  ```

- [ ] Tests pass locally
  - All tests should pass before deploying
  - Code coverage should be > 0%

### ✅ Auth URL Extraction
- [ ] Can extract SFDX Auth URL
  ```bash
  ./scripts/get-auth-url.sh
  # OR
  sf org display --target-org DevOpsPOC --verbose
  # Look for "Sfdx Auth Url" line
  ```

- [ ] Auth URL is complete and starts with `force://`
  - Format: `force://PlatformCLI::<token>@<instance>.my.salesforce.com`

## GitHub Setup

### ✅ Repository Configuration
- [ ] Workflow file exists
  ```bash
  ls -la .github/workflows/scheduled-apex-tests.yml
  # Should exist and not show any errors
  ```

- [ ] All documentation files are present
  - [ ] `.github/workflows/README.md`
  - [ ] `SETUP_GUIDE.md`
  - [ ] `README.md`
  - [ ] `TESTING_CHECKLIST.md` (this file)

- [ ] Helper scripts are executable
  ```bash
  ls -la scripts/
  # test-local.sh and get-auth-url.sh should have execute permissions (x)
  ```

### ✅ GitHub Secrets Configuration
- [ ] `SFDX_AUTH_URL` secret added
  - Navigate to: Settings → Secrets and variables → Actions
  - Secret name: `SFDX_AUTH_URL`
  - Secret value: Complete auth URL from pre-deployment step

- [ ] (Optional) `SLACK_WEBHOOK_URL` secret added
  - Navigate to: Settings → Secrets and variables → Actions
  - Secret name: `SLACK_WEBHOOK_URL`
  - Secret value: Slack webhook URL from https://api.slack.com/apps

### ✅ Code Pushed to GitHub
- [ ] All workflow files committed and pushed
  ```bash
  git add .github/ scripts/ *.md .gitignore
  git commit -m "Add scheduled Apex test workflow with Slack notifications"
  git push origin main
  ```

- [ ] Verify files are visible in GitHub repository
  - Check `.github/workflows/` directory exists
  - Check workflow file is visible

## First Manual Test Run

### ✅ Trigger Workflow Manually
- [ ] Navigate to Actions tab in GitHub repository
- [ ] Select "Scheduled Salesforce Apex Tests" from left sidebar
- [ ] Click "Run workflow" button
- [ ] Configure parameters:
  - Target Org: `DevOpsPOC`
  - Test Level: `RunLocalTests`
- [ ] Click "Run workflow"

### ✅ Monitor Workflow Execution
- [ ] Workflow starts successfully (appears in run list)
- [ ] Click on the workflow run to view details
- [ ] Monitor each step:
  - [ ] ✅ Checkout code
  - [ ] ✅ Setup Node.js
  - [ ] ✅ Install Salesforce CLI
  - [ ] ✅ Authenticate to Salesforce Org
  - [ ] ✅ Run Apex Tests
  - [ ] ✅ Parse Test Results
  - [ ] ✅ Generate Coverage Report
  - [ ] ✅ Upload Test Results
  - [ ] ✅ Send Slack Notification
  - [ ] ✅ Overall workflow status: Success

### ✅ Verify Results in GitHub
- [ ] All steps completed successfully (green checkmarks)
- [ ] Test output visible in "Run Apex Tests" step
- [ ] Test summary displayed in "Parse Test Results" step
- [ ] Artifacts uploaded (check bottom of workflow run page)
  - [ ] `apex-test-results` artifact exists
  - [ ] Can download artifact
  - [ ] Contains: `test-results.json`, `test-output.txt`, `coverage-report.md`

### ✅ Verify Slack Notification (if configured)
- [ ] Message received in Slack channel
- [ ] Message contains:
  - [ ] Status (Passed/Failed)
  - [ ] Test counts (Total, Passed, Failed, Skipped)
  - [ ] Code coverage percentage
  - [ ] Execution time
  - [ ] Link to GitHub Actions run
- [ ] Link in Slack message works and opens GitHub Actions run

## Scheduled Run Verification

### ✅ Schedule Configuration
- [ ] Verify cron schedule is correct
  - Default: `0 8 * * 1` (Monday 8 AM UTC)
  - Matches your requirements
  - Timezone is correct (UTC)

- [ ] Calculate when next run will occur
  ```bash
  # Use a cron calculator or https://crontab.guru/
  # Example: Monday 8 AM UTC = Your local time zone conversion
  ```

- [ ] (Optional) Adjust schedule if needed
  - Edit `.github/workflows/scheduled-apex-tests.yml`
  - Modify cron expression
  - Commit and push changes

### ✅ Wait for Scheduled Run (Monday 8 AM UTC)
- [ ] Workflow runs automatically on schedule
- [ ] No manual intervention required
- [ ] All steps complete successfully
- [ ] Slack notification received (if configured)

## Post-Deployment Verification

### ✅ Test Results Quality
- [ ] Code coverage percentage is acceptable
  - Minimum: 75% (Salesforce requirement for production)
  - Recommended: 80%+ for better code quality

- [ ] No unexpected test failures
  - All expected tests pass
  - Failed tests are documented and tracked

- [ ] Execution time is reasonable
  - Should complete within 30 minutes
  - If timing out, consider optimizing tests

### ✅ Notification Quality
- [ ] Slack messages are readable and informative
- [ ] No false positives or negatives
- [ ] Team members can understand results without additional context

### ✅ Artifact Retention
- [ ] Test artifacts are retained for 30 days
- [ ] Can download and review past test results
- [ ] Historical data is useful for tracking trends

## Troubleshooting Checklist

### ❌ If Authentication Fails
- [ ] Verify `SFDX_AUTH_URL` secret is set correctly
- [ ] Check auth URL is complete and unmodified
- [ ] Regenerate auth URL:
  ```bash
  ./scripts/get-auth-url.sh
  ```
- [ ] Update GitHub secret with new auth URL

### ❌ If No Tests Run
- [ ] Verify test classes exist in org:
  ```bash
  sf apex list test --target-org DevOpsPOC
  ```
- [ ] Check test classes have `@isTest` annotation
- [ ] Verify tests pass locally first
- [ ] Check test level is correct (`RunLocalTests` vs `RunAllTestsInOrg`)

### ❌ If Tests Fail
- [ ] Review test output in GitHub Actions logs
- [ ] Download test artifacts for detailed analysis
- [ ] Run tests locally to reproduce:
  ```bash
  ./scripts/test-local.sh
  ```
- [ ] Fix failing tests and redeploy
- [ ] Trigger manual test run to verify fixes

### ❌ If Slack Notification Doesn't Send
- [ ] Verify `SLACK_WEBHOOK_URL` secret is set
- [ ] Test webhook manually:
  ```bash
  curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"Test from curl"}' \
    YOUR_WEBHOOK_URL
  ```
- [ ] Check Slack app permissions
- [ ] Verify webhook URL is correct and hasn't expired
- [ ] Check GitHub Actions logs for error messages

### ❌ If Workflow Doesn't Trigger on Schedule
- [ ] Verify cron syntax is correct: https://crontab.guru/
- [ ] Check repository is not archived or disabled
- [ ] Ensure workflow file is on default branch (main/master)
- [ ] Wait for next scheduled time (GitHub Actions may have slight delays)
- [ ] Check GitHub Actions usage limits haven't been exceeded

## Advanced Testing

### ✅ Multiple Environment Testing
- [ ] Create auth URLs for additional orgs:
  - [ ] Sandbox
  - [ ] UAT
  - [ ] Production (if applicable)
- [ ] Add secrets for each environment
- [ ] Modify workflow or create separate workflows
- [ ] Test each environment individually

### ✅ Performance Testing
- [ ] Monitor test execution times
- [ ] Identify slow tests
- [ ] Optimize test data setup
- [ ] Consider parallel test execution if available

### ✅ Notification Testing
- [ ] Test with passing tests
- [ ] Test with failing tests
- [ ] Test with mixed results
- [ ] Verify formatting is correct in all cases
- [ ] Test notification during off-hours

## Maintenance Checklist

### 🔄 Weekly
- [ ] Review test results from scheduled run
- [ ] Check code coverage trends
- [ ] Identify and fix flaky tests
- [ ] Verify Slack notifications are being received

### 🔄 Monthly
- [ ] Review and clean up test artifacts
- [ ] Audit GitHub Actions usage
- [ ] Update Salesforce CLI if needed
- [ ] Review and update test classes

### 🔄 Quarterly
- [ ] Rotate SFDX Auth URL for security
- [ ] Review and optimize workflow
- [ ] Update documentation as needed
- [ ] Review scheduled times (adjust for DST if needed)

### 🔄 Annually
- [ ] Review overall testing strategy
- [ ] Update GitHub Actions versions
- [ ] Review Slack integration and permissions
- [ ] Audit test coverage goals

## Success Criteria

Your setup is fully verified when:

- ✅ Local tests run successfully
- ✅ Manual GitHub Actions run completes successfully
- ✅ All workflow steps complete without errors
- ✅ Test results are accurate and match local results
- ✅ Code coverage reports are generated
- ✅ Slack notifications are received (if configured)
- ✅ Test artifacts are uploaded and downloadable
- ✅ Scheduled run works automatically
- ✅ Team members can understand and act on results

## Quick Reference Commands

```bash
# Test locally
./scripts/test-local.sh

# Get auth URL
./scripts/get-auth-url.sh

# Run tests manually
sf apex run test --test-level RunLocalTests --code-coverage --target-org DevOpsPOC

# List test classes
sf apex list test --target-org DevOpsPOC

# Check org status
sf org display --target-org DevOpsPOC

# View workflow file
cat .github/workflows/scheduled-apex-tests.yml

# Push changes
git add . && git commit -m "Your message" && git push origin main
```

## Documentation
- [Setup Guide](SETUP_GUIDE.md) - Initial setup instructions
- [Workflow README](.github/workflows/README.md) - Detailed workflow documentation
- [Main README](README.md) - Project overview

---

**Last Updated:** $(date)  
**Tested By:** [Your Name]  
**Status:** [ ] Pending / [ ] In Progress / [ ] Complete


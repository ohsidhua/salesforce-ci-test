#!/bin/bash

###############################################################################
# Get Salesforce Auth URL for GitHub Secrets
# This script helps you get the SFDX_AUTH_URL needed for GitHub Actions
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

TARGET_ORG="${1:-DevOpsPOC}"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Get Salesforce Auth URL for GitHub Actions          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Salesforce CLI is installed
if ! command -v sf &> /dev/null; then
    echo -e "${RED}❌ Salesforce CLI not found${NC}"
    echo "Please install it: npm install -g @salesforce/cli"
    exit 1
fi

echo -e "${YELLOW}🔍 Checking for org: $TARGET_ORG${NC}"
echo ""

# Check if org is authenticated
if sf org display --target-org "$TARGET_ORG" &> /dev/null; then
    echo -e "${GREEN}✓${NC} Found authenticated org: $TARGET_ORG"
    echo ""
else
    echo -e "${YELLOW}⚠️  Org '$TARGET_ORG' is not authenticated${NC}"
    echo ""
    echo -e "Would you like to authenticate now? ${YELLOW}(y/n)${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}⏳ Opening browser for authentication...${NC}"
        sf org login web --alias "$TARGET_ORG" --set-default
        echo ""
        echo -e "${GREEN}✓${NC} Authentication successful!"
        echo ""
    else
        echo ""
        echo -e "${RED}Cannot proceed without authentication.${NC}"
        echo ""
        echo "To authenticate manually, run:"
        echo -e "  ${CYAN}sf org login web --alias $TARGET_ORG --set-default${NC}"
        exit 1
    fi
fi

# Display org info
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Org Information                       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

ORG_INFO=$(sf org display --target-org "$TARGET_ORG" --verbose)
echo "$ORG_INFO"
echo ""

# Extract the auth URL
AUTH_URL=$(echo "$ORG_INFO" | grep "Sfdx Auth Url" | cut -d' ' -f4-)

if [ -z "$AUTH_URL" ]; then
    echo -e "${RED}❌ Could not extract auth URL${NC}"
    echo ""
    echo "Please run the following command manually and copy the 'Sfdx Auth Url' value:"
    echo -e "  ${CYAN}sf org display --target-org $TARGET_ORG --verbose${NC}"
    exit 1
fi

# Display the auth URL
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              🔑 SFDX Auth URL (Secret)                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Copy this entire URL for GitHub Secrets:${NC}"
echo ""
echo -e "${CYAN}$AUTH_URL${NC}"
echo ""

# Save to clipboard if available
if command -v pbcopy &> /dev/null; then
    echo "$AUTH_URL" | pbcopy
    echo -e "${GREEN}✓${NC} Auth URL copied to clipboard!"
    echo ""
elif command -v xclip &> /dev/null; then
    echo "$AUTH_URL" | xclip -selection clipboard
    echo -e "${GREEN}✓${NC} Auth URL copied to clipboard!"
    echo ""
fi

# Instructions
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              📝 Next Steps                               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}1. Add this to GitHub Secrets:${NC}"
echo "   a. Go to your GitHub repository"
echo "   b. Navigate to: Settings → Secrets and variables → Actions"
echo "   c. Click 'New repository secret'"
echo "   d. Name: SFDX_AUTH_URL"
echo "   e. Value: Paste the auth URL above"
echo "   f. Click 'Add secret'"
echo ""
echo -e "${YELLOW}2. Test the workflow:${NC}"
echo "   a. Go to: Actions tab in your repository"
echo "   b. Select: Scheduled Salesforce Apex Tests"
echo "   c. Click: Run workflow"
echo "   d. Verify it runs successfully"
echo ""

echo -e "${RED}⚠️  IMPORTANT SECURITY NOTES:${NC}"
echo "   • This auth URL is like a password - keep it secure!"
echo "   • Never commit this URL to your repository"
echo "   • Only store it in GitHub Secrets"
echo "   • Rotate it periodically for security"
echo ""

# Option to save to file (with warning)
echo -e "${YELLOW}💾 Save to file? (NOT RECOMMENDED - security risk)${NC} (y/n)"
read -r save_response

if [[ "$save_response" =~ ^[Yy]$ ]]; then
    OUTPUT_FILE="./SFDX_AUTH_URL.txt"
    echo "$AUTH_URL" > "$OUTPUT_FILE"
    echo ""
    echo -e "${GREEN}✓${NC} Saved to: $OUTPUT_FILE"
    echo -e "${RED}⚠️  REMEMBER TO DELETE THIS FILE AFTER USE!${NC}"
    echo -e "${RED}⚠️  DO NOT COMMIT THIS FILE TO GIT!${NC}"
    echo ""
fi

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""


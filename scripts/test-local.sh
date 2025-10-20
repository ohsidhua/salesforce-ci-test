#!/bin/bash

###############################################################################
# Salesforce Local Test Runner
# This script runs Apex tests locally and displays results similar to GitHub Actions
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TARGET_ORG="${1:-DevOpsPOC}"
TEST_LEVEL="${2:-RunLocalTests}"
OUTPUT_DIR="./local-test-results"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Salesforce Apex Test Runner (Local)                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Salesforce CLI is installed
if ! command -v sf &> /dev/null; then
    echo -e "${RED}❌ Salesforce CLI not found${NC}"
    echo "Please install it: npm install -g @salesforce/cli"
    exit 1
fi

echo -e "${GREEN}✓${NC} Salesforce CLI found: $(sf version --json | grep -o '"version":"[^"]*"' | cut -d'"' -f4)"

# Check if target org exists
echo -e "\n${YELLOW}⏳ Checking authentication...${NC}"
if ! sf org display --target-org "$TARGET_ORG" &> /dev/null; then
    echo -e "${RED}❌ Not authenticated to org: $TARGET_ORG${NC}"
    echo ""
    echo "To authenticate, run:"
    echo "  sf org login web --alias $TARGET_ORG --set-default"
    exit 1
fi

echo -e "${GREEN}✓${NC} Authenticated to org: $TARGET_ORG"

# Display org info
ORG_ID=$(sf org display --target-org "$TARGET_ORG" --json | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
ORG_USERNAME=$(sf org display --target-org "$TARGET_ORG" --json | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
echo -e "  Username: ${BLUE}$ORG_USERNAME${NC}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# List available test classes
echo -e "\n${YELLOW}⏳ Discovering test classes...${NC}"
TEST_CLASSES=$(sf apex list test --target-org "$TARGET_ORG" --json 2>/dev/null | grep -o '"FullName":"[^"]*"' | cut -d'"' -f4 | wc -l | tr -d ' ')

if [ "$TEST_CLASSES" -eq 0 ]; then
    echo -e "${RED}❌ No test classes found in org${NC}"
    echo ""
    echo "Make sure you have test classes with @isTest annotation deployed to the org."
    exit 1
fi

echo -e "${GREEN}✓${NC} Found $TEST_CLASSES test class(es)"

# Run tests
echo -e "\n${YELLOW}⏳ Running Apex tests (Test Level: $TEST_LEVEL)...${NC}"
echo -e "  This may take a few minutes...\n"

START_TIME=$(date +%s)

# Run tests with human-readable output
if sf apex run test \
    --test-level "$TEST_LEVEL" \
    --code-coverage \
    --result-format human \
    --output-dir "$OUTPUT_DIR" \
    --wait 30 \
    --target-org "$TARGET_ORG" > "$OUTPUT_DIR/test-output.txt" 2>&1; then
    TEST_SUCCESS=true
else
    TEST_SUCCESS=false
fi

# Also get JSON format for parsing
sf apex run test \
    --test-level "$TEST_LEVEL" \
    --code-coverage \
    --result-format json \
    --output-dir "$OUTPUT_DIR" \
    --wait 30 \
    --target-org "$TARGET_ORG" > "$OUTPUT_DIR/test-results.json" 2>&1 || true

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Display human-readable output
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
cat "$OUTPUT_DIR/test-output.txt" 2>/dev/null || echo "Test output not available"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"

# Parse JSON results if available
if [ -f "$OUTPUT_DIR/test-results.json" ]; then
    if command -v jq &> /dev/null; then
        # Extract summary with jq
        TOTAL=$(jq -r '.summary.testsRan // 0' "$OUTPUT_DIR/test-results.json")
        PASSED=$(jq -r '.summary.passing // 0' "$OUTPUT_DIR/test-results.json")
        FAILED=$(jq -r '.summary.failing // 0' "$OUTPUT_DIR/test-results.json")
        SKIPPED=$(jq -r '.summary.skipped // 0' "$OUTPUT_DIR/test-results.json")
        COVERAGE=$(jq -r '.summary.testRunCoverage // "0%"' "$OUTPUT_DIR/test-results.json")
        ORG_COVERAGE=$(jq -r '.summary.orgWideCoverage // "N/A"' "$OUTPUT_DIR/test-results.json")
        OUTCOME=$(jq -r '.summary.outcome // "Unknown"' "$OUTPUT_DIR/test-results.json")
    else
        # Fallback parsing without jq
        TOTAL=$(grep -o '"testsRan":[0-9]*' "$OUTPUT_DIR/test-results.json" | head -1 | cut -d':' -f2 || echo "0")
        PASSED=$(grep -o '"passing":[0-9]*' "$OUTPUT_DIR/test-results.json" | head -1 | cut -d':' -f2 || echo "0")
        FAILED=$(grep -o '"failing":[0-9]*' "$OUTPUT_DIR/test-results.json" | head -1 | cut -d':' -f2 || echo "0")
        SKIPPED=$(grep -o '"skipped":[0-9]*' "$OUTPUT_DIR/test-results.json" | head -1 | cut -d':' -f2 || echo "0")
        COVERAGE=$(grep -o '"testRunCoverage":"[^"]*"' "$OUTPUT_DIR/test-results.json" | head -1 | cut -d'"' -f4 || echo "0%")
        ORG_COVERAGE=$(grep -o '"orgWideCoverage":"[^"]*"' "$OUTPUT_DIR/test-results.json" | head -1 | cut -d'"' -f4 || echo "N/A")
        OUTCOME=$(grep -o '"outcome":"[^"]*"' "$OUTPUT_DIR/test-results.json" | head -1 | cut -d'"' -f4 || echo "Unknown")
    fi
    
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   📊 Test Summary                        ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Outcome:           ${GREEN}$OUTCOME${NC}"
    echo -e "  Total Tests:       $TOTAL"
    echo -e "  ${GREEN}Passed:${NC}           $PASSED"
    echo -e "  ${RED}Failed:${NC}           $FAILED"
    echo -e "  ${YELLOW}Skipped:${NC}          $SKIPPED"
    echo -e "  Code Coverage:     $COVERAGE"
    echo -e "  Org Coverage:      $ORG_COVERAGE"
    echo -e "  Duration:          ${DURATION}s"
    echo ""
    
    # Code coverage details
    if command -v jq &> /dev/null; then
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║              📈 Code Coverage Details                    ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        # Create coverage table
        {
            echo "Class Name|Coverage %|Lines Covered|Lines Uncovered"
            echo "----------|----------|-------------|---------------"
            
            if jq -e '.coverage.coverage' "$OUTPUT_DIR/test-results.json" > /dev/null 2>&1; then
                jq -r '.coverage.coverage[] | "\(.name)|\(.coveredPercent)%|\(.numLocations - .numLocationsNotCovered)|\(.numLocationsNotCovered)"' "$OUTPUT_DIR/test-results.json" 2>/dev/null
            else
                echo "No coverage data|N/A|N/A|N/A"
            fi
        } | column -t -s '|'
        echo ""
    fi
    
    # Save summary
    {
        echo "# Test Summary - $(date)"
        echo ""
        echo "**Outcome:** $OUTCOME"
        echo "**Total Tests:** $TOTAL"
        echo "**Passed:** $PASSED"
        echo "**Failed:** $FAILED"
        echo "**Skipped:** $SKIPPED"
        echo "**Code Coverage:** $COVERAGE"
        echo "**Org-Wide Coverage:** $ORG_COVERAGE"
        echo "**Duration:** ${DURATION}s"
    } > "$OUTPUT_DIR/summary.md"
fi

# Final status
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
if [ "$TEST_SUCCESS" = true ] && [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    EXIT_CODE=0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    EXIT_CODE=1
fi

echo -e "\n${YELLOW}📁 Test results saved to:${NC} $OUTPUT_DIR/"
echo -e "  - test-output.txt     (human-readable)"
echo -e "  - test-results.json   (JSON format)"
echo -e "  - summary.md          (summary report)"
echo ""

# Display command to view results
echo -e "${YELLOW}💡 Tips:${NC}"
echo -e "  View full output:  cat $OUTPUT_DIR/test-output.txt"
echo -e "  View JSON results: cat $OUTPUT_DIR/test-results.json | jq"
echo -e "  View summary:      cat $OUTPUT_DIR/summary.md"
echo ""

# Suggest next steps
if [ "$TEST_SUCCESS" = true ]; then
    echo -e "${GREEN}🚀 Ready to push to GitHub!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Commit your changes: git add . && git commit -m 'Update tests'"
    echo "  2. Push to GitHub: git push origin main"
    echo "  3. Tests will run automatically every Monday at 8 AM UTC"
    echo "  4. Or trigger manually: GitHub → Actions → Run workflow"
else
    echo -e "${YELLOW}⚠️  Fix failing tests before pushing to GitHub${NC}"
fi

echo ""
exit $EXIT_CODE


#!/usr/bin/env python3
"""
Enhanced Slack Notifier for Salesforce Test Results
Supports both webhook and bot token authentication
"""

import json
import sys
import os
import requests
from datetime import datetime
from typing import Dict, Any, Optional

class SlackNotifier:
    def __init__(self, webhook_url: Optional[str] = None, bot_token: Optional[str] = None, channel: str = "#salesforce-ci"):
        self.webhook_url = webhook_url
        self.bot_token = bot_token
        self.channel = channel
        
        if not webhook_url and not bot_token:
            raise ValueError("Either webhook_url or bot_token must be provided")
    
    def load_test_summary(self, summary_file: str) -> Dict[str, Any]:
        """Load test summary from JSON file"""
        try:
            with open(summary_file, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Warning: Could not load summary file {summary_file}: {e}")
            return {
                "sandbox": "Unknown",
                "total_tests": 0,
                "passed_tests": 0,
                "failed_tests": 0,
                "avg_coverage": 0,
                "status": "❓ Unknown",
                "coverage_status": "❓ Unknown"
            }
    
    def create_message_payload(self, summary: Dict[str, Any], github_context: Dict[str, str]) -> Dict[str, Any]:
        """Create Slack message payload"""
        
        # Determine colors and status
        if summary.get("failed_tests", 0) == 0 and summary.get("total_tests", 0) > 0:
            color = "#36a64f"  # Green
            status_emoji = "✅"
            overall_status = "SUCCESS"
        else:
            color = "#ff0000"  # Red
            status_emoji = "❌"
            overall_status = "FAILED"
        
        # Coverage color coding
        coverage_pct = summary.get("avg_coverage", 0)
        if coverage_pct >= 75:
            coverage_color = "✅"
        elif coverage_pct >= 50:
            coverage_color = "⚠️"
        else:
            coverage_color = "❌"
        
        # Create rich message with blocks (modern Slack format)
        blocks = [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": f"{status_emoji} Salesforce Test Results - {summary.get('sandbox', 'Unknown')}"
                }
            },
            {
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": f"*Environment:*\n{summary.get('sandbox', 'Unknown')}"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*Status:*\n{status_emoji} {overall_status}"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*Tests:*\n{summary.get('passed_tests', 0)}/{summary.get('total_tests', 0)} passed"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*Coverage:*\n{coverage_pct}% {coverage_color}"
                    }
                ]
            }
        ]
        
        # Add failed tests section if there are failures
        if summary.get("failed_tests", 0) > 0:
            blocks.append({
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"⚠️ *{summary.get('failed_tests', 0)} tests failed* - Immediate attention required"
                }
            })
        
        # Add coverage warning if low
        if coverage_pct < 75:
            blocks.append({
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"📊 *Coverage Alert:* {coverage_pct}% is below the recommended 75% threshold"
                }
            })
        
        # Add action buttons
        blocks.append({
            "type": "actions",
            "elements": [
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Detailed Report"
                    },
                    "url": f"{github_context.get('server_url', 'https://github.com')}/{github_context.get('repository', 'unknown')}/actions/runs/{github_context.get('run_id', 'unknown')}",
                    "style": "primary"
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Repository"
                    },
                    "url": f"{github_context.get('server_url', 'https://github.com')}/{github_context.get('repository', 'unknown')}"
                }
            ]
        })
        
        # Add context footer
        blocks.append({
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": f"🤖 Triggered by: {github_context.get('trigger', 'Unknown')} | 📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}"
                }
            ]
        })
        
        # Return payload based on authentication method
        if self.webhook_url:
            return {
                "channel": self.channel,
                "username": "Salesforce CI Bot",
                "icon_emoji": ":salesforce:",
                "blocks": blocks,
                # Fallback text for notifications
                "text": f"{status_emoji} Salesforce tests {overall_status.lower()} for {summary.get('sandbox', 'Unknown')} - {summary.get('passed_tests', 0)}/{summary.get('total_tests', 0)} tests passed, {coverage_pct}% coverage"
            }
        else:
            return {
                "channel": self.channel,
                "blocks": blocks,
                "text": f"{status_emoji} Salesforce tests {overall_status.lower()} for {summary.get('sandbox', 'Unknown')} - {summary.get('passed_tests', 0)}/{summary.get('total_tests', 0)} tests passed, {coverage_pct}% coverage"
            }
    
    def send_notification(self, payload: Dict[str, Any]) -> bool:
        """Send notification to Slack"""
        try:
            if self.webhook_url:
                response = requests.post(
                    self.webhook_url,
                    json=payload,
                    headers={'Content-Type': 'application/json'},
                    timeout=30
                )
                
                if response.status_code == 200:
                    print("✅ Slack notification sent successfully via webhook")
                    return True
                else:
                    print(f"❌ Failed to send Slack notification via webhook: {response.status_code} - {response.text}")
                    return False
            
            elif self.bot_token:
                response = requests.post(
                    'https://slack.com/api/chat.postMessage',
                    json=payload,
                    headers={
                        'Authorization': f'Bearer {self.bot_token}',
                        'Content-Type': 'application/json'
                    },
                    timeout=30
                )
                
                result = response.json()
                if result.get('ok'):
                    print("✅ Slack notification sent successfully via bot token")
                    return True
                else:
                    print(f"❌ Failed to send Slack notification via bot token: {result.get('error', 'Unknown error')}")
                    return False
        
        except Exception as e:
            print(f"❌ Exception while sending Slack notification: {e}")
            return False
    
    def send_test_results(self, summary_file: str, github_context: Dict[str, str]) -> bool:
        """Main method to send test results notification"""
        summary = self.load_test_summary(summary_file)
        payload = self.create_message_payload(summary, github_context)
        return self.send_notification(payload)

def main():
    """Main function for command line usage"""
    if len(sys.argv) < 2:
        print("Usage: python3 slack-notifier.py <summary_file> [github_server_url] [github_repository] [github_run_id] [trigger]")
        sys.exit(1)
    
    summary_file = sys.argv[1]
    
    # GitHub context
    github_context = {
        'server_url': sys.argv[2] if len(sys.argv) > 2 else os.getenv('GITHUB_SERVER_URL', 'https://github.com'),
        'repository': sys.argv[3] if len(sys.argv) > 3 else os.getenv('GITHUB_REPOSITORY', 'unknown/unknown'),
        'run_id': sys.argv[4] if len(sys.argv) > 4 else os.getenv('GITHUB_RUN_ID', 'unknown'),
        'trigger': sys.argv[5] if len(sys.argv) > 5 else os.getenv('GITHUB_EVENT_NAME', 'unknown')
    }
    
    # Get Slack credentials from environment
    webhook_url = os.getenv('SLACK_WEBHOOK_URL')
    bot_token = os.getenv('SLACK_BOT_TOKEN')
    channel = os.getenv('SLACK_CHANNEL', '#salesforce-ci')
    
    if not webhook_url and not bot_token:
        print("❌ Error: Either SLACK_WEBHOOK_URL or SLACK_BOT_TOKEN environment variable must be set")
        sys.exit(1)
    
    try:
        notifier = SlackNotifier(webhook_url=webhook_url, bot_token=bot_token, channel=channel)
        success = notifier.send_test_results(summary_file, github_context)
        sys.exit(0 if success else 1)
    
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

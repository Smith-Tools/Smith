#!/bin/bash

# Smith Build Emergency Kill
# Immediate termination of stuck Swift build processes
# Part of the Smith Build Diagnostics methodology

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/smith-emergency-kill-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log output
log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check for stuck processes and kill them
emergency_kill() {
    log "${RED}🚨 EMERGENCY KILL INITIATED${NC}"
    log "${BLUE}Checking for stuck Swift build processes...${NC}"

    # Find Swift build processes with high CPU usage
    local stuck_processes=$(ps aux | grep -E "(swift|swiftc|xcodebuild|clang)" | grep -v grep | awk '$3 > 80 {print $2}')

    if [[ -z "$stuck_processes" ]]; then
        log "${GREEN}✅ No high-CPU Swift processes found${NC}"
        return 0
    fi

    log "${RED}🔥 Found stuck processes: $stuck_processes${NC}"

    # Kill each stuck process
    for pid in $stuck_processes; do
        local process_info=$(ps -p "$pid" -o pid,ppid,command --no-headers)
        log "${YELLOW}🔨 Terminating process: $process_info${NC}"

        # Try graceful kill first
        if kill -TERM "$pid" 2>/dev/null; then
            sleep 2
            # Check if it's still running
            if kill -0 "$pid" 2>/dev/null; then
                log "${RED}💀 Force killing process $pid${NC}"
                kill -KILL "$pid" 2>/dev/null || true
            fi
        fi
    done

    # Clean up any remaining swift temp files
    log "${BLUE}🧹 Cleaning up temporary files...${NC}"
    find /tmp -name "swift-*" -user "$USER" -mmin +60 -delete 2>/dev/null || true
    find /var/folders -name "swift-*" -user "$USER" -mmin +60 -delete 2>/dev/null || true

    # Kill any hanging Xcode build processes
    local xcode_processes=$(ps aux | grep -E "Xcode|xcbuild" | grep -v grep | awk '$3 > 50 {print $2}')
    for pid in $xcode_processes; do
        log "${YELLOW}🔨 Terminating Xcode process: $pid${NC}"
        kill -TERM "$pid" 2>/dev/null || true
    done

    log "${GREEN}✅ Emergency kill completed${NC}"
}

# Function to show usage
usage() {
    cat << EOF
Smith Build Emergency Kill

Usage: $(basename "$0") [options]

Description:
  Emergency termination of stuck Swift build processes that are consuming
  excessive CPU (80%+). This is a last resort when builds are completely hung.

Options:
  -h, --help     Show this help message
  -v, --verbose  Verbose output
  -l, --log      Show log file location

Examples:
  $(basename "$0")                    # Kill stuck processes
  $(basename "$0") --verbose         # Verbose output
  $(basename "$0") --log             # Show log file

EOF
}

# Parse command line arguments
VERBOSE=false
SHOW_LOG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -l|--log)
            SHOW_LOG=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

# Main execution
if [[ "$VERBOSE" == "true" ]]; then
    log "${BLUE}🔍 Smith Emergency Kill (Verbose Mode)${NC}"
    log "${BLUE}Log file: $LOG_FILE${NC}"
fi

emergency_kill

if [[ "$SHOW_LOG" == "true" ]]; then
    echo
    log "${BLUE}📋 Full log available at: $LOG_FILE${NC}"
fi

log "${GREEN}🎯 Emergency recovery complete. You can now retry your build.${NC}"
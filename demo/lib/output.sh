#!/usr/bin/env bash
# Output helpers — colors and print functions for demo.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_banner() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}         SIGNUS DEMO LAUNCHER${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

print_step() { echo -e "${BOLD}$1${NC}"; }
print_ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
print_fail() { echo -e "  ${RED}✗${NC} $1"; }
print_section() { echo ""; echo -e "${BOLD}-- $1 --${NC}"; }

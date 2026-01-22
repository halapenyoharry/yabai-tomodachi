#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Yabai Scripting Addition Installer${NC}"
echo "===================================="
echo ""

# Check if Yabai is installed
if ! command -v yabai &> /dev/null; then
    echo -e "${RED}Error: Yabai is not installed.${NC}"
    echo "Please install Yabai first using yabai-tomodachi or run:"
    echo "  brew install koekeishiya/formulae/yabai"
    exit 1
fi

# Check SIP status
echo -e "${YELLOW}Checking System Integrity Protection (SIP) status...${NC}"
SIP_STATUS=$(csrutil status)
echo "$SIP_STATUS"
echo ""

# Check if both filesystem protections AND debugging restrictions are disabled
FS_DISABLED=$(echo "$SIP_STATUS" | grep -q "Filesystem Protections: disabled" && echo "yes" || echo "no")
DEBUG_DISABLED=$(echo "$SIP_STATUS" | grep -q "Debugging Restrictions: disabled" && echo "yes" || echo "no")

if [[ "$FS_DISABLED" == "yes" && "$DEBUG_DISABLED" == "yes" ]]; then
    echo -e "${GREEN}✓ SIP is properly configured for Yabai scripting addition${NC}"
else
    echo -e "${RED}✗ SIP needs to be partially disabled for the scripting addition${NC}"
    echo ""
    if [[ "$FS_DISABLED" == "no" ]]; then
        echo -e "${RED}  • Filesystem Protections: NOT disabled${NC}"
    else
        echo -e "${GREEN}  • Filesystem Protections: disabled${NC}"
    fi
    
    if [[ "$DEBUG_DISABLED" == "no" ]]; then
        echo -e "${RED}  • Debugging Restrictions: NOT disabled${NC}"
    else
        echo -e "${GREEN}  • Debugging Restrictions: disabled${NC}"
    fi
    
    echo ""
    echo "To use advanced features (opacity, focus follows mouse, etc.), you need to:"
    echo "1. Restart your Mac and hold Cmd+R to enter Recovery Mode"
    echo "2. Open Terminal from the Utilities menu"
    echo "3. Run: csrutil enable --without fs --without debug"
    echo "4. Restart your Mac"
    echo ""
    echo "This disables only the minimum required for Yabai."
    echo "Other security features remain enabled."
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}What the Scripting Addition enables:${NC}"
echo "  • Window opacity control"
echo "  • Focus follows mouse"
echo "  • Window animations"
echo "  • Better space switching"
echo "  • Advanced window manipulation"
echo ""

# Check if already installed
if [ -f "/Library/ScriptingAdditions/yabai.osax/Contents/MacOS/mach_loader" ]; then
    echo -e "${YELLOW}Scripting addition appears to be installed.${NC}"
    echo "Do you want to reinstall it? (y/n)"
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}Loading scripting addition...${NC}"
        sudo yabai --load-sa
        echo -e "${GREEN}✓ Scripting addition loaded!${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${YELLOW}Installing Yabai scripting addition...${NC}"
echo "This requires administrator privileges."
echo ""

# Install/load scripting addition
sudo yabai --load-sa

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Scripting addition loaded successfully!${NC}"
    echo ""
    echo "You can now use advanced Yabai features!"
    echo "Note: You'll need to reload it after each restart."
else
    echo ""
    echo -e "${RED}✗ Failed to install scripting addition${NC}"
    echo "Please check the error messages above."
    exit 1
fi
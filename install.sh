#!/bin/bash

# Source files
DISPLAYHATMINI_SRC="displayhatmini.py"
ST7789_SRC="ST7789.py"

# Destination directories
DISPLAYHATMINI_DST_DIR="/usr/local/lib/python3.11/dist-packages/pwnagotchi/ui/hw"
ST7789_DST_DIR="/usr/local/lib/python3.11/dist-packages/pwnagotchi/ui/hw/libs/pimoroni/displayhatmini"

# Path to /boot/firmware/config.txt
CONFIG_FILE="/boot/firmware/config.txt"

# Create destination directories if they don't exist
echo "Creating destination directories..."
mkdir -p "$DISPLAYHATMINI_DST_DIR"
mkdir -p "$ST7789_DST_DIR"

# Copy displayhatmini.py
echo "Copying $DISPLAYHATMINI_SRC to $DISPLAYHATMINI_DST_DIR..."
if cp "$DISPLAYHATMINI_SRC" "$DISPLAYHATMINI_DST_DIR/"; then
    echo "Successfully copied $DISPLAYHATMINI_SRC"
else
    echo "Failed to copy $DISPLAYHATMINI_SRC"
    exit 1
fi

# Copy ST7789.py
echo "Copying $ST7789_SRC to $ST7789_DST_DIR..."
if cp "$ST7789_SRC" "$ST7789_DST_DIR/"; then
    echo "Successfully copied $ST7789_SRC"
else
    echo "Failed to copy $ST7789_SRC"
    exit 1
fi

# Edit /boot/firmware/config.txt
echo "Editing $CONFIG_FILE..."

# Define the new [pi0] section content
PI0_SECTION=$(cat <<EOF
[pi0]
dtoverlay=spi1-0cs
#dtoverlay=disable-wifi
enable_uart=1
EOF
)

# Backup config.txt before making changes
sudo cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Function to replace the [pi0] section using awk
replace_pi0_section() {
    awk -v new_section="$PI0_SECTION" '
    BEGIN { found_pi0 = 0 }
    /^\[pi0\]/ { found_pi0 = 1; print new_section; next }
    /^\[.*\]/ { found_pi0 = 0 }
    !found_pi0 { print $0 }
    ' "$CONFIG_FILE" | sudo tee "$CONFIG_FILE.tmp" > /dev/null && sudo mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
}

# Apply the changes to the [pi0] section
replace_pi0_section

echo "All files copied and configuration updated successfully."

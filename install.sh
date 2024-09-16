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

# Function to replace the [pi0] section
replace_pi0_section() {
    # Use sed to find the [pi0] section and replace it with the new content
    if grep -q "\[pi0\]" "$CONFIG_FILE"; then
        echo "Replacing [pi0] section in $CONFIG_FILE..."
        sudo sed -i '/\[pi0\]/,/\[.*\]/c\'"$PI0_SECTION" "$CONFIG_FILE"
    else
        echo "[pi0] section not found, adding it..."
        echo "$PI0_SECTION" | sudo tee -a "$CONFIG_FILE" > /dev/null
    fi
}

# Apply the changes to the [pi0] section
replace_pi0_section

echo "All files copied and configuration updated successfully."

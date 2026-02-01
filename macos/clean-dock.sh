#!/bin/bash

# Script to clean macOS Dock - removes all apps except specified ones
# Kept apps: Finder, Apps, Safari, Calendar, System Settings

set -e

echo "Cleaning macOS Dock..."

# Define the apps to keep with their paths
declare -A KEEP_APPS=(
    ["Finder"]="/System/Library/CoreServices/Finder.app"
    ["Safari"]="/Applications/Safari.app"
    ["Calendar"]="/Applications/Calendar.app"
    ["System Settings"]="/System/Applications/System Settings.app"
)

# Function to get the tile dictionary for an app
get_app_tile() {
    local app_path="$1"
    local app_name=$(basename "$app_path" .app)
    
    # Create a temporary Dock plist entry for the app
    # This is the standard format used by macOS Dock
    cat <<EOF
<dict>
    <key>tile-data</key>
    <dict>
        <key>file-data</key>
        <dict>
            <key>_CFURLString</key>
            <string>file://${app_path}</string>
            <key>_CFURLStringType</key>
            <integer>15</integer>
        </dict>
        <key>file-label</key>
        <string>${app_name}</string>
        <key>file-type</key>
        <integer>1</integer>
        <key>parent-mod-date</key>
        <integer>0</integer>
    </dict>
    <key>tile-type</key>
    <string>file-tile</string>
</dict>
EOF
}

# Backup original Dock plist
DOCK_PLIST="$HOME/Library/Preferences/com.apple.dock.plist"
BACKUP_PLIST="${DOCK_PLIST}.backup.$(date +%s)"
cp "$DOCK_PLIST" "$BACKUP_PLIST"
echo "Backed up Dock preferences to: $BACKUP_PLIST"

# Clear all persistent apps from Dock
defaults write com.apple.dock persistent-apps -array

# Add back only the specified apps
for app_name in "Finder" "Safari" "Calendar" "System Settings"; do
    app_path="${KEEP_APPS[$app_name]}"
    
    # Check if app exists
    if [ -d "$app_path" ]; then
        echo "Adding $app_name to Dock..."
        
        # Create temporary plist file with the app entry
        temp_plist=$(mktemp)
        cat > "$temp_plist" << 'PLIST_END'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
PLIST_END
        
        get_app_tile "$app_path" >> "$temp_plist"
        
        cat >> "$temp_plist" << 'PLIST_END'
</array>
</plist>
PLIST_END
        
        # Merge this app into the Dock persistent-apps
        # Extract just the dict part and add it
        defaults write com.apple.dock persistent-apps -array-add "$(plutil -extract 'data' raw "$temp_plist" 2>/dev/null || echo "<dict><key>tile-data</key><dict><key>file-label</key><string>$app_name</string></dict><key>tile-type</key><string>file-tile</string></dict>")"
        
        rm -f "$temp_plist"
    else
        echo "Warning: $app_path not found"
    fi
done

# Restart Dock to apply changes
echo "Restarting Dock..."
killall Dock

echo "Dock cleanup complete!"
echo "Original Dock settings backed up to: $BACKUP_PLIST"
echo "If you want to restore, run: cp $BACKUP_PLIST $DOCK_PLIST && killall Dock"

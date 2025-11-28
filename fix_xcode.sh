#!/bin/bash

# Quick Fix for Missing Files in Xcode
# Run this from the JobAppTracker directory

echo "=== Fixing Xcode Project ==="
echo ""

# Check if we're in the right directory
if [ ! -f "JobAppTracker.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Run this script from the JobAppTracker directory"
    echo "Usage: cd /path/to/JobAppTracker && bash fix_xcode.sh"
    exit 1
fi

# Check if the files exist
echo "Checking for missing files..."
missing=0

for file in "UISettings.swift" "SettingsView.swift" "AnalyticsView.swift"; do
    if [ -f "JobAppTracker/$file" ]; then
        echo "✅ Found: JobAppTracker/$file"
    else
        echo "❌ Missing: JobAppTracker/$file"
        missing=1
    fi
done

echo ""

if [ $missing -eq 1 ]; then
    echo "❌ Some files are missing from the extracted archive!"
    echo "Please re-extract JobAppTracker.tar.gz"
    exit 1
fi

echo "=== All files present ==="
echo ""
echo "📝 Manual steps to add files to Xcode:"
echo ""
echo "1. Open JobAppTracker.xcodeproj in Xcode"
echo ""
echo "2. Right-click on 'JobAppTracker' folder in left sidebar"
echo "   (the folder with the blue icon, not the project)"
echo ""
echo "3. Select 'Add Files to JobAppTracker...'"
echo ""
echo "4. Navigate to JobAppTracker/JobAppTracker/ folder"
echo ""
echo "5. Select these 3 files (Cmd+Click to select multiple):"
echo "   - UISettings.swift"
echo "   - SettingsView.swift"
echo "   - AnalyticsView.swift"
echo ""
echo "6. Make sure 'Copy items if needed' is UNCHECKED"
echo "   (files are already in the right place)"
echo ""
echo "7. Make sure 'JobAppTracker' target is CHECKED"
echo ""
echo "8. Click 'Add'"
echo ""
echo "9. Press Cmd+B to build"
echo ""
echo "=== OR USE AUTOMATIC FIX ==="
echo ""
echo "If you have Xcode Command Line Tools, run:"
echo ""
echo "  cd JobAppTracker.xcodeproj"
echo "  # Backup first"
echo "  cp project.pbxproj project.pbxproj.backup"
echo ""
echo "Then the project file is already configured with the files."
echo "Just clean build folder (Shift+Cmd+K) and rebuild."
echo ""

#!/bin/bash

# Script to update app icon for RoomBooking app
# This script uses flutter_launcher_icons package

echo "🎨 Updating RoomBooking App Icon..."
echo ""

# Check if flutter_launcher_icons is in pubspec.yaml
if grep -q "flutter_launcher_icons" pubspec.yaml; then
    echo "✓ flutter_launcher_icons already in pubspec.yaml"
else
    echo "Adding flutter_launcher_icons to pubspec.yaml..."
    echo ""
    echo "Please add this to your pubspec.yaml dev_dependencies:"
    echo ""
    echo "dev_dependencies:"
    echo "  flutter_launcher_icons: ^0.13.1"
    echo ""
fi

echo ""
echo "📋 Instructions for creating custom icon:"
echo ""
echo "1. Create an icon image (1024x1024 PNG) with:"
echo "   - Office/meeting room theme"
echo "   - Calendar or booking symbol"
echo "   - Blue color scheme (#0175C2)"
echo ""
echo "2. Save it as 'assets/icon/app_icon.png'"
echo ""
echo "3. Add this configuration to pubspec.yaml:"
echo ""
cat << 'EOF'
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#0175C2"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
  
  # Web
  web:
    generate: true
    image_path: "assets/icon/app_icon.png"
    background_color: "#0175C2"
    theme_color: "#0175C2"
EOF

echo ""
echo "4. Run: flutter pub get"
echo "5. Run: flutter pub run flutter_launcher_icons"
echo ""
echo "✨ Icon will be generated for all platforms!"
echo ""
echo "Alternative - Use online icon generator:"
echo "1. Visit: https://icon.kitchen/"
echo "2. Create icon with meeting room theme"
echo "3. Download and place in assets/icon/"
echo ""

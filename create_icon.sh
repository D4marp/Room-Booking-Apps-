#!/bin/bash
# Script to generate app icon using Python with venv

echo "🎨 Generating RoomBooking App Icon..."

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install pillow
pip install pillow --quiet

# Run the icon generator
python3 generate_icon.py

# Deactivate venv
deactivate

echo ""
echo "✅ Done! Now run:"
echo "   flutter pub get"
echo "   flutter pub run flutter_launcher_icons"

#!/usr/bin/env python3
"""
Generate app icon for RoomBooking app
Requires: pip install pillow
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    # Create 1024x1024 icon (standard size)
    size = 1024
    icon = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(icon)
    
    # Background gradient effect (blue)
    primary_blue = (33, 150, 243)  # #2196F3
    dark_blue = (25, 118, 210)     # #1976D2
    
    # Draw rounded rectangle background
    margin = 50
    radius = 180
    
    # Create gradient background
    for i in range(size):
        ratio = i / size
        r = int(primary_blue[0] + (dark_blue[0] - primary_blue[0]) * ratio)
        g = int(primary_blue[1] + (dark_blue[1] - primary_blue[1]) * ratio)
        b = int(primary_blue[2] + (dark_blue[2] - primary_blue[2]) * ratio)
        draw.rectangle([0, i, size, i+1], fill=(r, g, b, 255))
    
    # Draw white room/door icon in center
    white = (255, 255, 255, 255)
    
    # Door frame
    door_width = 400
    door_height = 600
    door_x = (size - door_width) // 2
    door_y = (size - door_height) // 2 - 50
    
    # Draw door outline
    line_width = 35
    draw.rounded_rectangle(
        [door_x, door_y, door_x + door_width, door_y + door_height],
        radius=40,
        outline=white,
        width=line_width
    )
    
    # Draw door handle
    handle_size = 60
    handle_x = door_x + door_width - 100
    handle_y = door_y + door_height // 2
    draw.ellipse(
        [handle_x - handle_size//2, handle_y - handle_size//2,
         handle_x + handle_size//2, handle_y + handle_size//2],
        fill=white
    )
    
    # Draw door panels (decorative rectangles inside)
    panel_margin = 80
    panel_width = door_width - 2 * panel_margin
    panel_height = 180
    
    # Top panel
    draw.rounded_rectangle(
        [door_x + panel_margin, door_y + 80,
         door_x + panel_margin + panel_width, door_y + 80 + panel_height],
        radius=20,
        outline=white,
        width=25
    )
    
    # Bottom panel
    draw.rounded_rectangle(
        [door_x + panel_margin, door_y + door_height - 80 - panel_height,
         door_x + panel_margin + panel_width, door_y + door_height - 80],
        radius=20,
        outline=white,
        width=25
    )
    
    # Draw calendar icon at the top
    cal_size = 120
    cal_x = size // 2 - cal_size // 2
    cal_y = 100
    
    # Calendar background
    draw.rounded_rectangle(
        [cal_x, cal_y, cal_x + cal_size, cal_y + cal_size],
        radius=15,
        fill=white
    )
    
    # Calendar header
    draw.rectangle(
        [cal_x, cal_y, cal_x + cal_size, cal_y + 35],
        fill=primary_blue
    )
    
    # Calendar rings
    ring_y = cal_y - 15
    draw.ellipse([cal_x + 20, ring_y, cal_x + 35, ring_y + 15], fill=white)
    draw.ellipse([cal_x + cal_size - 35, ring_y, cal_x + cal_size - 20, ring_y + 15], fill=white)
    
    # Save main icon
    output_path = 'assets/icon/icon.png'
    icon.save(output_path, 'PNG')
    print(f"✅ Created: {output_path}")
    
    # Create foreground for adaptive icon (Android)
    # Foreground should have transparent background
    foreground = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(foreground)
    
    # Draw same door icon but larger for foreground
    door_width = 450
    door_height = 650
    door_x = (size - door_width) // 2
    door_y = (size - door_height) // 2
    
    # Door outline (white)
    fg_draw.rounded_rectangle(
        [door_x, door_y, door_x + door_width, door_y + door_height],
        radius=45,
        outline=white,
        width=40
    )
    
    # Door handle
    handle_x = door_x + door_width - 110
    handle_y = door_y + door_height // 2
    fg_draw.ellipse(
        [handle_x - 35, handle_y - 35, handle_x + 35, handle_y + 35],
        fill=white
    )
    
    # Door panels
    panel_margin = 90
    panel_width = door_width - 2 * panel_margin
    panel_height = 200
    
    fg_draw.rounded_rectangle(
        [door_x + panel_margin, door_y + 90,
         door_x + panel_margin + panel_width, door_y + 90 + panel_height],
        radius=25,
        outline=white,
        width=30
    )
    
    fg_draw.rounded_rectangle(
        [door_x + panel_margin, door_y + door_height - 90 - panel_height,
         door_x + panel_margin + panel_width, door_y + door_height - 90],
        radius=25,
        outline=white,
        width=30
    )
    
    # Save foreground
    foreground_path = 'assets/icon/icon_foreground.png'
    foreground.save(foreground_path, 'PNG')
    print(f"✅ Created: {foreground_path}")
    
    print("\n🎨 Icons generated successfully!")
    print("\nNext steps:")
    print("1. Run: flutter pub get")
    print("2. Run: flutter pub run flutter_launcher_icons")
    print("3. Rebuild your app")

if __name__ == '__main__':
    create_app_icon()

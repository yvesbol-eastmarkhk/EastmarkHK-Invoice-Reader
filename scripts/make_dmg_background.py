#!/usr/bin/env python3
"""Generate a styled background image for the DMG installer window."""

from PIL import Image, ImageDraw, ImageFont

WIDTH, HEIGHT = 660, 400
BG = (236, 245, 241)
ACCENT = (46, 111, 94)
ACCENT_LIGHT = (207, 224, 218)
TEXT = (31, 45, 39)
MUTED = (100, 120, 112)

img = Image.new("RGB", (WIDTH, HEIGHT), BG)
draw = ImageDraw.Draw(img)

# Soft top band
for y in range(120):
    alpha = 1 - y / 120
    color = (
        int(BG[0] + (ACCENT_LIGHT[0] - BG[0]) * alpha * 0.35),
        int(BG[1] + (ACCENT_LIGHT[1] - BG[1]) * alpha * 0.35),
        int(BG[2] + (ACCENT_LIGHT[2] - BG[2]) * alpha * 0.35),
    )
    draw.line([(0, y), (WIDTH, y)], fill=color)

# Bottom subtle gradient
for y in range(HEIGHT - 80, HEIGHT):
    t = (y - (HEIGHT - 80)) / 80
    color = (
        int(BG[0] - 8 * t),
        int(BG[1] - 6 * t),
        int(BG[2] - 4 * t),
    )
    draw.line([(0, y), (WIDTH, y)], fill=color)

# Decorative arrow between app and Applications
arrow_y = 195
draw.polygon(
    [(300, arrow_y), (330, arrow_y + 16), (300, arrow_y + 32), (308, arrow_y + 16)],
    fill=ACCENT,
)
for offset in range(3):
    x = 250 + offset * 14
    draw.polygon([(x, arrow_y + 8), (x + 10, arrow_y + 16), (x, arrow_y + 24)], fill=ACCENT_LIGHT)

# Title
try:
    title_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 28)
    subtitle_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 14)
    hint_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 12)
except OSError:
    title_font = ImageFont.load_default()
    subtitle_font = title_font
    hint_font = title_font

draw.text((WIDTH // 2, 42), "EastmarkHK Invoice Reader", fill=TEXT, font=title_font, anchor="mm")
draw.text((WIDTH // 2, 78), "Drag the app to Applications", fill=MUTED, font=subtitle_font, anchor="mm")

# Drop zone hint
draw.rounded_rectangle((430, 130, 590, 270), radius=16, outline=ACCENT_LIGHT, width=2)
draw.text((510, 305), "Applications", fill=MUTED, font=hint_font, anchor="mm")

draw.rounded_rectangle((70, 130, 270, 270), radius=16, outline=ACCENT_LIGHT, width=2)

output = __import__("pathlib").Path(__file__).resolve().parent.parent / "assets" / "dmg_background.png"
img.save(output)
print(f"Wrote {output}")

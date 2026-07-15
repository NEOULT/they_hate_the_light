from PIL import Image, ImageDraw

SIZE = 32
DOT_RADIUS = 3
MARGIN = 7
OUT_DIR = "dado/sprites"

# Pip positions (center of each dot)
positions = {
    1: [(SIZE//2, SIZE//2)],
    2: [(SIZE - MARGIN, MARGIN), (MARGIN, SIZE - MARGIN)],
    3: [(SIZE - MARGIN, MARGIN), (SIZE//2, SIZE//2), (MARGIN, SIZE - MARGIN)],
    4: [(MARGIN, MARGIN), (SIZE - MARGIN, MARGIN), (MARGIN, SIZE - MARGIN), (SIZE - MARGIN, SIZE - MARGIN)],
    5: [(MARGIN, MARGIN), (SIZE - MARGIN, MARGIN), (SIZE//2, SIZE//2), (MARGIN, SIZE - MARGIN), (SIZE - MARGIN, SIZE - MARGIN)],
    6: [(MARGIN, MARGIN), (MARGIN, SIZE//2), (MARGIN, SIZE - MARGIN),
        (SIZE - MARGIN, MARGIN), (SIZE - MARGIN, SIZE//2), (SIZE - MARGIN, SIZE - MARGIN)],
}

for face in range(1, 7):
    # Transparent background
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # White-filled rounded rectangle with black border on transparent background
    draw.rounded_rectangle([1, 1, SIZE-2, SIZE-2], radius=4, fill=(255, 255, 255, 255), outline=(0, 0, 0, 255), width=2)

    # Draw dots (black circles)
    for cx, cy in positions[face]:
        draw.ellipse(
            [cx - DOT_RADIUS, cy - DOT_RADIUS, cx + DOT_RADIUS, cy + DOT_RADIUS],
            fill=(0, 0, 0, 255)
        )

    path = f"{OUT_DIR}/face_{face}.png"
    img.save(path)
    print(f"Saved {path}")

print("Done!")

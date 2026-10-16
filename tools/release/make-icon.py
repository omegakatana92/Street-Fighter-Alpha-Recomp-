#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Draws the port's icon, tools/release/sfa.png (256x256): a rising sun over the port's own navy,
with a golden ring and a fighter's silhouette-free sunburst. Everything here is arithmetic — no
artwork from the game is used or copied, so the releases ship none. Rebuild it with:

    python3 tools/release/make-icon.py

Each shape is rasterised with one bit per pixel at SS-times the final size, then averaged down, which
is what gives the edges their smoothness.
"""

import math
import os
import struct
import zlib

W = H = 256
SS = 3
SW = W * SS

SKY_TOP = (6, 10, 26)
SKY_BOTTOM = (30, 20, 40)
GLOW = (120, 40, 24)      # the warm light behind the sun
SUN = (214, 46, 40)       # the rising sun
SUN_HI = (240, 96, 64)    # its upper edge
RAY = (176, 58, 40)       # the sunburst
RING = (236, 182, 74)     # the golden ring
INK = (3, 5, 12)          # the outline


def mask_from_spans(rows):
    m = [0] * SW
    for y, spans in rows.items():
        ys = range(max(0, y * SS), min(SW, (y + 1) * SS))
        bits = 0
        for x0, x1 in spans:
            xa, xb = max(0, int(x0 * SS)), min(SW, int(x1 * SS))
            if xb > xa:
                bits |= ((1 << (xb - xa)) - 1) << xa
        for yy in ys:
            m[yy] |= bits
    return m


def polygon(points):
    spans = {}
    ys = [p[1] for p in points]
    for y in range(int(min(ys)), int(max(ys)) + 1):
        yc = y + 0.5
        xs = []
        for i in range(len(points)):
            x0, y0 = points[i]
            x1, y1 = points[(i + 1) % len(points)]
            if (y0 <= yc < y1) or (y1 <= yc < y0):
                xs.append(x0 + (yc - y0) * (x1 - x0) / (y1 - y0))
        xs.sort()
        spans[y] = [(xs[i], xs[i + 1]) for i in range(0, len(xs) - 1, 2)]
    return mask_from_spans(spans)


def ellipse(cx, cy, rx, ry):
    spans = {}
    for y in range(int(cy - ry), int(cy + ry) + 1):
        dy = (y + 0.5 - cy) / ry
        if abs(dy) >= 1:
            continue
        dx = rx * (1 - dy * dy) ** 0.5
        spans[y] = [(cx - dx, cx + dx)]
    return mask_from_spans(spans)


def union(*masks):
    out = [0] * SW
    for m in masks:
        for y in range(SW):
            out[y] |= m[y]
    return out


def intersect(a, b):
    return [a[y] & b[y] for y in range(SW)]


def spread(mask, r):
    out = mask[:]
    for dy in range(-r, r + 1):
        for y in range(SW):
            sy = y + dy
            if 0 <= sy < SW:
                out[y] |= mask[sy]
    for y in range(SW):
        row = out[y]
        acc = 0
        for dx in range(-r, r + 1):
            acc |= row << dx if dx > 0 else row >> -dx
        out[y] = acc & ((1 << SW) - 1)
    return out


def minus(a, b):
    return [a[y] & ~b[y] for y in range(SW)]


def coverage(mask):
    cov = [[0.0] * W for _ in range(H)]
    group = (1 << SS) - 1
    for y in range(H):
        rows = mask[y * SS:(y + 1) * SS]
        for x in range(W):
            sh = x * SS
            n = 0
            for row in rows:
                n += bin((row >> sh) & group).count("1")
            cov[y][x] = n / float(SS * SS)
    return cov


# --- the shapes -----------------------------------------------------------------------------------

def sunburst(inner, outer, rays, width):
    """A ring of triangular rays around the centre (128, 150)."""
    cx, cy = 128, 150
    parts = []
    for i in range(rays):
        a = 2 * math.pi * i / rays - math.pi / 2
        half = math.pi / rays * (width / 100.0)
        p0 = (cx + inner * math.cos(a), cy + inner * math.sin(a))
        p1 = (cx + outer * math.cos(a - half), cy + outer * math.sin(a - half))
        p2 = (cx + outer * math.cos(a + half), cy + outer * math.sin(a + half))
        parts.append(polygon([p0, p1, p2]))
    return union(*parts)


def background():
    img = [[[0.0] * 3 for _ in range(W)] for _ in range(H)]
    for y in range(H):
        t = y / float(H - 1)
        base = [SKY_TOP[i] + (SKY_BOTTOM[i] - SKY_TOP[i]) * t for i in range(3)]
        for x in range(W):
            d = (((x - 128) ** 2 + (y - 150) ** 2) ** 0.5) / 170.0
            glow = max(0.0, 1.0 - d) ** 2
            img[y][x] = [base[i] + (GLOW[i] - base[i]) * glow * 0.5 for i in range(3)]
    return img


def over(img, cov, colour):
    for y in range(H):
        for x in range(W):
            a = cov[y][x]
            if a:
                px = img[y][x]
                img[y][x] = [px[i] + (colour[i] - px[i]) * a for i in range(3)]


def main():
    disc = ellipse(128, 150, 74, 74)
    rays = minus(sunburst(80, 128, 24, 46), ellipse(128, 150, 76, 76))
    ring_out = ellipse(128, 150, 66, 66)
    ring_in = ellipse(128, 150, 58, 58)
    ring = minus(ring_out, ring_in)
    body = minus(disc, ring)
    hi = intersect(body, polygon([(0, 150), (256, 150), (256, 96), (0, 96)]))
    head = union(disc, rays)
    outline = minus(spread(head, 6), spread(head, 2))

    img = background()
    over(img, coverage(rays), RAY)
    over(img, coverage(outline), INK)
    over(img, coverage(body), SUN)
    over(img, coverage(hi), SUN_HI)
    over(img, coverage(ring), RING)

    rows = []
    for y in range(H):
        row = bytearray()
        for x in range(W):
            for i in range(3):
                row.append(max(0, min(255, int(img[y][x][i] + 0.5))))
        rows.append(row)

    raw = b"".join(b"\x00" + bytes(r) for r in rows)

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")

    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sfa.png")
    with open(out, "wb") as f:
        f.write(png)
    print("wrote %s (%d bytes)" % (out, len(png)))


if __name__ == "__main__":
    main()

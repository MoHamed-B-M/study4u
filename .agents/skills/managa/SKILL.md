---
name: comic-print-manga-ui
description: >-
  Enforces a high-contrast Neo-Brutalist, Manga, and Comic-Print UI style guide. 
  Replaces fluid or rounded Material Design components with sharp, raw, hand-drawn 
  elements featuring thick black ink borders, hard offset misprinted shadows, 
  and an aged newsprint background palette.
metadata:
  author: AI Collaborator
  version: "1.0"
---

# Comic-Print / Manga Design System

You are a UI Engineer specializing in stylized, retro-manga, and high-contrast web/mobile interfaces. You enforce structural layout rigidity reminiscent of comic book frames.

## Design Tokens

### 1. Color Specification
- **Paper Background (`paper_bg`):** `Color(0xFFFDFBF7)` — Core canvas scaffold.
- **Ink Black (`ink_black`):** `Color(0xFF000000)` — Primary text, thick borders, and hard drop shadows.
- **Ink Red (`ink_red`):** `Color(0xFFE63946)` — High-impact call-to-actions, alerts, badges, and focus items.
- **Surface White (`surface_white`):** `Color(0xFFFFFFFF)` — Card backgrounds providing flat contrast overlay panels.

### 2. Layout, Borders & Shadows
- **Borders:** All primary components (cards, text boxes, buttons) require a distinct flat border using `Border.all(color: Color(0xFF000000), width: 2.5)`. 
- **Corners:** Maintain sharp geometric edges. Do not use high-radius circular borders. Use `BorderRadius.zero` or a maximum of `BorderRadius.circular(2.0)`.
- **Misprinted Shadows:** Never use soft Gaussian blurs (`blurRadius: 0`). Shadows must be solid ink blocks offset diagonally to simulate shifting printing plates.
  ```dart
  boxShadow: [
    BoxShadow(
      color: Color(0xFF000000),
      offset: Offset(4, 4),
      blurRadius: 0,
    ),
  ]
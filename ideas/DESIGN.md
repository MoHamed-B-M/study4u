---
name: stdy4u
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#3d4a3e'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#6d7b6d'
  outline-variant: '#bccabb'
  surface-tint: '#006d36'
  primary: '#006d36'
  on-primary: '#ffffff'
  primary-container: '#4ade80'
  on-primary-container: '#005e2d'
  inverse-primary: '#4de082'
  secondary: '#006b5f'
  on-secondary: '#ffffff'
  secondary-container: '#62fae3'
  on-secondary-container: '#007165'
  tertiary: '#795900'
  on-tertiary: '#ffffff'
  tertiary-container: '#f6bb1f'
  on-tertiary-container: '#684c00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6dfe9c'
  primary-fixed-dim: '#4de082'
  on-primary-fixed: '#00210c'
  on-primary-fixed-variant: '#005227'
  secondary-fixed: '#62fae3'
  secondary-fixed-dim: '#3cddc7'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005047'
  tertiary-fixed: '#ffdf9f'
  tertiary-fixed-dim: '#f9bd22'
  on-tertiary-fixed: '#261a00'
  on-tertiary-fixed-variant: '#5c4300'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  display-lg:
    fontFamily: Outfit
    fontSize: 44px
    fontWeight: '800'
    lineHeight: 52px
    letterSpacing: -0.02em
  stat-lg:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Outfit
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md-mobile:
    fontFamily: Outfit
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-base:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: '0'
  body-bold:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: '0'
  label-caps:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 16px
  margin-desktop: 32px
  gutter: 16px
---

## Brand & Style
The design system embodies a fresh, premium academic workspace designed to motivate and de-stress students. It follows a **Material 3 Expressive** style, characterized by organic shapes, generous breathing room, and a vibrant, optimistic energy.

The aesthetic blends **Minimalism** with **Glassmorphism-lite** and **Corporate Modern** influences. It avoids the rigidity of traditional educational software in favor of a soft, tactile interface that feels like a high-end productivity lifestyle app. The UI should evoke feelings of clarity, progress, and calm focus through the use of gentle minty washes and energetic lime accents.

## Colors
The palette is built on a "Fresh Mint" foundation to reduce eye strain during long study sessions.

- **Primary (#4ADE80):** A vibrant lime-green used for the most important actions, active states, and motivational highlights.
- **Secondary (#2DD4BF):** A teal accent used for progress tracking, successful streaks, and data visualizations.
- **Tertiary (#FBBF24):** A warm amber used specifically for time-sensitive elements like Pomodoro timers and urgent deadlines.
- **Neutral (#1E293B):** A deep slate gray for primary text to ensure high legibility without the harshness of pure black.
- **System Surfaces:** Backgrounds use a soft mint wash (`#F4F9F6`), while cards use an off-white surface (`#F8FAF9`) or pure white to create subtle depth.

## Typography
The system uses a duo-font strategy to balance character with readability.

- **Outfit** is used for all display and heading roles. Its geometric yet slightly rounded terminals complement the extra-large corner radius of the UI components. Use `display-lg` for hero stats (like GPA) and `headline-md` for section headers.
- **Plus Jakarta Sans** handles the heavy lifting for body text and labels. It is chosen for its high x-height and modern, open feel, ensuring that dense task lists remain legible.
- **Line Heights:** Generous line heights are maintained to preserve the "spacious" feel of the design system. 
- **Hierarchy:** Ensure a strict 12px vertical margin between headers and body content to maintain group cohesion.

## Layout & Spacing
The layout follows a fluid-to-masonry transition model. 

- **Mobile:** A single-column vertical stack. Elements use the full width minus the 16px side margins.
- **Tablet/Desktop:** A multi-column staggered grid (masonry) that adapts based on screen width, capped at a maximum container width of 1200px.
- **Rhythm:** A 4px/8px baseline grid is used. However, top-level containers and dashboard widgets must use a minimum of 24px internal padding (`spacing.lg`) to ensure a premium, uncrowded appearance.
- **Whitespace:** Prioritize "macro-whitespace" between different functional blocks (24px to 32px) to prevent the academic data from feeling overwhelming.

## Elevation & Depth
Depth in this design system is achieved through **Tonal Layering** and **Soft Ambient Shadows** rather than traditional heavy dropshadows.

1.  **Base Layer:** The application background (`#F4F9F6`) acts as the canvas.
2.  **Surface Layer:** Cards and containers (`#F8FAF9`) sit slightly above the base with a subtle 1px hairline border (`#CBD5E1`) to define edges without adding visual weight.
3.  **Active Elevation:** Primary floating elements (like active Pomodoro widgets or bottom sheets) use a pure white surface (`#FFFFFF`) and a very soft, tinted shadow: `0 10px 20px rgba(74, 222, 128, 0.15)`.
4.  **Glassmorphism:** Use backdrop blurs (20px-30px) for navigation bars and overlay modals to maintain a sense of context and modern "airiness."

## Shapes
The shape language is defined by **extra-large, organic rounded corners** to create a friendly and approachable interface.

- **Standard Containers:** Use a radius of 28px to 32px (`rounded-xl` / `rounded-2xl`). This applies to course cards, dashboard widgets, and main content areas.
- **Small Elements:** Buttons and input fields should use a 16px radius (`rounded-md`) to maintain harmony without feeling too "bubbly."
- **Interactive Pills:** Navigation indicators, chips, and primary action buttons utilize a `rounded-full` (pill) shape to signify high interactability.

## Components

### Buttons
- **Primary:** High-profile pill shapes (56px height). Use a gentle linear gradient from Primary (`#4ADE80`) to Secondary (`#2DD4BF`). Text should be Deep Emerald (`#00391B`) for maximum contrast.
- **Secondary:** Transparent background with a 2px Primary border or a soft mint-tinted background.

### Cards & Widgets
- **Course Cards:** Feature 32px rounded corners. Include a soft interior gradient glow (5% opacity Primary in the top-left). 
- **Pomodoro Widget:** A large circular dial with a thick 8px track. Use Primary for the "active" segment and Tertiary for break states. Add a pulsing glow animation when the timer is active.

### Inputs & Forms
- **Fields:** 56px height with 16px rounded corners. On focus, the border should transition from Muted Gray to a 2px Primary stroke. Labels should use the "floating" Material style.

### Navigation
- **Bottom Bar:** A floating white dock with 32px top-corner radius. Active states are indicated by a soft mint capsule (`#D1FAE5`) behind the icon.
- **Chips:** Small, pill-shaped markers for categories (e.g., "Homework", "Exam"). Use `label-caps` typography inside.

### Feedback & Stats
- **Progress Bars:** Thick (8px+), rounded caps, using Primary and Secondary gradients to show completion.
- **Charts:** Use smooth, rounded line graphs with a soft gradient fill underneath the data line.
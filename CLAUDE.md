# Civics Test Tidbyt App

## Project Overview

A Tidbyt app written in **Starlark** (Pixlet framework) that displays USCIS civics test questions and answers on a Tidbyt LED display (64×32 pixels).

## Key File

- `civics_test.star` — the entire app: data, rendering logic, and schema config

## How It Works

Each render picks a new random question and plays this sequence:
1. **Flag intro** (~1.6s): Pixel-column sine wave animation — each of 64 columns shifts vertically by ±3px based on a sine lookup table
2. **"QUESTION" title card** (~2s): Gold text on black
3. **Question text** (15s): White, vertically centered if ≤60 chars, else scrolls via `render.Marquee`
4. **"ANSWER" title card** (~2s): Gold text on black
5. **Answer text** (10s): White, same centering/scrolling logic

## Data

- 128 USCIS civics questions with concise, screen-friendly answers in `QUESTIONS` list
- `pick_question()` seeds an LCG from the current timestamp (`YYYYMMDDHHmmss`) for a new question each render

## Rendering

- Display is 64×32 px at 10 fps (`FRAME_MS = 100`)
- Font: `tom-thumb` for content, `tb-8` for title cards
- Colors: `RED`, `WHITE`, `NAVY` (flag), `GOLD` (labels), `BLACK` (background)
- Flag wave: pixel-column approach using `SIN64` integer lookup table (no math lib in Starlark); run-length encoding per column keeps widget count low
- Vertical centering: `render.Box(height=30)` + `render.Column(main_align="center")` for short text; `render.Marquee(scroll_direction="vertical")` for long text (>60 chars)

## Deployment

```bash
make install    # install pixlet via Homebrew
make serve      # live preview at http://localhost:8080
make render     # produces civics_test.webp
make push       # render + push to device (requires env vars below)
```

Requires shell env vars:
```bash
export TIDBYT_DEVICE_ID=your_device_id
export TIDBYT_API_KEY=your_api_key
```

Push command: `pixlet push $TIDBYT_DEVICE_ID civics_test.webp --api-token $TIDBYT_API_KEY --installation-id civicstest`

## Starlark / Pixlet Notes

- Starlark is a Python-like language; no standard library, only Pixlet's built-in modules
- Available modules: `render.star`, `schema.star`, `time.star`
- No `math` module — use integer lookup tables for trig (see `SIN64`)
- `render.Animation` with `show_full_animation = True` plays all frames once
- `render.Marquee(scroll_direction="vertical")` scrolls content taller than its `height`
- `render.WrappedText` handles multi-line text within a fixed width
- Tidbyt installation IDs must be alphanumeric only (no underscores) — hence `civicstest` not `civics_test`
- Pushed WebP files are static — `time.now()` is evaluated at render time, not on each display cycle. For dynamic content, re-push on a schedule or publish to the Tidbyt community app store (which re-renders on their servers every ~15 min)

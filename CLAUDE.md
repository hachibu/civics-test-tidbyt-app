# Civics Test Tidbyt App

## Project Overview

A Tidbyt app written in **Starlark** (Pixlet framework) that displays daily USCIS civics test questions and answers on a Tidbyt LED display (64×32 pixels).

## Key File

- `civics_test.star` — the entire app: data, rendering logic, and schema config

## How It Works

1. **Flag intro** (~1.4s): An animated waving American flag with a shimmer sweep effect
2. **Question screen**: Shows a daily civics question (stable for the whole day via LCG hash of the date)
3. **Answer screen**: Reveals the answer after a configurable delay

## Data

- 128 USCIS civics questions with concise, screen-friendly answers in `QUESTIONS` list
- Daily question selection: `pick_for_today()` uses a linear congruential generator on the date (`20060102` format) so the same question shows all day

## Rendering

- Display is 64×32 px at 10 fps (`FRAME_MS = 100`)
- Font: `tom-thumb` (tiny pixel font for the small display)
- Colors: `RED`, `WHITE`, `NAVY` (flag colors), `GOLD` (answer text), `BLUE_LABEL` (question label), `GREY` (question on answer screen)
- Flag shimmer: translucent white band sweeps left-to-right across 14 frames

## Configuration (Tidbyt App Schema)

- `answer_delay`: Dropdown — 2, 3, 5, 7, or 10 seconds (default: 3)
- `show_question_with_answer`: Toggle — show question above answer when revealed (default: true)

## Local Development

```bash
make install                 # install pixlet via Homebrew
make serve                   # live preview at http://localhost:8080
make render                  # produces civics_test.webp
pixlet push <DEVICE_ID> civics_test.webp --installation-id civics  # push to device
```

## Starlark / Pixlet Notes

- Starlark is a Python-like language; no standard library, only Pixlet's built-in modules
- Available modules: `render.star`, `schema.star`, `time.star`
- `render.Animation` with `show_full_animation = True` plays all frames once
- `render.Stack` layers children on top of each other (used for flag + shimmer overlay)
- `render.WrappedText` handles multi-line text within a fixed width

## Session Learnings

<!-- Add learnings here as the session progresses -->

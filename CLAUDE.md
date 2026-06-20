# Civics Test Tidbyt App

## Project Overview

A Tidbyt app written in **Starlark** (Pixlet framework) that displays USCIS civics test questions and answers on a Tidbyt LED display (64×32 pixels).

## Key File

- `civics_test.star` — the entire app: data, rendering logic, and schema config

## How It Works

Each render picks a new question via timestamp seed and plays this sequence:
1. **Flag intro** (~1.6s): Pixel-column sine wave animation — each of 64 columns shifts vertically by ±3px based on a sine lookup table
2. **"QUESTION" title card** (~2s): Gold text on black
3. **Question text** (15s): White, vertically centered if ≤60 chars, else scrolls via `render.Marquee`
4. **"ANSWER" title card** (~2s): Gold text on black
5. **Answer text** (10s): White, same centering/scrolling logic

## Data

- 128 USCIS civics questions with concise, screen-friendly answers in `QUESTIONS` list
- `pick_question()` selects `QUESTIONS[timestamp % len(QUESTIONS)]` where `timestamp = int(time.now().format("20060102150405"))` — different on each render

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

## GitHub Actions Workflow

The app is automatically updated every 6 hours via GitHub Actions. The workflow:
1. Checks out the repo
2. Runs `make render` to generate a new WebP with a random question
3. Commits the updated `civics_test.webp` to `main`
4. Pushes to your Tidbyt device

**Setup**: Add these secrets to your GitHub repository settings:
- `TIDBYT_DEVICE_ID`: Your device ID
- `TIDBYT_API_KEY`: Your API key from Tidbyt

## Local Development

```bash
git clone https://github.com/hachibu/civics-test-tidbyt-app.git
cd civics-test-tidbyt-app
make install          # install pixlet (requires Homebrew)
make serve            # live preview at http://localhost:8080
make render           # test render without pushing
```

To test changes locally, edit `civics_test.star`, run `make serve`, and watch the preview update. Use `make check` before committing to catch formatting issues early.

## Design Rationale

- **Timestamp-based seeding** (`timestamp % len(QUESTIONS)`): Each render gets a unique timestamp seed, so every GitHub Actions push shows a different question. Gives users new content every 6 hours.
- **Run-length encoding in flag wave**: Starlark's `render.Column` with individual boxes is expensive. Instead of 64 columns × 32 rows = 2048 boxes, run-length encoding condenses each column into ~3–5 boxes, reducing total widget count to ~300.
- **SIN64 integer lookup table**: Starlark has no `math` module. Pre-computed `sin(2πi/64) × 256` for i in 0..63 gives smooth sine values via table lookup; no floating-point overhead.
- **Percentage-based timing**: Instead of fixed frame counts per section, `TOTAL_S` and percentage constants (`FLAG_PCT`, `Q_PCT`, etc.) keep the animation under Tidbyt's ~15s display limit and make timing adjustments clear and maintainable.
- **Scroll threshold heuristic** (≤60 chars): Text height can't be measured at render time. Centering short text works for most questions; longer text switches to vertical marquee scrolling. Tuned to fit common question lengths.

## Release Checklist

Before merging code changes:

1. **Test locally**: `make serve` and verify rendering looks correct
2. **Commit and push**: Create a PR to main
3. **Manual approval**: Merge PR to main after review
4. **GitHub Actions**: Workflow automatically renders and pushes to device every 6 hours

## Troubleshooting

- **`pixlet: command not found`**: Run `make install` to install via Homebrew
- **`make push` fails**: Ensure `TIDBYT_DEVICE_ID` and `TIDBYT_API_KEY` are set (`echo $TIDBYT_DEVICE_ID`)
- **GitHub Actions workflow fails**: Check that `TIDBYT_DEVICE_ID` and `TIDBYT_API_KEY` are set as repository secrets
- **Same question displayed locally**: That's expected — `time.now()` is frozen at render time. Rendered question changes with each `make render` call


## Starlark / Pixlet Notes

- Starlark is a Python-like language; no standard library, only Pixlet's built-in modules
- Available modules: `render.star`, `schema.star`, `time.star`
- No `math` module — use integer lookup tables for trig (see `SIN64`)
- `render.Animation` with `show_full_animation = True` plays all frames once
- `render.Marquee(scroll_direction="vertical")` scrolls content taller than its `height`
- `render.WrappedText` handles multi-line text within a fixed width
- Tidbyt installation IDs must be alphanumeric only (no underscores) — hence `civicstest` not `civics_test`
- Pushed WebP files are static — `time.now()` is evaluated at render time, not on each display cycle. GitHub Actions re-renders and pushes every 6 hours with a new random question

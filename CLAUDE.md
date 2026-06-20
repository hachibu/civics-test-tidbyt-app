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
- `pick_question()` selects `QUESTIONS[day % len(QUESTIONS)]` where `day = int(time.now().format("20060102"))` — stable all day, advances daily

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
make check      # run pixlet format + lint checks against the community fork (run before publishing)
```

Requires shell env vars:
```bash
export TIDBYT_DEVICE_ID=your_device_id
export TIDBYT_API_KEY=your_api_key
```

Push command: `pixlet push $TIDBYT_DEVICE_ID civics_test.webp --api-token $TIDBYT_API_KEY --installation-id civicstest`

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

- **Daily seeding** (`day % len(QUESTIONS)`): Pushed WebP is static; `time.now()` only evaluates at render time. Daily seeding ensures users see a different question each day with a single local push. For dynamic minute-by-minute updates, publish to the community store (Tidbyt re-renders every ~15 min).
- **Run-length encoding in flag wave**: Starlark's `render.Column` with individual boxes is expensive. Instead of 64 columns × 32 rows = 2048 boxes, run-length encoding condenses each column into ~3–5 boxes, reducing total widget count to ~300.
- **SIN64 integer lookup table**: Starlark has no `math` module. Pre-computed `sin(2πi/64) × 256` for i in 0..63 gives smooth sine values via table lookup; no floating-point overhead.
- **Percentage-based timing**: Instead of fixed frame counts per section, `TOTAL_S` and percentage constants (`FLAG_PCT`, `Q_PCT`, etc.) keep the animation under Tidbyt's ~15s display limit and make timing adjustments clear and maintainable.
- **Scroll threshold heuristic** (≤60 chars): Text height can't be measured at render time. Centering short text works for most questions; longer text switches to vertical marquee scrolling. Tuned to fit common question lengths.

## Release Checklist

Before pushing to production:

1. **Test locally**: `make serve` and verify rendering looks correct
2. **Verify formatting**: `make check` passes (buildifier, lint)
3. **Commit and push**: Create a PR to main
4. **CI passes**: GitHub Actions confirms formatting/lint OK
5. **Sync community fork**: `cp` files and push to `civics-test` branch
6. **Manual approval**: Merge PR to main after review
7. **Push to device** (optional): `make push` if you have a Tidbyt

## Troubleshooting

- **`pixlet: command not found`**: Run `make install` to install via Homebrew
- **`make push` fails**: Ensure `TIDBYT_DEVICE_ID` and `TIDBYT_API_KEY` are set (`echo $TIDBYT_DEVICE_ID`)
- **`make check` fails on formatting**: Run `pixlet format apps/civicstest/civics_test.star` locally to auto-fix
- **Community fork out of sync**: Run the sync commands from the "Community App Publishing" section
- **Same question displayed locally**: That's expected — `time.now()` is frozen at render time. Question changes daily; push to device to see daily rotation

## Community App Publishing

The app is published to the Tidbyt community store via a separate fork repo at `/tmp/tidbyt-community` (branch `civics-test`, PR #3224).

**Before publishing**, run `make check` to verify formatting and lint pass. Tidbyt CI enforces buildifier formatting (no column-alignment spaces, two-space inline comments) and flags unused variables — use `_` instead of `config` in `main()`.

**Every time `civics_test.star` or `manifest.yaml` changes**, sync the community fork:

```bash
cp civics_test.star /tmp/tidbyt-community/apps/civicstest/civics_test.star
cp manifest.yaml /tmp/tidbyt-community/apps/civicstest/manifest.yaml
cd /tmp/tidbyt-community
git add apps/civicstest/
git commit -m "your message"
git push origin civics-test
```

Key constraints from Tidbyt CI:
- `manifest.yaml` `summary` field must be **≤ 26 characters**
- `id` in manifest must be kebab-case (`civics-test`); `packageName` must be camelCase (`civicstest`)
- Installation ID passed to `pixlet push --installation-id` must be alphanumeric only

## Starlark / Pixlet Notes

- Starlark is a Python-like language; no standard library, only Pixlet's built-in modules
- Available modules: `render.star`, `schema.star`, `time.star`
- No `math` module — use integer lookup tables for trig (see `SIN64`)
- `render.Animation` with `show_full_animation = True` plays all frames once
- `render.Marquee(scroll_direction="vertical")` scrolls content taller than its `height`
- `render.WrappedText` handles multi-line text within a fixed width
- Tidbyt installation IDs must be alphanumeric only (no underscores) — hence `civicstest` not `civics_test`
- Pushed WebP files are static — `time.now()` is evaluated at render time, not on each display cycle. For dynamic content, re-push on a schedule or publish to the Tidbyt community app store (which re-renders on their servers every ~15 min)

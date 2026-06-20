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

The app is automatically updated and pushed to your Tidbyt via GitHub Actions:

**Triggers:**
1. On every commit to main (after checks pass)
2. Every 6 hours (0, 6, 12, 18 UTC) as a fallback
3. Manual trigger via Actions tab

**What it does:**
1. Checks out the repo
2. Installs pixlet
3. Renders a fresh `civics_test.webp` with a new question (via timestamp seed)
4. Pushes to your device
5. **Does not commit** changes back to main

Code changes are committed manually via PR; the workflow handles rendering and pushing automatically.

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

To test changes locally, edit `civics_test.star`, run `make serve`, and watch the preview update. After making code changes:
1. Run `make render` to generate the WebP
2. Commit **both** the code and WebP changes
3. Create a PR to main

The GitHub Actions workflow will then render and push new questions every 6 hours without committing.

## Design Rationale

- **Timestamp-based seeding** (`timestamp % len(QUESTIONS)`): Each render gets a unique timestamp seed. GitHub Actions renders every 6 hours with a fresh timestamp, so users see a different question each time.
- **Run-length encoding in flag wave**: Starlark's `render.Column` with individual boxes is expensive. Instead of 64 columns × 32 rows = 2048 boxes, run-length encoding condenses each column into ~3–5 boxes, reducing total widget count to ~300.
- **SIN64 integer lookup table**: Starlark has no `math` module. Pre-computed `sin(2πi/64) × 256` for i in 0..63 gives smooth sine values via table lookup; no floating-point overhead.
- **Percentage-based timing**: Instead of fixed frame counts per section, `TOTAL_S` and percentage constants (`FLAG_PCT`, `Q_PCT`, etc.) keep the animation under Tidbyt's ~15s display limit and make timing adjustments clear and maintainable.
- **Scroll threshold heuristic** (≤60 chars): Text height can't be measured at render time. Centering short text works for most questions; longer text switches to vertical marquee scrolling. Tuned to fit common question lengths.

## Release Checklist

Before merging code changes:

1. **Test locally**: `make serve` and verify rendering looks correct
2. **Render and commit**: Run `make render` to update `civics_test.webp`, then commit **both code and WebP changes** together in a single commit
3. **Create PR**: Push to a feature branch and create a PR to main
4. **Merge strategy**: Always **squash and merge** (or rebase and merge) to keep main history clean — each PR becomes one atomic commit on main
5. **GitHub Actions**: Workflow automatically renders and pushes new questions to device every 6 hours

## Important: Workflow Git Practice

**Before creating new feature branches**, always pull the latest from main:
```bash
git checkout main && git pull origin main
git checkout -b feature/your-feature-name
```

**Keep branches up to date with main** — if main advances while your PR is open, rebase:
```bash
git fetch origin
git rebase origin/main
git push origin feature-branch --force-with-lease
```

**For PRs**, when making changes during review or iteration:
- Amend the original commit: `git commit --amend`
- Force push to update the PR: `git push origin feature-branch --force-with-lease`
- Keep the PR as a single atomic commit (squashed if needed)

This keeps git history clean, avoids merge conflicts, and makes each PR one focused change.

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
- Pushed WebP files are static — `time.now()` is evaluated at render time, not on each display cycle. GitHub Actions renders with a fresh timestamp every 6 hours, generating a new WebP with a different question each time

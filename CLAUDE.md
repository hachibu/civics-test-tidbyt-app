# Civics Test Tidbyt App

## RULES — Follow These Exactly

1. **Always re-render before committing code changes.** Run `make render` after editing `civics_test.star`, then commit both the `.star` file and `civics_test.webp` together in a single commit.
2. **Keep PRs as a single atomic commit.** When iterating on a PR, amend the original commit (`git commit --amend`) and force-push (`git push origin branch --force-with-lease`). Do not add new commits to an open PR.
3. **Always squash and merge** (or rebase and merge) when merging PRs — never create merge commits on main.
4. **Branch from latest main.** Before creating a feature branch: `git checkout main && git pull origin main`.

---

## Project Overview

A Tidbyt app written in **Starlark** (Pixlet framework) that displays USCIS civics test questions and answers on a Tidbyt LED display (64×32 pixels).

**Key file:** `civics_test.star` — the entire app: data, rendering logic, and schema config.

## How It Works

Each render picks a new question via timestamp seed and plays this sequence:
1. **Flag intro** (~1.6s): Pixel-column sine wave animation
2. **"QUESTION" title card** (~2s): Gold text on black
3. **Question text** (15s): Vertically centered if ≤60 chars, else scrolls via `render.Marquee`
4. **"ANSWER" title card** (~2s): Gold text on black
5. **Answer text** (10s): Same centering/scrolling logic

## Data

- 128 USCIS civics questions with concise answers in `QUESTIONS` list
- `pick_question()` selects `QUESTIONS[timestamp % len(QUESTIONS)]` where `timestamp = int(time.now().format("20060102150405"))`

## Rendering

- Display is 64×32 px at 10 fps (`FRAME_MS = 100`)
- Font: `tom-thumb` for content, `tb-8` for title cards
- Colors: `RED`, `WHITE`, `NAVY` (flag), `GOLD` (labels), `BLACK` (background)
- Flag wave: pixel-column approach using `SIN64` integer lookup table; run-length encoding per column keeps widget count low (~300 widgets vs 2048 naive)
- Scroll threshold heuristic (≤60 chars): text height can't be measured at render time

## Development Commands

```bash
make install    # install pixlet via Homebrew
make serve      # live preview at http://localhost:8080
make render     # produces civics_test.webp
make push       # render + push to device
```

Requires env vars:
```bash
export TIDBYT_DEVICE_ID=your_device_id
export TIDBYT_API_KEY=your_api_key
```

## GitHub Actions Workflow

Automatically renders and pushes to your Tidbyt — triggers on every commit to main, every 6 hours (0/6/12/18 UTC), and manual dispatch. Does **not** commit back to main.

**Setup:** Add `TIDBYT_DEVICE_ID` and `TIDBYT_API_KEY` as repository secrets.

## Troubleshooting

- **`pixlet: command not found`**: Run `make install`
- **`make push` fails**: Check `TIDBYT_DEVICE_ID` and `TIDBYT_API_KEY` are set
- **GitHub Actions fails**: Check the same vars are set as repository secrets
- **Same question locally**: Expected — `time.now()` is frozen at render time; changes with each `make render` call

## Starlark / Pixlet Notes

- Python-like language; no standard library, only Pixlet's built-in modules
- Available modules: `render.star`, `schema.star`, `time.star`
- No `math` module — use integer lookup tables for trig (see `SIN64`)
- `render.Animation` with `show_full_animation = True` plays all frames once
- `render.Marquee(scroll_direction="vertical")` scrolls content taller than its `height`
- Tidbyt installation IDs must be alphanumeric only — hence `civicstest` not `civics_test`
- Pushed WebP files are static; `time.now()` is evaluated at render time, not display time

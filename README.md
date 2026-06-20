# Civics Test

A Tidbyt app that displays a new USCIS civics test question and answer each day. Study for the U.S. citizenship test one question at a time!

![Civics Test Preview](civics_test.webp)

## Features

- **128 official USCIS civics test questions** — all questions from the official citizenship test
- **Daily rotation** — a new question every day, same all day long
- **Animated flag intro** — waving American flag pixel animation
- **Auto-scrolling answers** — long answers scroll vertically; short ones center
- **Screen-friendly formatting** — designed for 64×32px LED displays

## How It Works

Each day when the app renders, it displays:
1. Animated waving American flag (~1.5s)
2. "QUESTION" title card
3. The question text (scrolls if long)
4. "ANSWER" title card  
5. The answer text (scrolls if long)

The animation loops and is ~15 seconds total — perfect for periodic glances at your Tidbyt display.

## Installation

Install via the [Tidbyt Community App Store](https://tidbyt.dev/docs/publish/publishing-apps) or push to your device manually:

```bash
pixlet render civics_test.star
pixlet push $TIDBYT_DEVICE_ID civics_test.webp --api-token $TIDBYT_API_KEY --installation-id civicstest
```

Requires `pixlet` (install via Homebrew: `brew install tidbyt/tidbyt/pixlet`)

## Development

See [CLAUDE.md](CLAUDE.md) for technical details, design decisions, and contribution guidelines.

Quick start:
```bash
make install    # install pixlet
make serve      # preview at http://localhost:8080
make check      # validate formatting & lint before committing
```

## License

Built by [hachibu](https://github.com/hachibu)  
Questions & answers sourced from [USCIS civics test](https://www.uscis.gov/citizenship/testupdates)

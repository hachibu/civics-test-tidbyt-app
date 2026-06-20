# Civics Test

Study for the U.S. citizenship test passively — your Tidbyt flips to a new question every 6 hours.

![Civics Test Preview](civics_test.webp)

All 128 official USCIS civics questions. Animated flag intro. Auto-scrolling answers. Zero effort required.

## Sideload

If you're running this outside the app store:

```bash
pixlet render civics_test.star
pixlet push $TIDBYT_DEVICE_ID civics_test.webp --api-token $TIDBYT_API_KEY --installation-id civicstest
```

Requires `pixlet`: `brew install tidbyt/tidbyt/pixlet`

## Develop

```bash
make install    # install pixlet
make serve      # preview at http://localhost:8080
make render     # generate civics_test.webp
```

---

Built by [hachibu](https://github.com/hachibu) · Questions from [USCIS](https://www.uscis.gov/citizenship/testupdates)

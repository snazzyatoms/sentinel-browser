<div align="center">

<img src="patches/pref-pane/category-sentinel.svg" width="96" alt="Sentinel logo"/>

# Sentinel Browser

A privacy-focused web browser built on Firefox — telemetry-free,
tracker-resistant, and bundled with uBlock Origin.

Sentinel is a fork of [LibreWolf](https://librewolf.net)'s build system
and patchset, applied to Mozilla Firefox release sources.

</div>

## Features

- **uBlock Origin bundled** — installed by default via enterprise policy,
  active in private windows too.
- **Anti-fingerprinting** — `privacy.resistFingerprinting` (Tor-style)
  enabled by default, including letterboxing.
- **Private search** — DuckDuckGo by default; Google removed from the
  built-in engine list.
- **No telemetry** — data reporting, crash reporter, studies, and the
  default-browser agent are disabled at compile time and via policy.
- **HTTPS-only mode**, total cookie protection (dFPI strict), WebRTC
  hardening, and query-parameter stripping out of the box.
- **AI features off** — sidebar chatbot, smart tab groups, link-preview
  key points and similar are blocked by policy.

The full settings list lives in [`settings/sentinel.cfg`](settings/sentinel.cfg)
— read it, it's meant to be customized.

## Build

Sentinel is built from Linux (Windows binaries are cross-compiled with
mingw — the same approach LibreWolf uses). On Windows hosts, use WSL2.

```bash
git clone https://github.com/snazzyatoms/sentinel-browser.git
cd sentinel-browser
make dir        # downloads + extracts + patches the Firefox source tree
make bootstrap  # installs the build toolchain (rust, clang, node, ...)
make build      # compile — expect ~45–90 min on a modern CPU
make package    # produce installable artifacts
```

Windows `.zip`/installer artifacts are produced through the bsys6
pipeline (`make test-windows` exercises it; a dedicated build doc is
planned).

## Repository layout

| Path | Purpose |
|---|---|
| `patches/` | Patches applied to the Firefox source tree |
| `settings/` | `sentinel.cfg`, enterprise `policies.json`, local-settings bootstrap |
| `themes/` | Branding (`browser/branding/sentinel`) + about-dialog overrides |
| `l10n/` | String overlays injected into each locale |
| `assets/` | mozconfig, search-config dumps, uBO assets, signing keys |
| `scripts/` | Patch driver (`sentinel-patches.py`), helpers |
| `tools/` | `generate-branding.py` — regenerates placeholder icons |

## Branding

Current artwork is generated placeholder art (shield + eye, navy/cyan).
Run `python tools/generate-branding.py` to regenerate. Real artwork
welcome.

## Acknowledgements

Sentinel is standing on the shoulders of:

- [Mozilla Firefox](https://www.firefox.com) (MPL-2.0)
- [LibreWolf](https://librewolf.net) — the patchset, settings, and build
  pipeline this repository is forked from

`Sentinel` is in no way affiliated with Mozilla; Firefox trademarks are
not used in built artifacts.

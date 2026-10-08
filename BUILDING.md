# Building Sentinel Browser

## Requirements

- **Windows host**: WSL2 with Ubuntu (Debian-family). The browser is
  cross-compiled for Windows from Linux (same approach as LibreWolf).
- ~60 GB free disk in the WSL filesystem, 16 GB+ RAM recommended.
- Internet access for the Firefox source tarball (~800 MB) and toolchain
  artifacts (~3 GB).

## Quick start (WSL2)

```bash
sudo apt update && sudo apt install -y git python3 make patch curl gpg pigz
git clone https://github.com/snazzyatoms/sentinel-browser.git
cd sentinel-browser

# full dependency set (includes mingw/wine/nsis helpers for Windows targets)
bash tools/setup-wsl.sh

make fetch      # downloads + verifies firefox-<version>.source.tar.xz
make dir        # extracts + applies Sentinel patches -> sentinel-<ver>-<rel>/
make bootstrap  # mach bootstraps the toolchain into ~/.mozbuild
```

## Windows build (cross-compile)

The source repo alone produces Linux builds. For Windows artifacts, use
the `sentinel-bsys6` pipeline (fork of LibreWolf's bsys6):

```bash
make all        # produce sentinel-<ver>-<rel>.source.tar.gz
git clone https://github.com/snazzyatoms/sentinel-bsys6.git ~/sentinel-bsys6
cd ~/sentinel-bsys6
SOURCE_TAR="/path/to/sentinel-<ver>-<rel>.source.tar.gz" \
  TARGET=windows ARCH=x86_64 ./bsys6 package portable setup
```

Produces `sentinel-<ver>-windows-x86_64.zip` (portable) and a NSIS
`setup.exe`. bsys6's `windows.mozconfig` adds `--target=x86_64-pc-windows-msvc`
and points at the MSVC sysroot fetched via mach artifact toolchains +
`get_vs.py` into `~/.mozbuild/win-cross`.

PGO: upstream bsys6 ships `.profdata` files via Git LFS; we stripped them
(history contained a pruned LFS object GitHub rejected). To rebuild PGO
profiles, run a `--enable-profile-generate` instrumented build.

## Releases

Upload artifacts with `gh release`:

```bash
gh release create v<ver>-<rel> \
  sentinel-<ver>-<rel>.source.tar.gz \
  sentinel-<ver>-windows-x86_64.zip sentinel-<ver>-windows-x86_64-setup.exe
```

The in-app "update available" check reads
`https://api.github.com/repos/snazzyatoms/sentinel-browser/releases`
(the `sentinel.aboutMenu.versionCheckGithubUrl` pref).

## Version tracking

`version` = upstream Firefox version, `release` = our packaging rev for
that Firefox version (reset to 1 on each Firefox bump).
Upstream sync: `git fetch upstream` (codeberg.org/librewolf/source) and
cherry-pick/merge, resolving the rename deltas.

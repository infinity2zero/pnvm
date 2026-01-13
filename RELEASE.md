# Release Guide

## Creating a Release

### Method 1: Using GitHub Actions (Automatic)

1. Create and push a git tag:
   ```bash
   git tag v2.0.0
   git push origin v2.0.0
   ```

2. GitHub Actions will automatically:
   - Package the release (universal, unix, windows)
   - Create a GitHub release
   - Upload the zip files as release assets
   - Track download counts automatically

### Method 2: Manual Release

1. Run the packaging script:
   ```bash
   ./package.sh v2.0.0
   ```

2. This creates zip files in the `release/` directory:
   - `pnvm-v2.0.0-universal.zip` (all platforms)
   - `pnvm-v2.0.0-unix.zip` (macOS/Linux only)
   - `pnvm-v2.0.0-windows.zip` (Windows only)

3. Create a GitHub release:
   - Go to GitHub → Releases → Draft a new release
   - Tag: `v2.0.0`
   - Title: `v2.0.0`
   - Upload the zip files from `release/` directory

## Download Tracking

GitHub automatically tracks download counts for release assets. You can view them:

1. Go to your repository → Releases
2. Click on a release
3. See download counts next to each asset

You can also use the GitHub API to get download stats programmatically:

```bash
# Get release info (replace with your repo)
curl https://api.github.com/repos/yourusername/pnvm/releases/latest
```

## Release Notes Template

```markdown
## What's New in v2.0.0

- Renamed to `pnvm` (Per-project Node Version Manager)
- Removed backward compatibility wrappers for cleaner codebase
- Improved sourcing support for zsh
- Windows direct execution (no `./` needed)

## Installation

Download the appropriate package for your OS:
- **Universal**: [pnvm-v2.0.0-universal.zip](link)
- **Unix**: [pnvm-v2.0.0-unix.zip](link)
- **Windows**: [pnvm-v2.0.0-windows.zip](link)

## Usage

```bash
# Windows
pnvm init
pnvm use 20.0.0

# Unix
./pnvm init
# Or: source ./pnvm (then use: pnvm init)
```
```

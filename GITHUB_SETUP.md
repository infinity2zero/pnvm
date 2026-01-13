# GitHub Release Setup Guide

## Quick Start

1. **Create GitHub Repository**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: pnvm v2.0.0"
   git remote add origin https://github.com/yourusername/pnvm.git
   git push -u origin main
   ```

2. **Create Your First Release**

   **Option A: Automatic (Recommended)**
   ```bash
   git tag v2.0.0
   git push origin v2.0.0
   ```
   GitHub Actions will automatically create the release and upload packages.

   **Option B: Manual**
   ```bash
   # Package locally
   ./package.sh v2.0.0
   
   # Create release on GitHub
   # 1. Go to: https://github.com/yourusername/pnvm/releases/new
   # 2. Tag: v2.0.0
   # 3. Title: v2.0.0
   # 4. Upload files from release/ directory
   ```

## Download Tracking

GitHub automatically tracks downloads for release assets. You can:

1. **View in GitHub UI**
   - Go to: `https://github.com/yourusername/pnvm/releases`
   - Click on any release
   - See download counts next to each asset

2. **Get via API**
   ```bash
   # Get latest release info
   curl https://api.github.com/repos/yourusername/pnvm/releases/latest
   
   # Get all releases with download stats
   curl https://api.github.com/repos/yourusername/pnvm/releases
   ```

3. **Add Download Badge** (Optional)
   Add to README.md:
   ```markdown
   ![GitHub release downloads](https://img.shields.io/github/downloads/yourusername/pnvm/total)
   ```

## Release Assets Created

Each release includes:
- `pnvm-v2.0.0-universal.zip` - All platforms (14KB)
- `pnvm-v2.0.0-unix.zip` - macOS/Linux only (10KB)
- `pnvm-v2.0.0-windows.zip` - Windows only (9.4KB)

## GitHub Actions

Two workflows are included:

1. **`.github/workflows/release.yml`**
   - Triggers on tag push (e.g., `v2.0.0`)
   - Automatically packages and creates release
   - Uploads all zip files

2. **`.github/workflows/package.yml`**
   - Manual trigger via GitHub UI
   - Packages without creating release
   - Useful for testing

## Update Repository URL

After creating your GitHub repo, update:
1. `README.md` - Replace `yourusername` with your GitHub username
2. `.github/workflows/*.yml` - Update repository references if needed

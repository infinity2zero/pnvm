
<img src="images/pnvm.png" alt="Logo"/>
# pnvm - Per-Project Node.js Version Manager

A portable, zero-admin Node.js version manager that works entirely within your project directory. Perfect for developers on corporate laptops without admin rights.

**pnvm** = Per-project Node Version Manager (like `nvm`, but 
per-project/portable/private)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/infinity2zero/pnenv?style=social)](https://github.com/infinity2zero/pnenv/stargazers)

> ⭐ **If you find this useful, please consider giving it a star!** It helps others discover the project and motivates continued development.

## Features

- ✅ Zero admin rights required
- ✅ Cross-platform (Windows, macOS, Linux)
- ✅ Auto-detects Node version from `package.json`
- ✅ Shared cache across projects
- ✅ Auto npm install on version switch

## Installation

### Step 1: Download

Download from [GitHub Releases](https://github.com/infinity2zero/pnenv/releases):
- **Windows**: `pnvm-v2.0.0-windows.zip`
- **Unix/macOS**: `pnvm-v2.0.0-unix-macos.zip`
- **Universal**: `pnvm-v2.0.0-universal.zip` (all platforms)

### Step 2: Extract and Copy to Project Root

**Windows:**
1. Extract the zip file
2. Inside you'll find: `pnvm-v2.0.0/pnvm.cmd`
3. **Copy `pnvm.cmd` to your project root directory**
4. Now you can use: `.\pnvm help`

**Unix/macOS:**
1. Extract the zip file
2. Inside you'll find: `pnvm-v2.0.0/pnvm`
3. **Copy `pnvm` to your project root directory**
4. Make it executable: `chmod +x pnvm`
5. Now you can use: `./pnvm help`

## Quick Start

**Windows:**
```cmd
.\pnvm init
.\pnvm use 20.0.0
.\pnvm node --version
.\pnvm npm install
```

**Unix/macOS:**
```bash
./pnvm init
./pnvm use 20.0.0
./pnvm node --version
./pnvm npm install

# Or source it to use without ./
source ./pnvm
pnvm help
```

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `pnvm init [version]` | Initialize pnvm in project. Auto-detects from `package.json` if no version specified. If no `package.json` exists, prompts for version (defaults to 20.0.0) | `pnvm init 20.0.0` |
| `pnvm use <version>` | Switch to Node version. Auto-runs `npm install` unless `--no-install` flag used | `pnvm use 20.0.0` |
| `pnvm list` | Show installed Node versions (active marked with `*`) | `pnvm list` |
| `pnvm current` | Show active Node version | `pnvm current` |
| `pnvm remove <version>` | Remove a Node version | `pnvm remove 18.0.0` |
| `pnvm node <args>` | Run Node.js commands | `pnvm node --version` |
| `pnvm npm <args>` | Run npm commands | `pnvm npm install` |
| `pnvm <script>` | Run npm script or alias | `pnvm dev` (runs `npm run dev`) |
| `pnvm alias <name> <cmd>` | Create command alias | `pnvm alias test "npm test"` |
| `pnvm unalias <name>` | Remove alias | `pnvm unalias test` |
| `pnvm aliases` | List all aliases | `pnvm aliases` |

## How It Works

- Stores Node.js runtimes in `.pnenv/` folder (gitignored)
- Active version stored in `.pnenv-version` (gitignored)
- Shared cache at `~/.pnenv/cache/` (Unix) or `%USERPROFILE%\.pnenv\cache\` (Windows)
- No system PATH modification - only affects current command execution

## Troubleshooting

**Windows: `pnvm` not recognized**
- Use `.\pnvm` instead of `pnvm`
- Make sure `pnvm.cmd` is in your project root

**Unix: Permission denied**
- Run: `chmod +x pnvm`

**Version detection not working**
- Manually specify: `pnvm init 20.0.0`

**Download failed**
- Check internet connection
- Verify version exists at https://nodejs.org/dist/

## Support

If `pnvm` has helped you overcome corporate laptop restrictions, consider:

- ⭐ **Starring the repository** - Helps others discover this tool
- 🐛 **Reporting issues** - Help improve the project
- 💡 **Suggesting features** - Share your ideas

---

**Developed by [infinity2zero](https://github.com/infinity2zero) with ❤️ , caffeine, and mild resentment toward corporate laptops.**

*Because sometimes you just need Node.js — not a ticket, a meeting, or admin rights.*

## License

MIT License - see [LICENSE](LICENSE) file for details.

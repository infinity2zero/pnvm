# pnvm - Per-Project Node.js Version Manager

A portable, zero-admin Node.js version manager that works entirely within your project directory. Perfect for developers on corporate laptops without admin rights.

**pnvm** = Per-project Node Version Manager (like `nvm`, but per-project)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/infinity2zero/pnenv?style=social)](https://github.com/infinity2zero/pnenv/stargazers)

> ⭐ **If you find this useful, please consider giving it a star!** It helps others discover the project and motivates continued development.

## Features

- ✅ **Zero Admin Rights Required** - Everything runs in your project directory
- ✅ **Cross-Platform** - Works on Windows, macOS, and Linux
- ✅ **Portable** - No system-wide installation or PATH pollution
- ✅ **Auto-Detection** - Automatically detects Node version from `package.json`
- ✅ **Shared Cache** - Reuses downloaded Node versions across projects
- ✅ **Command Aliases** - Create custom shortcuts for common commands
- ✅ **Auto npm install** - Automatically installs dependencies when switching versions

## Installation

### Option 1: Download from GitHub Releases (Recommended)

Download the appropriate package for your OS:

- **From GitHub Releases**: [Releases page](https://github.com/infinity2zero/pnenv/releases)
- **Direct download from repo**: [release folder](https://github.com/infinity2zero/pnenv/tree/main/release)

Available packages:
- **Universal** (all platforms): `pnvm-v2.0.0-universal.zip`
- **Unix/macOS** (same package for both): `pnvm-v2.0.0-unix-macos.zip`
- **Windows only**: `pnvm-v2.0.0-windows.zip`

Extract and copy the script(s) to your project root.

### Option 2: Manual Copy

Simply copy the appropriate script to your project:

- **Unix (macOS/Linux)**: Copy `pnvm` to your project root
- **Windows**: Copy `pnvm.cmd` to your project root

Make the Unix script executable:
```bash
chmod +x pnvm
```

## Quick Start

**Windows** (works directly without `./`):
```cmd
pnvm help
pnvm init
pnvm use 20.0.0
pnvm list
pnvm node --version
pnvm npm install
pnvm dev
```

**Unix (macOS/Linux)**:
```bash
# Direct execution
./pnvm init
./pnvm use 20.0.0
./pnvm list
./pnvm node --version
./pnvm npm install
./pnvm dev

# Or source it to use without ./
source ./pnvm
pnvm help
pnvm init
```

**Note**: On Windows, `pnvm.cmd` works directly without `./` because Windows automatically finds `.bat`/`.cmd` files in the current directory. On Unix, you need `./pnvm` unless you source it (see Advanced Usage below).

## Commands

### `pnvm help` or `pnvm init [version]`

Show help or initialize pnvm in your project. If no version is specified, pnvm will:
1. Try to detect the version from `package.json` `engines.node` field
2. Prompt you to enter a version (defaults to 20.0.0)

**Examples:**
```bash
# Windows (no ./ needed)
pnvm help
pnvm init
pnvm init 18.17.0

# Unix
./pnvm help
./pnvm init
./pnvm init 18.17.0
```

### `pnvm use <version> [--no-install]`

Switch to a different Node.js version. If the version isn't installed, you'll need to run `pnvm init <version>` first.

By default, `pnvm use` will automatically run `npm install` if:
- `node_modules` doesn't exist, or
- `package.json` is newer than `node_modules`

Use `--no-install` to skip automatic npm install.

**Examples:**
```bash
# Windows
pnvm use 20.0.0
pnvm use 18.17.0 --no-install

# Unix
./pnvm use 20.0.0
./pnvm use 18.17.0 --no-install
```

### `pnvm list`

List all Node.js versions installed in this project. The active version is marked with `*`.

**Example:**
```
Installed Node versions in this project:
  * 20.0.0
    18.17.0
    16.20.0
```

### `pnvm current`

Show the currently active Node.js version.

**Example:**
```
Current Node version: 20.0.0
```

### `pnvm remove <version>`

Remove a specific Node.js version from the project. If you remove the active version, you'll need to run `pnvm use` or `pnvm init` again.

**Example:**
```bash
# Windows
pnvm remove 16.20.0

# Unix
./pnvm remove 16.20.0
```

### `pnvm node <args>`

Run Node.js commands using the project's local Node.js installation.

**Examples:**
```bash
# Windows
pnvm node --version
pnvm node script.js

# Unix
./pnvm node --version
./pnvm node script.js
```

### `pnvm npm <args>`

Run npm commands using the project's local npm installation.

**Examples:**
```bash
# Windows
pnvm npm install
pnvm npm run build

# Unix
./pnvm npm install
./pnvm npm run build
```

### `pnvm <script-name>`

Run npm scripts defined in `package.json`. This is a shortcut for `pnvm npm run <script-name>`.

**Examples:**
```bash
# Windows
pnvm dev      # Runs: npm run dev
pnvm build    # Runs: npm run build

# Unix
./pnvm dev
./pnvm build
```

### `pnvm alias <name> <command>`

Create a custom command alias. Aliases are stored in `.pnenv-aliases` and can be executed with `pnvm <name>`.

**Examples:**
```bash
# Windows
pnvm alias test "npm run test:unit"
pnvm alias lint "npm run lint:fix"

# Unix
./pnvm alias test "npm run test:unit"
./pnvm alias lint "npm run lint:fix"
```

### `pnvm unalias <name>`

Remove a command alias.

**Example:**
```bash
# Windows
pnvm unalias test

# Unix
./pnvm unalias test
```

### `pnvm aliases`

List all defined aliases.

**Example:**
```
Defined aliases:
  test -> npm run test:unit
  lint -> npm run lint:fix
```

## Advanced Usage

### Using pnvm without `./` on Unix

On Unix systems, you can source the script to use `pnvm` without the `./` prefix:

```bash
# Source it once per terminal session
source ./pnvm

# You should see:
# ✓ pnvm function loaded. You can now use: pnvm help

# Now you can use pnvm directly
pnvm help
pnvm init
pnvm list
```

Or add a shell function to your `~/.zshrc` or `~/.bashrc`:

```bash
pnvm() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/pnvm" ] && [ -x "$dir/pnvm" ]; then
            "$dir/pnvm" "$@"
            return $?
        fi
        dir="$(dirname "$dir")"
    done
    echo "pnvm: not found in project directory" >&2
    return 1
}
```

## Auto-Detection from package.json

pnvm can automatically detect the required Node.js version from your `package.json`:

```json
{
  "engines": {
    "node": ">=18.0.0"
  }
}
```

When you run `pnvm init` without a version, pnvm will:
1. Parse the `engines.node` field
2. Extract the version number (handles `>=`, `~`, `^`, etc.)
3. Suggest using that version
4. Prompt for confirmation

## Shared Cache

pnvm uses a shared cache to avoid re-downloading Node.js versions across projects:

- **Unix**: `~/.pnenv/cache/`
- **Windows**: `%USERPROFILE%\.pnenv\cache\`

When you install a Node.js version:
1. pnvm checks the shared cache first
2. If found, copies from cache (much faster)
3. If not found, downloads and stores in both project cache and shared cache

This means the first project to use a version downloads it, and subsequent projects reuse the cached version.

## Project Structure

After initialization, your project will have:

```
your-project/
├── .pnenv/              # Node.js runtimes (gitignored - internal implementation)
│   ├── cache/           # Downloaded archives
│   └── node-v20.0.0-*/  # Extracted Node.js runtime
├── .pnenv-version       # Current active version (gitignored)
├── .pnenv-aliases      # Command aliases (gitignored)
├── pnvm                # The pnvm script (Unix)
└── pnvm.cmd            # The pnvm script (Windows)
```

**Note**: The `.pnenv` folder name is an internal implementation detail. The tool is called `pnvm` (Per-project Node Version Manager), similar to how `nvm` works globally.

## Platform Support

### Supported Platforms

- **Windows**: x64, ARM64
- **macOS**: x64 (Intel), ARM64 (Apple Silicon)
- **Linux**: x64, ARM64

### Archive Formats

- **Windows**: `.zip` files
- **macOS**: `.tar.gz` files
- **Linux**: `.tar.xz` files

## Requirements

### Unix (macOS/Linux)

- `bash` (version 4+)
- `curl` or `wget` for downloads
- `tar` for archive extraction

### Windows

- PowerShell (for downloads and extraction)
- Internet connection for downloading Node.js

## Troubleshooting

### "Neither curl nor wget found" (Unix)

Install one of these tools:
- **macOS**: `curl` comes pre-installed
- **Linux**: `sudo apt-get install curl` or `sudo apt-get install wget`

### "Failed to download Node"

Possible causes:
1. **Network issues**: Check your internet connection
2. **Corporate firewall**: May need to configure proxy settings
3. **Invalid version**: The version may not exist on nodejs.org

**Solution**: pnvm includes retry logic (3 attempts). If it still fails, verify the version exists at https://nodejs.org/dist/

### "Node runtime missing" after switching versions

This happens if you manually deleted a version directory or the version wasn't fully installed.

**Solution**: Run `pnvm init <version>` to reinstall the version.

### Auto npm install is too slow

Use the `--no-install` flag:
```bash
# Windows
pnvm use 20.0.0 --no-install

# Unix
./pnvm use 20.0.0 --no-install
```

### Shared cache not working

The shared cache is optional. If it fails (e.g., permission issues), pnvm falls back to project-local cache. This is normal and doesn't affect functionality.

### Version detection from package.json not working

pnvm uses simple pattern matching to extract versions. If your `engines.node` field uses complex ranges, it may not detect correctly.

**Example that works:**
```json
"engines": { "node": ">=18.0.0" }
"engines": { "node": "18.5.0" }
"engines": { "node": "~20.0.0" }
```

**Solution**: Manually specify the version: `pnvm init 20.0.0` (Windows) or `./pnvm init 20.0.0` (Unix)

### Aliases not working

Make sure:
1. The alias is defined: `pnvm aliases` (Windows) or `./pnvm aliases` (Unix)
2. You're using the correct name: `pnvm <alias-name>`
3. The command in the alias is valid

### Permission denied (Unix)

Make sure the script is executable:
```bash
chmod +x pnvm
```

## How It Works

1. **No PATH Pollution**: pnvm doesn't modify system PATH. It only modifies PATH for the current command execution.

2. **Portable**: Everything is stored in `.pnenv/` directory within your project. No global installation.

3. **No Admin Rights**: All operations happen in user-writable directories:
   - Project directory (`.pnenv/`)
   - User home directory (`~/.pnenv/cache/`)

4. **Version Management**: The active version is stored in `.pnenv-version`, which is read before executing any Node/npm command.

5. **Windows Direct Execution**: On Windows, `pnvm.cmd` works directly without `./` because Windows automatically finds `.bat`/`.cmd` files in the current directory.

6. **Naming**: `pnvm` = Per-project Node Version Manager (like `nvm`, but per-project). The internal `.pnenv` folder name is just an implementation detail.

## Comparison with nvm

| Feature | nvm | pnvm |
|---------|-----|------|
| Admin rights required | Sometimes | Never |
| System-wide installation | Yes | No |
| PATH modification | Global | Per-command |
| Per-project versions | Manual | Automatic |
| Portable | No | Yes |
| Works on corporate laptops | Often blocked | Always works |

## Best Practices

1. **Commit the script**: Add `pnvm` or `pnvm.cmd` to your repository so all team members can use it.

2. **Don't commit runtimes**: The `.pnenv/` directory is gitignored for good reason - it's large and platform-specific.

3. **Use version detection**: Let pnvm detect from `package.json` to keep versions in sync.

4. **Use aliases**: Create aliases for common commands to improve developer experience.

5. **Share the cache**: The shared cache speeds up setup for new projects.

6. **Use pnvm on Windows**: On Windows, `pnvm` works directly without `./` - take advantage of this!

## Download Statistics

GitHub automatically tracks download counts for each release. View statistics at:
- [GitHub Releases](https://github.com/infinity2zero/pnenv/releases)

Each release shows download counts for:
- Universal package (all platforms)
- Unix/macOS package (same for both)
- Windows package

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Feel free to submit issues or improvements. This tool is designed to be simple and portable.

## Support

If `pnvm` has helped you overcome corporate laptop restrictions, consider:

- ⭐ **Starring the repository** - Helps others discover this tool
- 🐛 **Reporting issues** - Help improve the project
- 💡 **Suggesting features** - Share your ideas

---

**Developed by [infinity2zero](https://github.com/infinity2zero) with ❤️ , caffeine, and mild resentment toward corporate laptops.**

*Because sometimes you just need Node.js — not a ticket, a meeting, or admin rights.*

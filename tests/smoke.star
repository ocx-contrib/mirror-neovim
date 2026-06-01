# Stable smoke test — assert on the contract (exit code, version shape,
# functional boot), never on help/version prose. Neovim reworks its banner,
# build info, and feature lines freely; the version digits and a clean
# headless boot are the contract.
NVIM = "nvim.exe" if ocx.target_platform.os == ocx.os.Windows else "nvim"

# Tier 1 + 2: liveness + version SHAPE (semver digits, not the "NVIM v…" banner).
r_version = ocx.run(NVIM, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional boot. --headless +q starts the full editor (loads the
# bundled runtime, initializes Lua) and quits — a far stronger liveness proof
# than --version, which short-circuits before real init. Exit 0 means the
# binary resolved on PATH, found its runtime, and booted clean.
r_boot = ocx.run(NVIM, "--headless", "+q")
expect.ok(r_boot)

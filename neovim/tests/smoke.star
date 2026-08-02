# neovim/tests/smoke.star — stable across upstream releases.
# Assert on the contract (exit code, version shape, computed result), never on
# help/version prose. Neovim reworks its banner, build info and feature lines
# freely; the digits, a clean headless boot and what Lua computes are the
# contract.
NVIM = "nvim.exe" if ocx.target_platform.os == ocx.os.Windows else "nvim"

# Hermetic env. `-u NONE` (below) skips every vimrc, and these point the whole
# config/state surface at the scratch sandbox so the runner's real home is
# neither read nor written. `USERPROFILE`/`LOCALAPPDATA` are the Windows
# spellings; the XDG vars are honoured on every platform, so both sets are set
# unconditionally rather than branched.
ISOLATED = {
    "HOME": ocx.scratch_root,
    "USERPROFILE": ocx.scratch_root,
    "LOCALAPPDATA": ocx.scratch_root,
    "XDG_CONFIG_HOME": ocx.scratch_root,
    "XDG_DATA_HOME": ocx.scratch_root,
    "XDG_STATE_HOME": ocx.scratch_root,
    "XDG_CACHE_HOME": ocx.scratch_root,
}

# Tier 1 + 2: liveness + version SHAPE (semver digits, not the "NVIM v…" banner).
r_version = ocx.run(NVIM, "--version", env = ISOLATED)
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: a computed value from a full headless boot, and the bundled runtime.
#
# `--version` short-circuits before real init; this starts the editor, runs Lua
# and quits. `io.write` goes to stdout (`print` would go to the message stream
# on stderr), so the assertion reads the value the interpreter actually
# produced — 2 from arithmetic, and 1 from `filereadable` on a file that exists
# only inside this bundle's `share/nvim/runtime/`. A bundle whose runtime tree
# failed to unpack, or whose `$VIMRUNTIME` resolved to some host install,
# answers `2:0` and reds here.
#
# `-i NONE` suppresses the shada file so nothing persists between runs.
LUA = "lua io.write(tostring(1 + 1) .. ':' .. vim.fn.filereadable(vim.env.VIMRUNTIME .. '/filetype.lua'))"

r_boot = ocx.run(NVIM, "-u", "NONE", "-i", "NONE", "--headless", "-c", LUA, "-c", "q", env = ISOLATED)
expect.ok(r_boot)
expect.contains(r_boot.stdout, "2:1")

# Tier 4: PATH is the only env var this package declares, and Tier 1 already
# proved it — `nvim` resolved by bare name. Nothing further to wire.

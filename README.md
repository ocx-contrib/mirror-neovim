# mirror-neovim

OCX mirror for [Neovim](https://github.com/neovim/neovim). One repository, one
spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [neovim](https://github.com/neovim/neovim) | [`neovim/mirror.yml`](neovim/mirror.yml) | `ghcr.io/ocx-contrib/neovim/neovim` | `ocx.sh/neovim/neovim` | `Apache-2.0 AND Vim` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/neovim`. `neovim/neovim` is the grouped successor — upstream's GitHub
> owner *is* `neovim`, so the namespace and the tool name coincide.

## Layout

```
mirror-base.yml            repo-wide policy every spec inherits via `extends:`
neovim/
├── mirror.yml             the spec — never at the repo root
├── metadata.json          bundle interface (linux + darwin)
├── metadata-windows.json  bundle interface (windows — larger binary set)
├── CATALOG.md             → ocx package describe
├── logo.svg / logo.png    describe assets, 512px PNG
└── tests/smoke.star       Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

`neovim` publishes six platform entries: both Linux arches, both macOS arches
and both Windows arches.

Both Linux keys carry **`+libc.glibc`**. `os.features` states what an artifact
requires *of the host*, and upstream's Linux `bin/nvim` is dynamically linked:
measured on v0.12.4 it carries a `PT_INTERP` naming the glibc loader
(`/lib64/ld-linux-x86-64.so.2` on amd64, `/lib/ld-linux-aarch64.so.1` on arm64)
plus `libm`, `libc` and `libgcc_s`. That is a hard host requirement, so the
bare keys this repo shipped before were a false claim of libc universality — an
empty `os.features` list means "demands nothing", which matches musl hosts the
binary cannot load on. Upstream publishes **no musl asset**, so there is no
`+libc.musl` counterpart; the glibc keys are the entire Linux surface. The
measurement itself is recorded above the `assets:` block in `neovim/mirror.yml`.

Container legs follow from the claim: `ubuntu:24.04` + `fedora:40` on each
Linux key, and **no alpine** — the renderer rejects an alpine leg on a glibc
key, and a glibc-linked binary genuinely cannot run there. `libgcc_s.so.1`, the
only non-base `DT_NEEDED`, ships in both images, so neither leg installs
anything.

The version floor is `0.11.0` — 0.10.4 and below use the legacy `nvim-linux64`
asset naming. `windows/arm64` has its own `min_version: "0.11.5"` gate in
`mirror-base.yml`, because `nvim-win-arm64.zip` first ships there; a global
floor bump would have cost the other five platforms four releases of history.

## The binaries claim

`bin_scan: verify`, two metadata files, because the binary set is
**platform-asymmetric**:

| Platform | Metadata file | Interface dir | Claim |
|---|---|---|---|
| `linux/*+libc.glibc`, `darwin/*` | `metadata.json` | `${installPath}/bin` | `nvim` |
| `windows/{amd64,arm64}` | `metadata-windows.json` | `${installPath}/bin` | `nvim tee win32yank xxd` |

Windows ships `win32yank.exe` and `xxd.exe` alongside `nvim.exe` in the same
`bin/`, plus `tee.exe` from v0.11.6 on. Under `verify` an on-PATH executable
the list omits **reds the run**, so the Windows legs cannot share the default
file — while a declared name merely *absent* from disk is legal, which is what
keeps `tee` green across v0.11.0..v0.11.5. Checked at both ends of the range
(v0.11.0 and v0.12.4) and at v0.11.3/v0.11.7/v0.12.0/v0.12.2 in between, since
`verify` reds every backfill on a set that drifted mid-range.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `neovim/mirror.yml` | hand | yes — see below |
| `neovim/{metadata*.json,CATALOG.md,logo.*}` | hand | — |
| `neovim/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec neovim/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; the
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md).

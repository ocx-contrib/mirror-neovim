# NOTICE

This repository packages and redistributes upstream software published by the
[Neovim project](https://github.com/neovim/neovim). The Apache-2.0 license in
[`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — the redistributed bytes carry their
own licenses, recorded below.

The Neovim name and logo are reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `neovim` | `ghcr.io/ocx-contrib/neovim/neovim` | `Apache-2.0 AND Vim` |

---

## `neovim`

Upstream: <https://github.com/neovim/neovim>
Published to `ghcr.io/ocx-contrib/neovim/neovim`.

| Component | SPDX | Holder |
|---|---|---|
| Neovim core (`bin/nvim`, `lib/nvim/`) | **Apache-2.0** | Copyright Neovim contributors |
| Bundled runtime (`share/nvim/runtime/`) | **Vim** | Copyright Bram Moolenaar et al. |

Upstream's [`LICENSE.txt`](https://github.com/neovim/neovim/blob/master/LICENSE.txt)
is a two-part document — the GitHub license API answers `NOASSERTION` for
exactly that reason, so the ids above are read off the file itself. Neovim is
Apache-2.0 "except for parts of Neovim that were contributed under the Vim
license"; the bundled `share/nvim/runtime/` tree is inherited from Vim and is
Vim-licensed. Both sets of bytes ship in the published bundle, so the recorded
expression is the conjunction `Apache-2.0 AND Vim` — classified by the most
restrictive license covering bytes actually redistributed.

Both are permissive for this use. Apache-2.0 grants redistribution provided the
license and attribution are preserved. The Vim license places **no restriction
on distributing unmodified copies** beyond including the license text — and the
text ships inside the artifact itself, at
`share/nvim/runtime/doc/uganda.txt`, alongside `pack/dist/opt/netrw/LICENSE.txt`
for the bundled netrw plugin. Upstream carries no `NOTICE` file to propagate.

The bundle also contains pre-built tree-sitter parsers (`lib/nvim/parser/*.so`)
built from upstream's vendored grammars, which are permissively licensed (MIT /
Apache-2.0) by their respective authors.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.

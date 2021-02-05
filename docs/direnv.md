# `direnv` integration

`direnv` is an extension for your shell.
It lets you load a development environment as soon as you enter the project directory.

See https://direnv.net/ to learn more.

To enable `direnv`, do the following:

1. Follow https://direnv.net/docs/installation.html to install `direnv`.

2. Create an `.envrc` file and place it in the project directory. Here are the recommended contents:

```bash
# Enable direnv + Nix integration.
# Entering the project directory will be equivalent to running `nix-shell`.
use nix


# Nix likes to set `TMPDIR` to `/run/user/$UID`, which is a typically a small temporary directory that is backed by RAM:

# $ df -h /run/user/$UID
# Filesystem      Size  Used Avail Use% Mounted on
# tmpfs           1.6G  116K  1.6G   1% /run/user/1000

# `clangd` language server uses `TMPDIR` if it is set to store temporary files. It can very quickly completely fill it in bigger C++ project.
# By unsetting this environment variable (or setting it to some other value), we prevent `clangd` from running out of space.
unset TMPDIR

# It is possible to write Nix expressions that behave differently depending on whether
# they are used with `nix-build` or `nix-shell`
# (see https://github.com/NixOS/nixpkgs/commit/4a91cfd32b44fede17f135b47ff0f035652f203e).
# Unsetting this environment variable ensures that `nix-build` does the same thing regardless of whether you use direnv or not.
unset IN_NIX_SHELL
```

3. Type `direnv allow` to enable it for the project directory.

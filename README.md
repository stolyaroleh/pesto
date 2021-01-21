# &#127807; Pesto 

Use [Nix](https://nixos.org/) and [Bazel](https://bazel.build/) to build C++ projects on Linux:

- **Choose from thousands of packages:** the [Nix Packages collection](https://github.com/NixOS/nixpkgs) is one of the [largest](https://repology.org/repositories/graphs) Linux package repositories, with over 60 000 packages.
Pesto uses it to provide C++ toolchain, build system and prebuilt libraries.

- **Never worry about your development environment again:** Nix makes it perfectly reproducible and self-contained. No need to use Docker containers.

- **Speed up your builds and tests:** Bazel provides fast and correct incremental builds.

- **Enjoy IDE support with compilation database and Clangd**

- **Format and lint your code with Clang Format and Clang Tidy**

- **Choose between any version of Clang or GCC**

## Getting Started

- [Install Nix](https://nixos.org/download.html)

- [Setup your project](./docs/project_setup.md)

- [Add dependencies](./docs/dependencies.md)

- [direnv integration](./docs/direnv.md) - load development environment automatically by entering project directory.

- [Package binaries and build Docker images](./docs/package.md)

## Advanced

- [CI hacks](./docs/hacks.md)
  
  Reuse Bazel cache when building with Nix.
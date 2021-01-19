{ nixpkgs ? import (import ./nix/sources.nix { }).nixpkgs }:
let
  nix2bazel = (
    nixpkgs {
      overlays = [
        (import ./nix/overlay.nix)
      ];
    }
  ).nix2bazel;
in
nix2bazel

{ nixpkgs ? import (import ./nix/sources.nix { }).nixpkgs }:
(
  nixpkgs {
    overlays = [
      (import ./nix/overlay.nix)
    ];
  }
).pesto

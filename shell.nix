{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs.buildPackages; [
    crystal_1_9
    shards
    crystalline
    sqlite      # libsqlite
    gmp         # libgmp
    file        # libmagic
  ];
}
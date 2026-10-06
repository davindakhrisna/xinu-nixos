{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [ gcc binutils gnumake flex bison gawk ];
}

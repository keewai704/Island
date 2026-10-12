{
  description = "Island: impasto's dynamic-island Quickshell shell with HyprFlux touches, packaged for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    impasto = {
      url = "github:keewai704/impasto/main";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      impasto,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      eachSystem = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      packageFor = pkgs: pkgs.callPackage ./nix/package.nix { inherit impasto; };
    in
    {
      packages = eachSystem (pkgs: rec {
        island = packageFor pkgs;
        default = island;
      });

      homeManagerModules.default = import ./nix/home-manager.nix packageFor;
      nixosModules.default = import ./nix/nixos.nix;

      checks = eachSystem (
        pkgs:
        let
          island = self.packages.${pkgs.stdenv.hostPlatform.system}.island;
        in
        {
          inherit island;
          paths =
            pkgs.runCommand "island-paths-check"
              {
                nativeBuildInputs = [
                  pkgs.python3
                  pkgs.ripgrep
                  pkgs.shellcheck
                ];
              }
              ''
                shell=${island}/share/quickshell/island
                ! rg -n '/usr/share/(icons|unicode|iso-codes|X11)' "$shell"
                for path in $(rg -oN --no-filename '/nix/store/[a-z0-9]{32}-(papirus|unicode-emoji|cldr|iso-codes|xkeyboard)[^"` ]*' "$shell" | sed 's/\$.*//; s|/$||' | sort -u); do
                  test -e "$path" || { echo "missing $path"; exit 1; }
                done
                for script in "$shell"/scripts/*.py; do
                  python3 -c 'import sys; compile(open(sys.argv[1]).read(), sys.argv[1], "exec")' "$script"
                done
                shellcheck ${./scripts/wallpaper-effect.sh}
                touch "$out"
              '';
        }
      );

      formatter = eachSystem (pkgs: pkgs.nixfmt);
    };
}

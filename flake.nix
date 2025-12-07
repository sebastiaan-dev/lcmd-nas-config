{
  description = "Development environment for terraform-provider-lcmd";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    vps-nix.url = "github:sebastiaan-dev/vps-nix";
    vps-nix.flake = false;
  };

  outputs =
    inputs@{
      flake-parts,
      devenv-root,
      self,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          lib,
          ...
        }:
        {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          # Enable unfree packages.
          _module.args.pkgs = import self.inputs.nixpkgs {
            inherit system;
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "terraform"
              ];
          };

          devenv.shells.default = {
            name = "terraform-provider-lcmd";

            languages.go.enable = true;

            imports = [
              # This is just like the imports in devenv.nix.
              # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
              # ./devenv-foo.nix
              "${inputs.vps-nix}/devenv/python-module.nix"
              "${inputs.vps-nix}/devenv/node-module.nix"
            ];

            # https://devenv.sh/reference/options/
            packages = [
              pkgs.terraform
              # Make `lzc-cli` available in PATH and delegate to `yarn lzc-cli`
              (pkgs.writeShellScriptBin "lzc-cli" ''
                #!${pkgs.bash}/bin/bash
                set -euo pipefail

                # devenv sets DEVENV_ROOT to your project root
                cd "''${DEVENV_ROOT:-.}"

                npx lzc-cli "$@"
              '')
            ];
          };

        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}

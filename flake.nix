{
  description = "A highly structured configuration database.";

  inputs =
    {
      nixos.url = "nixpkgs/nixos-unstable";
      override.url = "nixpkgs";
      ci-agent = {
        url = "github:hercules-ci/hercules-ci-agent";
        inputs = { nix-darwin.follows = "darwin"; flake-compat.follows = "flake-compat"; nixos-20_09.follows = "nixos"; nixos-unstable.follows = "override"; };
      };
      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "override";
      deploy = {
        url = "github:serokell/deploy-rs";
        inputs = { flake-compat.follows = "flake-compat"; naersk.follows = "naersk"; nixpkgs.follows = "override"; utils.follows = "utils"; };
      };
      devshell.url = "github:numtide/devshell";
      flake-compat.url = "github:BBBSnowball/flake-compat/pr-1";
      flake-compat.flake = false;
      home.url = "github:nix-community/home-manager";
      home.inputs.nixpkgs.follows = "nixos";
      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "override";
      nixos-hardware.url = "github:nixos/nixos-hardware";
      utils.url = "github:numtide/flake-utils/flatten-tree-system";
      pkgs.url = "path:./pkgs";
      pkgs.inputs.nixpkgs.follows = "nixos";
    };

    outputs = inputs@{ deploy, nixos, nur, self, utils, ... }:
      let
        lib = import ./lib { inherit self nixos inputs; };
        inherit (lib.os) importIfExists;

        out = lib.mkFlake {
          inherit self;
          hosts = ./hosts;
          packages = importIfExists ./pkgs;
          suites = importIfExists ./suites;
          extern = importIfExists ./extern;
          overrides = importIfExists ./overrides;
          overlays = ./overlays;
          profiles = ./profiles;
          userProfiles = ./users/profiles;
          modules = importIfExists ./modules/module-list.nix;
          userModules = importIfExists ./users/modules/module-list.nix;
        };

      in nixos.lib.recursiveUpdate out {
        defaultTemplate = self.templates.flk;
        templates.flk.path = builtins.toPath self;
        templates.flk.description = "flk template";
        templates.mkdevos.path =
          let
            excludes = [ "lib" "tests" "cachix" "nix" "theme" ".github" "bors.toml" "cachix.nix" ];
            filter = path: type: ! builtins.elem (baseNameOf path) excludes;
          in
            builtins.filterSource filter ../..;
        templates.mkdevos.description = "for mkDevos usage";
      }
}

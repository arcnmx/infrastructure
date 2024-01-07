{
  inputs,
  system ? builtins.currentSystem or "x86_64-linux",
  ...
}: let
  patchedInputs = import ./patchedInputs.nix {inherit inputs system;};
  pkgs = import ./overlays {
    inherit system;
    inputs = patchedInputs;
  };
  inherit (pkgs) lib;
  tree = import ./tree.nix {
    inherit lib;
    inputs = patchedInputs;
  };
  root = ./.; # Required for modules/meta/imports.nix to find hosts
  nixfiles = tree.impure;

  eval = let
    nixosNodes = [
      {
        network.nodes.tewi = {
          imports = [
            ./systems/tewi/nixos.nix
            nixfiles.nixos.base
          ];
        };
        network.nodes.tei = {
          imports = [
            ./systems/tei/nixos.nix
            nixfiles.nixos.base
          ];
        };
        network.nodes.reisen-ct = {
          imports = [
            ./systems/ct/nixos.nix
            nixfiles.nixos.base
          ];
        };
      }
    ];
  in
    lib.evalModules {
      modules =
        [
          nixfiles.modules.meta
          {
            _module.args.pkgs = lib.mkDefault pkgs;
          }
        ]
        ++ nixosNodes;

      specialArgs =
        {
          inherit root tree;
          inputs = patchedInputs;
          meta = self;
        }
        // nixfiles;
    };

  inherit (eval) config;
  self =
    config
    // {
      inherit pkgs lib tree;
      inputs = patchedInputs;
    }
    // nixfiles;
in
  self

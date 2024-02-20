{
  name,
  config,
  meta,
  std,
  lib,
  inputs,
  ...
}: let
  inherit (lib.modules) mkOptionDefault;
  inherit (std) string;
in {
  options = let
    inherit (lib.types) str listOf attrs unspecified enum nullOr;
    inherit (lib.options) mkOption;
  in {
    arch = mkOption {
      description = "Processor architecture of the host";
      type = str;
      default = "x86_64";
    };
    type = mkOption {
      description = "Operating system type of the host";
      type = nullOr (enum ["NixOS" "MacOS" "Darwin" "Linux"]);
      default = "NixOS";
    };
    folder = mkOption {
      type = str;
      internal = true;
    };
    system = mkOption {
      type = str;
      internal = true;
    };
    modules = mkOption {
      type = listOf unspecified;
    };
    specialArgs = mkOption {
      type = attrs;
      internal = true;
    };
    builder = mkOption {
      type = unspecified;
      internal = true;
    };
    built = mkOption {
      type = unspecified;
      internal = true;
    };
  };
  config = {
    system = let
      kernel =
        {
          nixos = "linux";
          macos = "darwin";
          darwin = "darwin";
          linux = "linux";
        }
        .${string.toLower config.type};
    in "${config.arch}-${kernel}";
    folder =
      {
        nixos = "nixos";
        macos = "darwin";
        darwin = "darwin";
        linux = "linux";
      }
      .${string.toLower config.type};
    modules = [
      # per-OS modules
      meta.modules.${config.folder}
      # per-OS configuration
      meta.${config.folder}.base
    ];
    builder =
      {
        nixos = let
          lib = inputs.nixpkgs.lib.extend (self: super:
            import (inputs.arcexprs + "/lib") {
              inherit super;
              lib = self;
              isOverlayLib = true;
            });
          sys = args:
            lib.nixosSystem ({
                inherit lib;
              }
              // args);
        in
          sys;
        darwin = inputs.darwin.lib.darwinSystem;
        macos = inputs.darwin.lib.darwinSystem;
      }
      .${string.toLower config.type};
    built = mkOptionDefault (config.builder {
      inherit (config) system modules specialArgs;
    });
    specialArgs = {
      inherit name inputs std meta;
      systemType = config.folder;
      system = config;
    };
  };
}

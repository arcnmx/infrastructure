{
  lib,
  config,
  channels,
  env,
  ...
}:
with lib; {
  name = "nodes";

  nixpkgs.args.localSystem = "x86_64-linux";

  ci = {
    version = "v0.6";
    gh-actions = {
      enable = true;
      export = true;
    };
  };
  channels.nixfiles.path = ../.;

  nix.config = {
    accept-flake-config = true;
    extra-platforms = ["aarch64-linux" "armv6l-linux" "armv7l-linux"];
    #extra-sandbox-paths = with channels.cipkgs; map (package: builtins.unsafeDiscardStringContext "${package}?") [bash qemu "/run/binfmt"];
  };

  gh-actions = {
    jobs = mkIf (config.id != "ci") {
      ${config.id}.step.architectures = {
        order = 201;
        name = "prepare for emulated builds";
        run = ''
          sudo $(which archbinfmt)
        '';
      };
    };
  };

  environment.bootstrap = {
    archbinfmt = let
      makeQemuWrapper = name: ''
        mkdir -p /run/binfmt
        rm -f /run/binfmt/${name}-linux
        cat > /run/binfmt/${name}-linux << 'EOF'
        #!${channels.cipkgs.bash}/bin/sh
        exec -- ${channels.cipkgs.qemu}/bin/qemu-${name} "$@"
        EOF
        chmod +x /run/binfmt/${name}-linux
      '';
    in
      channels.cipkgs.writeShellScriptBin "archbinfmt" ''
        ${makeQemuWrapper "aarch64"}
        ${makeQemuWrapper "arm"}
        echo 'extra-sandbox-paths = ${channels.cipkgs.bash} ${channels.cipkgs.qemu} /run/binfmt' >> /etc/nix/nix.conf
        echo ':aarch64-linux:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff:/run/binfmt/aarch64-linux:' > /proc/sys/fs/binfmt_misc/register
        echo ':armv6l-linux:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff:/run/binfmt/arm-linux:' > /proc/sys/fs/binfmt_misc/register
        echo ':armv7l-linux:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff:/run/binfmt/arm-linux:' > /proc/sys/fs/binfmt_misc/register
      '';
  };

  jobs = let
    enabledHosts = ["hakurei" "reimu" "aya" "tei" "mediabox" "ct"];
  in
    mapAttrs' (k: nameValuePair "${k}") (genAttrs enabledHosts (host: {
      tasks.${host}.inputs = channels.nixfiles.nixosConfigurations.${host}.config.system.build.toplevel;
    }));

  ci.gh-actions.checkoutOptions.submodules = false;
  cache.cachix.arc = {
    enable = true;
    publicKey = "arc.cachix.org-1:DZmhclLkB6UO0rc0rBzNpwFbbaeLfyn+fYccuAy7YVY=";
  };
  cache.cachix.gensokyo-infrastructure = {
    enable = true;
    publicKey = "gensokyo-infrastructure.cachix.org-1:CY6ChfQ8KTUdwWoMbo8ZWr2QCLMXUQspHAxywnS2FyI=";
    signingKey = "mewp";
  };
}

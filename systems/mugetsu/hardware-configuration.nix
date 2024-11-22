{
  meta,
  config,
  ...
}: {
  imports = let
    inherit (meta) nixos;
  in [
    nixos.hw.c4130
  ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };

  networking.useNetworkd = true;
  systemd.network = {
    networks."40-eno1" = {
      inherit (config.systemd.network.links.eno1) matchConfig;
      address = ["10.1.1.60/24"];
      gateway = ["10.1.1.1"];
      DHCP = "no";
      networkConfig = {
        IPv6AcceptRA = true;
      };
      linkConfig = {
        Multicast = true;
      };
    };
    links.eno1 = {
      matchConfig = {
        Type = "ether";
        MACAddress = "64:00:6a:c0:a1:4c";
      };
    };
  };
}

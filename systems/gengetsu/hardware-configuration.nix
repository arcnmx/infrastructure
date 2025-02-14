{
  meta,
  config,
  ...
}: {
  imports = let
    inherit (meta) nixos;
  in [
    nixos.hw.c4130
    nixos.netboot.kyuuto
  ];

  fileSystems = {
    "/mnt/root-old" = {
      device = "/dev/disk/by-uuid/bf317f5d-ffc2-45fd-9621-b645ff7223fc";
      fsType = "xfs";
      options = ["x-systemd.automount" "lazytime" "noatime" "noauto" "nofail"];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };

  networking.useNetworkd = true;
  systemd.network = {
    networks."10-eno1" = {
      inherit (config.systemd.network.links."10-eno1") matchConfig;
      address = ["10.1.1.61/24"];
      gateway = ["10.1.1.1"];
      DHCP = "no";
      networkConfig = {
        IPv6AcceptRA = true;
      };
      linkConfig = {
        Multicast = true;
      };
    };
    links = {
      "10-eno1" = {
        matchConfig = {
          Type = "ether";
          MACAddress = "54:48:10:f3:fe:aa";
        };
      };
      "10-eno2" = {
        matchConfig = {
          Type = "ether";
          MACAddress = "54:48:10:f3:fe:ac";
        };
      };
    };
  };
}

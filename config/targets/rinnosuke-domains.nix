{ config, ... }:

let rinnosuke = config.network.nodes.rinnosuke; in
{
  deploy.targets.rinnosuke-domains.tf = {
    dns.records = {
      node_public_rinnosuke_v4 = {
        inherit (rinnosuke.network.dns) zone;
        domain = rinnosuke.networking.hostName;
        a.address = rinnosuke.network.addresses.public.nixos.ipv4.address;
      };
      node_public_rinnosuke_v6 = {
        inherit (rinnosuke.network.dns) zone;
        domain = rinnosuke.networking.hostName;
        aaaa.address = rinnosuke.network.addresses.public.nixos.ipv6.address;
      };
      node_wireguard_rinnosuke_v4 = {
        inherit (rinnosuke.network.dns) zone;
        domain = rinnosuke.network.addresses.wireguard.subdomain;
        a.address = rinnosuke.network.addresses.wireguard.nixos.ipv4.address;
      };
      node_wireguard_rinnosuke_v6 = {
        inherit (rinnosuke.network.dns) zone;
        domain = rinnosuke.network.addresses.wireguard.subdomain;
        aaaa.address = rinnosuke.network.addresses.wireguard.nixos.ipv6.address;
      };
      node_yggdrasil_rinnosuke_v6 = {
        inherit (rinnosuke.network.dns) zone;
        domain = rinnosuke.network.addresses.yggdrasil.subdomain;
        aaaa.address = rinnosuke.network.addresses.yggdrasil.nixos.ipv6.address;
      };
    };
  };
}

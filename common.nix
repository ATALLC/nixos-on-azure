{ username }:
{ pkgs, modulesPath, ... }: {
  imports = [ "${modulesPath}/virtualisation/azure-common.nix" ];

  system.stateVersion = "24.05";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.growPartition = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  virtualisation.azure.agent.enable = true;
  services.cloud-init.enable = true;
  systemd.services.cloud-config.serviceConfig = { Restart = "on-failure"; };
  services.cloud-init.network.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;

  programs.zsh.enable = true;
  users.users."${username}" = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLbrIDbLSEpfOc4onBP8y6aKCNEN5rEe0J3h7klfKzG mcamp@butler"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICnIDQryNiERcduqFFq/dF92U32GHYrMicZs7qThIHEp bruce"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxNjPTsNNdhgO8lBMSaR62ymenruxA9W5mgBGdRgpMRzWUCBL6J7Jp33cXzdJfChNXvHGffD84N5nuHAbE4SoaWQa/SdDiSn/DTMAfClCGX+x4gA1WDbmAjmBSW4wKHuUe1rHgibqdEguljS21WZOu8xOQm/q6SLqI9dm0Wxv8LCJImMXANrar7LD5OcnKerqmX7fSdM/qZVqQB/uvVeb7sPsOROwDHFIB8L+peTxpKsQ+Bbv0W5I+ZYbWvQ1IdgjSRd7erRmF7+TQQXriZxBwSp62sgmk023igCPnJFzCKOk0DU+8qiCKGOsMSNBZeVhEDZYIwfxBaWqGbJ/v6bwmNKZi8VD0ap2shYQv5uw0UZTxsWUTu7rsg4PzdJWZ8QtbmPgUxDKhqqJsTGal2MlHSWgevLie8SDPy2zChocPVhr34qXtIViMqBTgbx4GMQtyFOxxKn5trJUK7rqOSC0164cdJcLv8GXplkiS2ToZMxfviW1T9sooI651R5iNtTU= cdf-key"
    ];
    shell = pkgs.zsh;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  environment.systemPackages = with pkgs; [ curl git vim ];

  nix.settings = {
    warn-dirty = false;
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ username ];
  };
}

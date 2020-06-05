# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../shared/efi.nix
    ../../shared/default.nix
    ./firewall.nix
  ];

  networking.hostName = "nixos-virtualbox"; # Define your hostname.

  # configure bspwm
  programs.bspwm.enable = true;
  services.xserver.displayManager.defaultSession = "none+bspwm";

  # configure alacritty
  programs.alacritty = {
    enable = true;
    brightBold = true;
  };

  #services.xserver.displayManager.sddm.autoLogin = {
  #  enable = true;
  #  user = "root";
  #};

  users.users.root = {
    hashedPassword = import ../../secrets/kranex/hashedPassword.nix;
  };
}

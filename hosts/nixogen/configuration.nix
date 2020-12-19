##########################
## AMD LENOVO E15 GEN 2 ##
##########################
## Partitions:          ##
## /dev/nvme1: EFI BOOT ##
## /dev/nvme2: LUKS LVM ##
##     /swap : 12 GB    ##
##     /root : 100%FREE ##
##########################

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../shared/users.nix
      ../../shared/work.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  #################
  ## E15 Specific

  # The E15 needs the latest linux kernel for Radeon graphics to work.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ##################
  ## Work specific

  # Work devices are "Other non metals" and this one is running Nixos.
  # Nixos + Nitrogen = Nixogen.
  networking.hostName = "nixogen";

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      # Use Systemd-boot. Grub really doesn't like LUKS.
      systemd-boot.enable = true;
      # Change the EFI mount point to "/boot/efi"
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    ## Mark /dev/nvme2 as luks.
    initrd.luks.devices = {
      root = {
       device = "/dev/disk/by-uuid/741fa890-193a-489c-960e-d6d308860f33";
       preLVM = true;
      };
    };
  };

  ####################
  ## Laptop Specific

  # Enable laptop touchpad.
  services.xserver.libinput.enable = true;

  # Enables wireless support via wpa_supplicant.
  networking.wireless.enable = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  #################
  ## Localisation

  # Locale
  time.timeZone = "Europe/Amsterdam";

  # Terminal keymap and font.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  ############
  ## Network

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # DHCP on the lan port, dunno if i'll ever use it.
  networking.interfaces.enp2s0.useDHCP = true;

  # Stops the network manager and DHCP from stalling boot for like 200 years.
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  ####################
  ## Graphical Stuff

  ## Enable X + SDDM + BSPWM.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:5";

    displayManager = {
      sddm.enable = true;
      defaultSession = "none+bspwm";
    };

    windowManager.bspwm = {
      enable = true;
    };
  };

  # Add nerdfonts to Hermit and Jetbrains
  fonts.fonts = with pkgs.unstable; [
    (nerdfonts.override { fonts = ["Hermit" "JetBrainsMono"]; })
  ];

  # configure alacritty
  programs.alacritty = {
    enable = true;
    brightBold = true;
    font = {
      normal.family = "JetBrainsMono NerdFont";
      size = "8.0";
    };
    theme = import ../../themes/ayu-mirage.nix;
  };

  ########################
  ## Old and hacky stuff

  # dependencies for sddm theme
  #environment.systemPackages = with pkgs.qt5; [
  #  qtbase
  #  qtquickcontrols
  #  qtgraphicaleffects
  #];

  #services.xserver.displayManager.sddm.theme = "${(pkgs.fetchFromGitHub {
  #  owner = "MarianArlt";
  #  repo = "sddm-chili";
  #  rev = "0.1.5";
  #  sha256 = "036fxsa7m8ymmp3p40z671z163y6fcsa9a641lrxdrw225ssq5f3";
  #})}";


  # Enable i3 + LightDM
  #services.xserver.windowManager.i3 = {
  #  enable = true;
  #  package = pkgs.i3-gaps;

  #  desktopManager = {
  #    xterm.enable = false;
  #  };

  #  displayManager = {
  #    defaultSession = "none+i3";
  #  };


  #};


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    initrd.luks.devices = [
      {
        name = "root";
        device = "/dev/sda3";
        preLVM = true;
      }
    ];
    loader = {
      grub.device = "/dev/sda";
      gummiboot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    # Define your hostname.
    # hostName = "nixos";

    # Enable wireless support via wpa_supplicant.
    wireless.enable = true;
  };

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [

    # Basic shell stuff
    byobu curl fish tmux tree wget which xclip

    # MTP support for mounting Android devices
    jmtpfs

    # Wireless networking
    wpa_supplicant_gui

    # Web browsers
    chromium firefox

    # IRC
    xchat

    # Virtualization
    vagrant

    # Editors
    idea."idea-ultimate" emacs gnome3.gedit sublime3 vim

    # Programming
    git gradle leiningen openjdk python ruby

    # Password management
    keepassx

    # GUI Launcher
    synapse

    # Dropbox GUI
    dropbox

    # Mouse hiding
    unclutter
  ];

  # List services that you want to enable:
  services = {
    # Enable the OpenSSH daemon.
    # openssh.enable = true;

    # Enable CUPS to print documents.
    # printing.enable = true;

    # The X11 windowing system.
    xserver = {
      enable = true;
      layout = "us";
      # xkbOptions = "eurosign:e";

      # Enable the KDE Desktop Environment.
      # displayManager.kdm.enable = true;
      desktopManager.kde4.enable = true;

      synaptics = {
        enable = true;
        tapButtons = false;
        twoFingerScroll = true;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.chris = {
    name = "chris";
    group = "users";
    extraGroups = [ "wheel" "disk" "audio" "video" "networkmanager" "systemd-journal" ];
    createHome = true;
    uid = 1000;
    home = "/home/chris";
    shell = "/run/current-system/sw/bin/fish";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

}

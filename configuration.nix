# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # The results of the hardware scan
    ./hardware-configuration.nix

    # Anything else not version-controlled
    ./secret.nix
  ];

  # Needed for Steam
  hardware.opengl.driSupport32Bit = true;

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
    hostName = "annemarie";
    networkmanager.enable = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  nixpkgs.config = {

    allowUnfree = true;

    chromium = {
      # Chromium's non-NSAPI alternative to Adobe Flash
      enablePepperFlash = true;

      enablePepperPDF = true;
    };

    packageOverrides = pkgs: rec {

      # Minecraft crashes on OpenJDK
      minecraft = pkgs.minecraft.override {
        jre = pkgs.oraclejre8;
      };

    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [

    steam

    baobab

    nmap nmap_graphical

    # Archive files
    zip unzip kde4.ark

    # Basic shell stuff
    curl fish gptfdisk htop tmux tree wget which xclip

    # Networking
    kde4.networkmanagement

    # Android devices
    android-udev-rules jmtpfs

    # Web browsers
    chromium firefox

    # IRC
    kde4.konversation

    # Virtualization
    vagrant

    # Editors
    idea."idea-ultimate" emacs gnome3.gedit sublime3 vim

    # Programming
    gitAndTools.gitFull gradle leiningen nodejs openjdk oraclejre8 ruby scala
    androidsdk_4_4 stdenv gcc gnumake chromedriver

    # Python
    python27Full python3 python34Packages.pip pypyPackages.virtualenv

    # Databases
    postgresql redis sqlite

    # Password management
    keepassx

    # Document/image viewers
    evince gnome3.eog

    # Video/audio
    gnome3.totem kde4.dragon vlc kde4.kmix

    # Dropbox GUI
    dropbox

    # Mouse hiding
    unclutter
  ];

  # List services that you want to enable:
  services = {

    nixosManual.showManual = true;

    # Enable the OpenSSH daemon.
    # openssh.enable = true;

    # Enable CUPS to print documents.
    # printing.enable = true;

    # The X11 windowing system.
    xserver = {
      enable = true;
      layout = "us";

      # KDE Desktop Environment.
      desktopManager.kde4.enable = true;

      # Touchpad
      synaptics = {
        enable = true;
        tapButtons = false;
        twoFingerScroll = true;
        minSpeed = "0.8";
        maxSpeed = "5.5";
        accelFactor = "0.015";
        palmDetect = true;

        # Left edge is adjusted because palm detection isn't good
        # enough on the edges. This touchpad is off-center and my
        # left palm tends to graze it.
        additionalOptions = ''
          Option "PalmMinWidth" "3"
          Option "AreaLeftEdge" "500"
          Option "VertScrollDelta" "65"
          Option "HorizScrollDelta" "65"
        '';
      };
    };
  };

  # VirtualBox
  virtualisation.virtualbox.host = {
    enable = true;
    enableHardening = false;
    addNetworkInterface = true;
  };

  # Fonts
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      inconsolata
      ubuntu_font_family
      vistafonts
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.chris = {
    name = "chris";
    group = "users";
    extraGroups = [
      "audio" "disk" "networkmanager" "plugdev"
      "systemd-journal" "wheel" "vboxusers" "video"
    ];
    createHome = true;
    uid = 1000;
    home = "/home/chris";
    shell = "/run/current-system/sw/bin/bash";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

}

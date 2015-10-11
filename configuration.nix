# This configuration is for my NixOS fork based on nixos-15.09.
# https://github.com/chris-martin/nixpkgs

{ config, pkgs, ... }:

{
  imports = [
    # The results of the hardware scan
    ./hardware-configuration.nix

    # Anything else not version-controlled
    ./secret.nix
  ];

  hardware = {
    # Needed for Steam
    opengl.driSupport32Bit = true;

    pulseaudio = {
      #enable = true;

      # Needed for Steam
      support32Bit = true;
    };

    bluetooth.enable = true;
  };

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

    firewall = {

      # Samba
      #allowedTCPPorts = [ 445 139 ];
      #allowedUDPPorts = [ 137 138 ];

      allowPing = true;
    };
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

      bluez = pkgs.bluez5;
    };
  };

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [

    baobab

    kde4.print_manager

    sshfsFuse

    truecrypt

    scrot

    #samba

    # Archive files
    zip unzip kde4.ark

    # Basic shell stuff
    curl fish gptfdisk htop tmux tree wget which xclip

    # Networking
    kde4.networkmanagement
    nmap nmap_graphical

    # Android devices
    android-udev-rules jmtpfs

    # Web browsers
    chromium firefox

    # IRC
    kde4.konversation

    # Virtualization and containers
    vagrant otto docker python27Packages.docker_compose

    # Editors
    idea."idea-ultimate" emacs gnome3.gedit sublime3 vim

    # Programming
    gitAndTools.gitFull nodejs androidsdk_4_4 chromedriver

    # C stuff and whatnot
    stdenv gcc gnumake automake autoconf

    # JVM
    openjdk7 openjdk8 oraclejre8 scala gradle leiningen

    # Ruby
    ruby bundler

    # Python
    python27Full python3 python34Packages.pip pypyPackages.virtualenv

    # Databases
    postgresql redis sqlite

    # Password management
    keepassx

    # Document/image viewers
    evince gnome3.eog

    # Image editing
    gimp inkscape

    # Video/audio
    gnome3.totem kde4.dragon vlc kde4.kmix

    # Gaming
    steam minecraft

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
    printing.enable = true;

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
        palmMinWidth = 3;
        scrollDelta = 65;

        # Left edge is adjusted because palm detection isn't good
        # enough on the edges. This touchpad is off-center and my
        # left palm tends to graze it.
        additionalOptions = ''
          Option "AreaLeftEdge" "500"
        '';
      };
    };

    #samba = {
    #  enable = true;
    #  shares = {
    #    chris = {
    #      path = "/home/chris/samba";
    #      "read only" = "yes";
    #      browseable = "yes";
    #      "guest ok" = "no";
    #      "valid users" = "chris";
    #      "follow symlinks" = "yes";
    #      "wide links" = "yes";
    #    };
    #  };
    #  extraConfig = ''
    #    unix extensions = no
    #    guest account = nobody
    #    map to guest = bad user
    #  '';
    #};

  };

  virtualisation = {

    # VirtualBox
    virtualbox.host = {
      enable = true;
      enableHardening = false;
      addNetworkInterface = true;
    };

    # Docker
    docker = {
      enable = true;
      storageDriver = "devicemapper";
    };
  };

  # Fonts
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      inconsolata
      ubuntu_font_family
      unifont
      vistafonts
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.chris = {
    name = "chris";
    group = "users";
    extraGroups = [
      "audio" "disk" "docker" "networkmanager" "plugdev"
      "systemd-journal" "wheel" "vboxusers" "video"
    ];
    createHome = true;
    uid = 1000;
    home = "/home/chris";
    shell = "/run/current-system/sw/bin/bash";
  };

  # Needed for otto :(
  # See https://github.com/NixOS/patchelf/issues/68
  system.activationScripts.globalLinker = ''
    mkdir -p /lib64
    ln -sf $(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker) /lib64/ld-linux-x86-64.so.2
  '';

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

}

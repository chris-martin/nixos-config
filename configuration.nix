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
    pulseaudio.support32Bit = true;
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
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    firewall.allowPing = true;
    #firewall.allowedTCPPorts = [ 8080 ];
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  #time.timeZone = "America/New_York";

  nixpkgs.config = {

    allowUnfree = true;

    chromium = {
      # Chromium's non-NSAPI alternative to Adobe Flash
      enablePepperFlash = true;

      enablePepperPDF = true;

      enableWideVine = true;
    };
  };

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [

    transmission_gtk

    openssl

    skype

    nix-repl

    # Disk usage analysis
    baobab ncdu

    gparted

    kde4.print_manager

    sshfsFuse

    truecrypt

    # Screenshots
    scrot gnome3.gnome-screenshot

    meld

    # Archive files
    zip unzip kde4.ark

    # Basic shell stuff
    curl fish gptfdisk htop jq lsof man_db psmisc tmux tree wget which xclip

    # Networking
    kde4.networkmanagement
    nmap nmap_graphical

    # Android devices
    android-udev-rules jmtpfs

    # Web browsers
    chromium # firefox

    # IRC
    kde4.konversation

    bridge-utils

    # Virtualization and containers
    docker python27Packages.docker_compose

    # AWS
    awscli packer

    # Editors
    idea."idea-ultimate" emacs vim # atom sublime3

    # Programming
    gitAndTools.gitFull nodejs # androidsdk_4_4 chromedriver

    # Haskell
    haskellPackages.cabal-install haskellPackages.ghc

    # C stuff and whatnot
    stdenv gcc gnumake automake autoconf

    # JVM
    openjdk8 scala sbt gradle ant leiningen maven # oraclejre8

    # Elixir/Erlang
    elixir rebar

    # Ruby
    ruby bundler

    # Python
    python27Full python3
    python34Packages.pip
    python34Packages.ipython
    pypyPackages.virtualenv

    # Databases and such
    postgresql rabbitmq_server redis sqlite

    # Password management
    keepassx2

    # Document/image viewers
    evince gnome3.eog

    # Image editing
    gimp inkscape imagemagick kde4.kcolorchooser

    # OCR
    tesseract

    # Video/audio
    gnome3.totem kde4.dragon vlc kde4.kmix ffmpeg

    # Gaming
    steam minecraft

    # Mouse hiding
    unclutter

    xorg.xkill
  ];

  services = {

    nixosManual.showManual = true;

    # Printing
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplipWithPlugin ];
    };

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
        minSpeed = "0.75";
        maxSpeed = "5.5";
        accelFactor = "0.015";
        palmDetect = true;
        palmMinWidth = 3;
        scrollDelta = 65;

        # Left edge is adjusted because palm detection isn't good
        # enough on the edges. This touchpad is off-center and my
        # left palm tends to graze it.
        additionalOptions = ''
          Option "AreaLeftEdge" "450"
        '';
      };
    };

    redshift = {
      enable = true;

      # San Mateo
      latitude = "37.56";
      longitude = "-122.33";
    };
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
      symbola
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

  system.activationScripts.dockerGc = ''
    echo ".*-data(_[0-9]+)?" > /etc/docker-gc-exclude-containers
    echo -e "alpine:.*\ncardforcoin/bitgo-express:.*\nclojure:.*\nmemcached:.*\nnginx:.*\npostgres:.*\npython:.*\nredis:.*\nspotify/docker-gc:.*\ntianon/true\nubuntu:.*" > /etc/docker-gc-exclude
  '';

  # Yubikey
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", TAG+="uaccess"
  '';

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

}

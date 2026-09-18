# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "focarix"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Display Manager: SDDM Wayland
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  
  # Tetapkan sesi default resmi NixOS ke Hyprland (UWSM)
  services.displayManager.defaultSession = "hyprland-uwsm";
  services.displayManager.sddm.settings = {
    General = {
      Session = "hyprland-uwsm.desktop";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable UPower for Battery status in Quickshell
  services.upower.enable = true;

  # Enable USB and External HDD mounting (Udisks2 & GVFS for Dolphin)
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  boot.supportedFilesystems = [ "ntfs" "exfat" "btrfs" ];

  # Enable sound with PipeWire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # RAM Optimize
  zramSwap.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.focarix = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    initialPassword = "908";
  };

  # Software Unfree
  nixpkgs.config.allowUnfree = true;

  # Environment Variable
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    # XDG_CURRENT_DESKTOP diatur otomatis oleh masing-masing sesi compositor
  };  

  # Flakes & Experimental Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Window Managers
  # 1. MangoWM (Desktop Utama Lama)
  # programs.mango.enable = false;

  # 2. Hyprland & Serpantinum Shell
  # programs.serpantinum.enable = true;
  programs.silentSDDM = {
    enable = true;
    theme = "rei";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # 3. Niri (Infinite Canvas Desktop)
  # programs.niri.enable = false;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    git
    tree
    kitty
    fastfetch
    brave
    waybar
    rofi
    pavucontrol
    grim
    slurp
    wl-clipboard
    neovim
    nodejs
    python3

   # inputs.silentSDDM.packages.${pkgs.system}.default
    quickshell
    matugen       # Generator warna Material You untuk Serpantinum
    qt6.qtwayland
    playerctl     # Kontrol media musik (MPRIS)
    brightnessctl # Kontrol slider kecerahan layar

    # Applications & File Manager
    kdePackages.dolphin  # File Manager KDE Dolphin

    # Icon & Font Themes (WhiteSur + Nerd Fonts)
    whitesur-gtk-theme
    whitesur-cursors
    papirus-icon-theme
    nerd-fonts.jetbrains-mono
    swaybg
    udiskie
    swappy
    wl-screenrec
    libnotify
  ];

  # System Fonts (Nerd Font untuk ikon simbolis Quickshell)
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Firewall configuration.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  # State version
  system.stateVersion = "26.05";
}

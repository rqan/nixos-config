# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, serpantinum, spicetify-nix, silentSDDM, ... }:

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
  services.resolved.enable = true;
  networking = {
    nameservers = ["1.1.1.1" "8.8.8.8" ];
    networkmanager.enable = true;
    };
  services.resolved.settings.Resolve = {
    DNS = "127.0.0.1:5300";
    Domains = [ "~test" ];
  };
  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  services.flatpak.enable = true;

  # Display Manager: SDDM Wayland
  services.xserver.enable = true;
  services.displayManager.sddm = {
	enable = true;
	wayland.enable = lib.mkForce true;
#	theme = "silent";
	};
#  services.displayManager.sddm.settings = {
#	Wayland = {
#	SessionDir = "usr/share/wayland-sessions";
#	};
 #  };  
  # Tetapkan sesi default resmi NixOS ke Hyprland (UWSM)
  services.displayManager.defaultSession = "hyprland-uwsm";
#  services.displayManager.sddm.settings = {
 #   General = {
  #    Session = "hyprland-uwsm.desktop";
  #  };
#  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable UPower for Battery status in Quickshell
  services.upower.enable = true;

  # Enable USB and External HDD mounting (Udisks2 & GVFS for Dolphin)
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  boot.supportedFilesystems = [ "ntfs" "exfat" "btrfs" ];
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Enable sound with PipeWire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.logind.settings.Login.HandlePowerKey = "ignore";

  # RAM Optimize
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.focarix = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" "kvm" ]; # Enable ‘sudo’ for the user.
    initialPassword = "908";
  };

  # Software Unfree
  nixpkgs.config.allowUnfree = true;

  # Environment Variable
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    VK_LAYER_PATH = "${pkgs.vkbasalt}/share/vulkan/explicit_layer.d";
    LIBVA_DRIVER_NAME = "iHD";
    # XDG_CURRENT_DESKTOP diatur otomatis oleh masing-masing sesi compositor
  };  
  


  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
  xdg.portal = {
	enable = true;
	wlr.enable = true;
	extraPortals = [
 	pkgs.xdg-desktop-portal-hyprland
	pkgs.xdg-desktop-portal-gtk
	];
	config.common.default = "*";
  };	
  # Flakes & Experimental Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Hyprland & Serpantinum Shell
  programs.serpantinum.enable = true;
  programs.silentSDDM = {
    enable = true;
    theme = "rei";
  };

  services.displayManager.sddm.theme = lib.mkForce "silent-patched";
  services.displayManager.sddm.settings.General.GreeterEnvironment = lib.mkForce "QML2_IMPORT_PATH=/run/current-system/sw/share/sddm/themes/silent-patched/components/,QT_IM_MODULE=qtvirtualkeyboard";


  systemd.tmpfiles.rules = [
    "d /var/lib/sddm-wallpaper 0755 focarix users"
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

    programs.spicetify =
    let
      spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
     enable = true;
     
     # 1. Paksa Spotify berjalan natif di Wayland (syarat wajib agar jendela bisa transparan di Hyprland)
     wayland = true;
     windowManagerPatch = true;

     enabledExtensions = with spicePkgs.extensions; [
       adblock
       hidePodcasts
       shuffle
    ];

    # 2. Sisipkan CSS untuk membuat background transparan (RGBA dengan alpha 0.5)
    theme = spicePkgs.themes.comfy // {
      additionalCss = ''
        .Root__main-view, 
        .Root__nav-bar, 
        .main-nowPlayingBar-container,
        .Root__top-container,
        .os-viewport {
            background-color: rgba(30, 30, 46, 0.4) !important;
            background-image: none !important;
        }
      '';
    };
    colorScheme = "catppuccin-mocha";
   };
  
  programs.nix-ld.enable = true;

   programs.nix-ld.libraries = with pkgs; [
    glib
    gtk3
    nss
    nspr
    dbus
    atk
    at-spi2-atk
    cups
    expat
    libdrm
    mesa
    libxkbcommon
    pango
    cairo
    alsa-lib
    libGL
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libgbm
];

  # List packages installed in system profile.
  virtualisation.podman.enable = true;
  # =========================================================================
  # System Packages Configuration
  # =========================================================================
  # =========================================================================
  # System Packages Configuration
  # =========================================================================
  environment.systemPackages = let
    patchedSilent = pkgs.stdenv.mkDerivation {
      name = "silent-patched";
      src = config.programs.silentSDDM.package';
      nativeBuildInputs = [ pkgs.perl ];
      installPhase = ''
        mkdir -p $out/share/sddm/themes/silent-patched
        cp -r $src/share/sddm/themes/silent/* $out/share/sddm/themes/silent-patched/
        
        chmod -R +w $out/share/sddm/themes/silent-patched
        
        perl -0777 -pi -e 's/property bool isVideo: \{.*?\}/property bool isVideo: {\n                var xhr = new XMLHttpRequest();\n                xhr.open("GET", "file:\/\/\/var\/lib\/sddm-wallpaper\/wallpaper_type", false);\n                try { xhr.send(); } catch(e) {}\n                if (xhr.status === 200 || xhr.status === 0) {\n                    return xhr.responseText.trim() === "video";\n                }\n                return false;\n            }/s' $out/share/sddm/themes/silent-patched/Main.qml

        perl -pi -e 's|source: !isVideo \? "backgrounds/" \+ tsource : ""|source: !isVideo ? "file:///var/lib/sddm-wallpaper/current_wallpaper" : ""|g' $out/share/sddm/themes/silent-patched/Main.qml
        perl -pi -e 's|backgroundVideo\.source = Qt\.resolvedUrl\("backgrounds/" \+ tsource\)|backgroundVideo.source = "file:///var/lib/sddm-wallpaper/current_wallpaper"|g' $out/share/sddm/themes/silent-patched/Main.qml
        
        sed -i 's/Name=silent/Name=silent-patched/' $out/share/sddm/themes/silent-patched/metadata.desktop
      '';
    };
  in [ patchedSilent ] ++ [

    # --- Custom Desktop Shortcuts (.desktop) ---
    (pkgs.makeDesktopItem {
      name = "github-desktop";
      desktopName = "GitHub Desktop";
      exec = "github-desktop %u";
      mimeTypes = [ "x-scheme-handler/x-github-client" ];
    })

    # --- Flake Input / Special Packages ---
    serpantinum.packages.${pkgs.stdenv.hostPlatform.system}.default

    # --- Pengolah Foto & Video (Creative Tools) ---
    pkgs.kdePackages.kdenlive              # Video Editor
    pkgs.gimp                  # Image Editor / Retouching

    # --- Web Browser ---
    pkgs.brave
    pkgs.microsoft-edge

    # --- Pemrograman & Developer Tools ---
    pkgs.proton-vpn
    pkgs.git
    pkgs.github-desktop
    pkgs.neovim
    pkgs.android-studio
    pkgs.dotnet-sdk_8
    pkgs.nodejs
    (pkgs.python3.withPackages(ps: with ps; [ evdev ]))
     (pkgs.dbeaver-bin.overrideAttrs (finalAttrs: previousAttrs: {
       version = "26.2.2";
       src = pkgs.fetchurl {
       url = "https://github.com/dbeaver/dbeaver/releases/download/26.2.2/dbeaver-ce-26.2.2-linux-x86_64.tar.gz";
       hash = "sha256-J7Oaeaaexw+flcbuO2hRT8x2d6zvkyh+jfjhPMUzhNU=";
   };
 }))
 
    # --- Media Player & Audio ---
    pkgs.mpv                   # Video Player
    pkgs.imv                   # Image Viewer
    pkgs.amberol               # Music Player GUI
    pkgs.cmus                  # Terminal Music Player
    pkgs.pavucontrol           # Volume Control GUI
    pkgs.playerctl             # Media Control CLI
    pkgs.pulseaudio            # Audio Utilities

    # --- Wayland, Desktop Shell, & Desktop Utilities ---
    pkgs.quickshell
    pkgs.matugen
    pkgs.qt6.qtwayland
    pkgs.brightnessctl
    pkgs.kdePackages.dolphin   # File Manager
    pkgs.kdePackages.ark       # Archive Manager (ZIP/TAR/7z)
    pkgs.unzip
    pkgs.udiskie               # Auto-mount USB / Drives
    pkgs.libnotify             # Desktop Notification Engine
    pkgs.polkit_gnome          # Authentication Agent
    pkgs.seahorse              # Keyring / Password Management GUI
    pkgs.grim                  # Wayland Screenshot
    pkgs.slurp                 # Wayland Region Selection
    pkgs.wl-clipboard          # Wayland Clipboard CLI
    pkgs.kitty                 # Terminal Emulator
    pkgs.appimage-run          # Runner untuk file .AppImage
    pkgs.vscode-fhs

    # --- Graphics, Gaming, & Driver Tools ---
    pkgs.vulkan-tools
    pkgs.mesa-demos
    pkgs.vkbasalt

    # --- Tema, Cursor, & Ikon ---
    pkgs.whitesur-gtk-theme
    pkgs.whitesur-cursors
    pkgs.papirus-icon-theme
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.font-awesome
    pkgs.material-symbols

    # --- CLI Utils & Terminal Rice (Visuals & TUI) ---
    pkgs.fastfetch
    pkgs.btop
    pkgs.tree
    pkgs.tty-clock
    pkgs.lavat
    pkgs.cava
    pkgs.cavalier
    pkgs.pipes
    pkgs.cmatrix
    pkgs.sptlrx

    # --- Video Recording (Serpantinum screenshot --record) ---
    # pkgs.gpu-screen-recorder  # Backend rekam utama (GPU-accelerated, Wayland)
    pkgs.wf-recorder          # Backend rekam fallback (region/area support)
    pkgs.ffmpeg               # Thumbnail video di notifikasi setelah rekam
    pkgs.inotify-tools        # inotifywait untuk recWatcher di Serpantinum
  ];
    programs.gpu-screen-recorder.enable = true;

  networking.networkmanager.dns = "systemd-resolved";
  systemd.user.tmpfiles.rules = [
    "L %h/.local/bin/lerd - - - - /run/current-system/sw/bin/lerd"
  ];
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_end_threshold}="80"
  '';

  systemd.services.asus-battery-charge-threshold = {
    description = "Set ASUS battery charge threshold to 80%";
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "multi-user.target" "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold'";
    };
  };

  system.stateVersion = "26.05";
}

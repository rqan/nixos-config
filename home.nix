{ config, pkgs, ... }:
{
 home.username = "focarix";
 home.homeDirectory = "/home/focarix";
 home.stateVersion = "24.05";

 programs.home-manager.enable = true;
 # wayland.windowManager.enable = true;
 
 home.packages = with pkgs;
 [
 foot
 quickshell
# wofi
 #dolphin
 ];
 home.sessionVariables =
 {
 MOZ_ENABLE_WAYLAND = "1";
 };
}

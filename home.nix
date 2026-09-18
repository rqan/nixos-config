{ config, pkgs, ... }:
{
 home.username = "focarix";
 home.homeDirectory = "/home/focarix";
 home.stateVersion = "24.05";

 programs.home-manager.enable = true;
 # wayland.windowManager.enable = true;
 
 wayland.windowsManager.hyprland = { enable = true; settings = { moitor = ",preferred,auto,auto"; general = { gaps_in = 5; gaps_out = 10; border_size = 2; };

 input = { kb_layout = "id";
	};
    };
 extraConfig = ''
 exec-once = quickshell
 $mainMod = SUPER
 bind = $mainMod, Return, exec, foot
 bind = $mainMod, Q, killactive, '';
 };

 home.packages = with pkgs;
 [
 foot
 quickshell
 ];
}

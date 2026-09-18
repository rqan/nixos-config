{
  description = "NixOS configuration with Hyprland and Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = { url = "github:nix-community/home-manager/master"; inputs.nixpkgs.follows = "nixpkgs"; };
    serpantinum = { url = "github:ilyamiro/serpantinum"; inputs.nixpkgs.follows = "nixpkgs"; };
    silentSDDM = { url = "github:uiriansan/SilentSDDM"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, home-manager, serpantinum, silentSDDM }@inputs:
   let
      system = "x86_64-linux";
   in
   {
    nixosConfigurations.focarix = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
	inherit serpantinum silentSDDM;
    };
      modules = [
	silentSDDM.nixosModules.default
	./configuration.nix

	home-manager.nixosModules.home-manager
	{
	  home-manager.useGlobalPkgs = true;
	  home-manager.useUserPackages = true;
	  home-manager.users.focarix = import ./home.nix;
	}
      ];
    }; 
  };
}

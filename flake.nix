{
  description = "NixOS configuration with MangoWM and Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    serpantinum = { url = "github:ilyamiro/serpantinum"; };
    silentSDDM = { url = "github:uiriansan/SilentSDDM"; inputs.nixpkgs.follows = "nixpkgs"; };
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, mangowm, ... }@inputs: {
    nixosConfigurations.focarix = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        mangowm.nixosModules.mango
        inputs.silentSDDM.nixosModules.default
        inputs.serpantinum.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}

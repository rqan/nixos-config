{
  description = "NixOS configuration with Hyprland and Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = { url = "github:nix-community/home-manager/master"; inputs.nixpkgs.follows = "nixpkgs"; };
    serpantinum = { url = "path:/home/focarix/.config/serpantinum"; inputs.nixpkgs.follows = "nixpkgs"; };
    silentSDDM = { url = "github:uiriansan/SilentSDDM"; inputs.nixpkgs.follows = "nixpkgs"; };
    spicetify-nix = { url = "github:Gerg-L/spicetify-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    lerd = { url = "github:lerd-env/lerd-nixos"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, home-manager, serpantinum, silentSDDM, spicetify-nix, lerd }@inputs:
   let
      system = "x86_64-linux";
   in
   {
    nixosConfigurations.focarix = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit serpantinum silentSDDM lerd spicetify-nix;
      };
      modules = [
        serpantinum.nixosModules.default
        silentSDDM.nixosModules.default
        spicetify-nix.nixosModules.default
        { environment.systemPackages = [ lerd.packages.x86_64-linux.default ]; }
        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit spicetify-nix; };
          home-manager.users.focarix = import ./home.nix;
        }
      ];
    }; 
  };
}

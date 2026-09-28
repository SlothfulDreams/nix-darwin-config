{
  description = "slothful nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    home-manager,
  }: let
    username = "slothy";
    system = "aarch64-darwin";

    # One nix-darwin config per host: the shared modules/darwin.nix plus
    # hosts/<host>.nix. `host` also reaches home.nix so `drs`/`nup` rebuild
    # the config they were built from.
    mkDarwin = host:
      nix-darwin.lib.darwinSystem {
        specialArgs = {inherit self username host;};
        modules = [
          ./modules/darwin.nix
          ./hosts/${host}.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = username;
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit host;};
              users.${username} = import ./home.nix;
            };
          }
        ];
      };
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    # Build with: darwin-rebuild build --flake .#<host>
    darwinConfigurations = nixpkgs.lib.genAttrs ["slothbook" "slouch" "work"] mkDarwin;
  };
}

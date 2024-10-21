{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Jaspers-MacBook-Pro
    darwinConfigurations."Jaspers-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin.nix ];
      specialArgs = inputs;
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Jaspers-MacBook-Pro".pkgs;
  };
}

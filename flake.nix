{
  description = "Mayhem NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations.mayhem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/mayhem/configuration.nix
      ];
    };
  };
}

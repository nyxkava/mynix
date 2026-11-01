{
  description = "NixOS Desktop — Stable (26.05) + Unstable + Flakes Externos + Home Manager";

  inputs = {
    # 1º CANAL: STABLE (NixOS 26.05 "Yarara" — base sólida, drivers Nvidia, Kernel, etc.)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # 2º CANAL: UNSTABLE (Para pacotes sempre na última versão)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (acompanhando a release 26.05 do canal principal)
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 3º CANAL: FLAKES DE TERCEIROS (Descomente os que quiser usar)
    # Repositório comunitário Source Engine (traz pacotes nativos como maretf e sourcepp):
    # srcds-nix.url = "git+https://git.partyvan.io/srcds-nix";

    # Exemplo: Zen Browser
    # zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";

    # Instancia o canal Unstable já aceitando pacotes proprietários (Discord, Steam, ProtonVPN, etc.)
    unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    # IMPORTANTE: Se mudar o hostname no Painel de Controle, mude o ".nixos" abaixo também
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      # Passa 'inputs' (Flakes externos) e 'unstable' (Canal Unstable) para dentro do configuration.nix
      specialArgs = { inherit inputs unstable; };
      modules = [
        # No NixOS 25.11/26.05+, 'system' direto em nixosSystem é depreciado; usa-se hostPlatform:
        { nixpkgs.hostPlatform = system; }
        ./configuration.nix
        home-manager.nixosModules.home-manager
      ];
    };
  };
}

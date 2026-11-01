Estou usando o NixOS 26.05 ("Yarara") e anexei meu `configuration.nix` completo nesta conversa. Antes de responder ou sugerir alterações, leia atentamente como a arquitetura do meu arquivo funciona e siga as regras abaixo:

### 1. Arquitetura do Sistema
- **Versão base:** NixOS 26.05 (`nixos-26.05`) com Flakes habilitados e Home Manager (`release-26.05`) embutido como módulo do NixOS (`moduloHomeManager` carregado via `imports`).
- **3 Canais de Pacotes (via `flake.nix` e `specialArgs`):**
  1. `pkgs`: canal estável (`nixos-26.05`).
  2. `pkgsUnstable`: canal `nixos-unstable` passado via `specialArgs = { inherit inputs unstable; }` (com fallback via `builtins.fetchTarball` caso avaliado sem o `unstable`).
  3. `inputs`: Flakes de terceiros (como `home-manager` e opcionalmente `srcds-nix`). A função auxiliar `tentar` (`tentarPacote`) usa `builtins.tryEval` para buscar pacotes primeiro no `srcds-nix`, depois no `pkgs` e por fim no `pkgsUnstable`, ignorando silenciosamente caso não existam.
- **Painel de Controle (`cfg = { ... }`):**
  Toda a parametrização do sistema fica centralizada no bloco `let cfg = { ... };` no topo do arquivo (identidade, kernel, Nvidia, 2º SSD, ambientes gráficos Plasma 6/Hyprland/i3, módulos, segurança, Multi-SRCDS e Estúdio Source Engine).

### 2. Ferramentas e Geradores Embutidos no `configuration.nix`
1. **`source-tools` (alias `st`):**
   Gerenciador declarativo (`pkgs.writeShellScriptBin "source-tools"`) para criação de conteúdo na Source Engine 1 e 2:
   - Gerencia um prefixo Wine 64-bit dedicado (`~/.local/share/source-modding/wine`) preparado com `.NET 4.8`, `vcrun2022`, `d3dx9`, `d3dcompiler_47` e `corefonts` para rodar ferramentas Windows (Crowbar, CompilePal, Hammer/Hammer++, HLMV, Source 2 Viewer GUI).
   - Baixa e atualiza releases oficiais do GitHub em `~/SourceTools` (Crowbar, CompilePal, BSPSource, Lumper, MareTF, Source2Viewer GUI/CLI, `fastgmad`, `glualint`) e executa binários Linux pré-compilados usando `steam-run` / `appimage-run` + `programs.nix-ld` + `GLIBC_TUNABLES=glibc.rtld.execstack=2` (necessário no Glibc 2.42+ para binários legados da Source 1).
   - O Blender é utilizado via Steam (não via `nixpkgs`).
2. **Gerador Multi-SRCDS (`cfg.srcds.servidores`):**
   Para cada servidor declarado em `cfg.srcds.servidores` (ex: `gmod`, `cs2`), o arquivo gera automaticamente:
   - Diretórios via `systemd.tmpfiles.rules`.
   - Abertura dinâmica de portas TCP/UDP no firewall apenas para servidores com `enable = true`.
   - 7 aliases automáticos (`srcds-<nome>-update`, `start`, `stop`, `restart`, `status`, `logs`, `dir`).
   - Serviços `systemd.services.srcds-<nome>` com sandboxing contra RCE (`ProtectHome = "tmpfs"`, `BindPaths`, `NoNewPrivileges`, bloqueio do `docker.sock`) e `GLIBC_TUNABLES=glibc.rtld.execstack=2`.
3. **`nixos-painel` (aliases `painel`, `configurar`, `ntui`):**
   Utilitário TUI (`fzf` + script Python `cfg_tool.py` embutido) que lê e edita o bloco `cfg = { ... }` do `/etc/nixos/configuration.nix` in-place preservando indentação e comentários. Por isso, **mantenha o formato das linhas `chave = valor;` dentro de `cfg = { ... }` limpo e consistente**.
4. **`nixos-guia` (aliases `guia`, `ajuda`, `manual`):**
   Manual interativo em terminal construído com `fzf` e `less -R`.

### 3. Detalhes Técnicos Importantes (NÃO confunda como bugs)
- **Fish Shell & Aliases:** O login shell do usuário é `pkgs.bashInteractive` que faz `exec fish` apenas em sessões interativas (`programs.bash.interactiveShellInit`), seguindo o padrão oficial da NixOS Wiki para não quebrar scripts POSIX de sessão (Wayland/SDDM). Como `programs.fish.enable = true;` está ativo no nível do NixOS, o módulo oficial `nixos/modules/programs/fish.nix` **já importa todos os `environment.shellAliases` automaticamente para o Fish**.
- **I2P no Unstable:** O módulo `services.i2p` não possui opção `.package`, portanto puxa do canal `unstable` através de `nixpkgs.overlays = [ (final: prev: { i2p = pkgsUnstable.i2p; }) ];`.
- **Sintaxe NixOS 26.05:** Display Managers ficam em `services.displayManager.*` (e não em `services.xserver.displayManager.*`), `services.resolved` usa `settings.Resolve`, e o Git no Home Manager usa `programs.git.settings`.
- **Escaping em Strings Multiline (`'' ... ''`):** Dentro dos scripts `writeShellScriptBin`, variáveis do Nix usam `${var}`, enquanto variáveis do Bash/Python precisam obrigatoriamente ser escapadas com duas aspas simples antes do cifrão: `''${VAR}`. Nunca coloque duas aspas simples seguidas (`''`) soltas dentro de textos ou scripts embutidos para não fechar nem escapar a string do Nix por engano.

---

### Meu Problema / O que preciso fazer agora:
[DESCREVA AQUI O QUE VOCÊ QUER FAZER OU COLE O ERRO QUE APARECEU NO TERMINAL]

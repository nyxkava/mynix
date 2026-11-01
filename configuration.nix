# ============================================================================
#  configuration.nix — Nvidia | Gaming + Dev | Flakes & HM | Multi-SRCDS
#                      + ESTÚDIO DE CRIAÇÃO SOURCE ENGINE (Source 1 & Source 2)
# ============================================================================
#  COMO APLICAR ALTERAÇÕES:
#    - 1ª vez após instalar: sudo nixos-rebuild switch --flake /etc/nixos#nixos --extra-experimental-features "nix-command flakes"
#    - Todas as próximas vezes: digite apenas 'nrs' no terminal
#    - Para abrir o Painel de Configuração TUI: digite 'painel' (ou 'configurar' / 'ntui')
#    - Para abrir o Guia Interativo completo no terminal: digite 'guia' (ou 'ajuda')
#
#  PRIMEIRO USO DO ESTÚDIO SOURCE (depois do 1º rebuild):
#    1) source-tools setup     -> cria o prefixo Wine dedicado (.NET 4.8, VC++, d3dx9...)
#    2) source-tools baixar    -> baixa/atualiza Crowbar, CompilePal, BSPSource, Lumper,
#                                 MareTF, Source2Viewer, fastgmad, glualint
#    3) source-tools hammerpp  -> escolhe e baixa a build do Hammer++ do seu jogo
#    4) source-tools ajuda     -> lista todos os comandos
# ============================================================================

{ config, pkgs, lib, options, inputs ? {}, unstable ? null, ... }:

let
  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                      PAINEL DE CONTROLE RÁPIDO                         ║
  # ║         Altere todo o comportamento e segurança do sistema aqui        ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  cfg = {
    # --- 1. Identidade, Shell e Regionalização ---
    usuario        = "nap";
    gitUser        = "nap";                 # Nome nos commits do Git (Home Manager)
    gitEmail       = "seu-email@exemplo.com";
    hostname       = "nixos";               # Se mudar, mude também "nixosConfigurations.nixos" no flake.nix
    shellPadrao    = "fish";                # "fish" (via wrapper POSIX seguro), "zsh" ou "bash"
    timezone       = "America/Sao_Paulo";
    locale         = "en_US.UTF-8";
    localeExtraPt  = false;                 # true = datas, moeda e medidas em pt_BR
    tecladoConsole = "br-abnt2";            # "br-abnt2" ou "us"
    tecladoGrafico = "br";                  # "br" ou "us"
    stateVersion   = "26.05";               # Mantenha IGUAL ao que o instalador original gerou!

    # --- 2. Home Manager (Gerencia configs da sua $HOME declarativamente) ---
    usarHomeManager = true;                 # Requer o input "home-manager" no flake.nix

    # --- 3. Hardware, Kernel, Energia e Performance ---
    kernel      = "stable";                 # "stable" (seguro p/ VMware/Nvidia), "zen" (jogos) ou "latest"
    nvidiaOpen  = false;                    # true recomendado para RTX série 20 ou superior
    cpuGovernor = "schedutil";              # "performance" ou "schedutil"
    ssdTrim     = true;
    zramEnable  = true;
    zramPercent = 50;
    bluetooth   = true;

    # --- 4. Segundo SSD / NVMe Opcional (para Jogos e Servidores) ---
    discoSecundario = {
      enable        = false;                # true = monta automaticamente no boot
      uuid          = "COLE-O-UUID-AQUI";   # Descubra rodando no terminal: lsblk -f
      pontoMontagem = "/mnt/ssd";
      fsType        = "ext4";               # "ext4", "btrfs" ou "ntfs3"
    };

    # --- 5. Ambientes Gráficos e Login ---
    desktop = {
      plasma    = true;                     # KDE Plasma 6 (Wayland)
      hyprland  = true;                     # Hyprland (Wayland) + ecossistema completo
      i3        = false;                    # i3wm (X11)
      autoLogin = false;
    };

    # --- 6. Módulos e Recursos do Sistema ---
    modulos = {
      gaming     = true;                    # Steam (+Proton-GE), Gamemode, Lutris, Heroic, MangoHud
      dev        = true;                    # VSCode, Neovim, linguagens, compiladores, Git TUI
      docker     = true;                    # Containers Docker
      vmware     = true;                    # VMware Workstation Pro + módulos
      flatpak    = true;                    # Flatpak + Flathub + XDG Portals
      appimage   = true;                    # Executa .AppImage direto com 2 cliques
      i2p        = true;                    # Roteador I2P
      ssh        = false;                   # Servidor OpenSSH blindado
      impressora = false;                   # CUPS
      earlyOom   = true;                    # Proteção contra congelamento por falta de RAM
    };

    # --- 7. Segurança e Privacidade de Rede ---
    seguranca = {
      dockerRootless   = false;
      dockerLocalOnly  = true;              # Impede que o Docker exponha portas na LAN sem aviso
      dnsCriptografado = false;             # DNS-over-TLS via Quad9/Cloudflare
      sudoPedeSenha    = true;
    };

    # --- 8. MULTI-SRCDS (Garry's Mod, CS2, TF2, etc. simultâneos ou individuais) ---
    srcds = {
      # ONDE OS SERVIDORES FICAM SALVOS POR PADRÃO:
      # "home"   -> Salva em /home/<usuario>/srcds/<nome-do-servidor>
      # "custom" -> Salva no segundo SSD/caminho definido em caminhoCustom
      localArmazenamento = "home";          # "home" ou "custom"
      caminhoCustom      = "/mnt/ssd/srcds";

      # LISTA DE SERVIDORES: Adicione quantos quiser!
      # Para cada um, o NixOS cria automaticamente os aliases:
      #   srcds-<nome>-update | srcds-<nome>-start | srcds-<nome>-stop | srcds-<nome>-logs | srcds-<nome>-dir
      servidores = {
        gmod = {
          enable    = false;                # Mude para true após rodar 'srcds-gmod-update'
          autoStart = false;                # true = inicia junto com o boot do PC
          appId     = 4020;                 # AppID do Garry's Mod Dedicated Server
          execBin   = "srcds_run";
          execArgs  = "-game garrysmod -console -port 27015 +maxplayers 16 +gamemode sandbox +map gm_construct";
          portasUDP = [ 27015 ];
          portasTCP = [ 27015 ];
          # customDir = "/mnt/ssd/meus_servidores/gmod"; # Opcional: força pasta individual
        };

        cs2 = {
          enable    = false;
          autoStart = false;
          appId     = 730;
          execBin   = "game/bin/linuxsteamrt64/cs2";
          execArgs  = "-dedicated -port 27016 +map de_dust2 +game_type 0 +game_mode 1 -maxplayers 10";
          portasUDP = [ 27016 27020 ];
          portasTCP = [ 27016 ];
        };
      };
    };

    # --- 9. ESTÚDIO DE CRIAÇÃO SOURCE ENGINE (Modelos, Texturas, Mapas, Addons) ---
    #  Nativos no Linux : VPKEdit, MareTF, BSPSource, Lumper, F3D,
    #                     GIMP, Krita, Inkscape, Audacity, Source2Viewer-CLI, fastgmad, glualint
    #  Via Wine dedicado: Crowbar, CompilePal, Hammer/Hammer++, HLMV, Source2Viewer (GUI)
    #  Via nixpkgs+Wine : VTFEdit (o nixpkgs já empacota com prefixo próprio)
    criacaoSource = {
      enable      = true;
      modelagem   = true;                   # F3D (visualizador 3D rápido; Blender instalado via Steam)
      texturas    = true;                   # GIMP, Krita, Inkscape, VTFEdit, MareTF, Upscayl
      audio       = true;                   # Audacity + SoX (Source exige WAV PCM 16-bit 44.1kHz)
      mapeamento  = true;                   # Hammer++ (Wine), CompilePal, BSPSource (Java), Lumper
      garrysmod   = true;                   # GLua: lua-language-server, StyLua, LuaJIT, glualint, fastgmad
      source2     = true;                   # Source2Viewer (CS2, Dota 2, Deadlock, HL:Alyx)
      atalhosMenu = true;                   # Cria atalhos no menu de apps (Plasma/Hyprland/wofi)

      # Wine do prefixo de modding:
      #   "wow64"    -> wineWow64Packages (novo WoW64, 64-bit puro, mesmo usado no módulo gaming)
      #   "classico" -> wineWowPackages (32+64 clássico; use se o dotnet48 falhar no "wow64")
      wineVariante = "wow64";

      # Pastas (relativas à sua $HOME)
      pastaFerramentas = "SourceTools";                     # Ferramentas baixadas do GitHub
      pastaProjetos    = "SourceProjects";                  # Seus projetos (modelos, mapas, addons...)
      prefixoWine      = ".local/share/source-modding/wine"; # Prefixo Wine exclusivo do modding
    };

    # --- 10. Manutenção Automática do NixOS ---
    manutencao = {
      gcAutomatico = true;
      gcManterDias = "14d";
    };
  };

  # ──────────────────────────────────────────────────────────────────────────
  # Lógica Interna (Não precisa editar)
  # ──────────────────────────────────────────────────────────────────────────
  cs      = cfg.criacaoSource;
  homeDir = "/home/${cfg.usuario}";

  # 2º canal (unstable) — usa o input do flake.nix ou fallback híbrido via tarball
  pkgsUnstable =
    if unstable != null then unstable
    else import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    }) { config = config.nixpkgs.config; };

  kernelMap = {
    stable = pkgs.linuxPackages;
    zen    = pkgs.linuxPackages_zen;
    latest = pkgs.linuxPackages_latest;
  };

  # Instala um pacote se existir no flake srcds-nix (se ativado), no stable ou no
  # unstable; senão ignora silenciosamente. Assim a config nunca quebra se um pacote
  # mudar de nome, e aproveita automaticamente pacotes nativos que entrarem no nixpkgs.
  pkgsSrcdsNix =
    if (inputs ? srcds-nix && inputs.srcds-nix ? packages)
    then (inputs.srcds-nix.packages.${pkgs.stdenv.hostPlatform.system} or {})
    else {};

  tentarPacote = nome:
    let
      achar = conjunto:
        let r = builtins.tryEval (conjunto.${nome} or null);
        in if r.success then r.value else null;
      doFlake  = achar pkgsSrcdsNix;
      estavel  = achar pkgs;
      instavel = achar pkgsUnstable;
    in
      if doFlake != null then [ doFlake ]
      else if estavel != null then [ estavel ]
      else if instavel != null then [ instavel ]
      else [ ];
  tentar = nomes: lib.concatMap tentarPacote nomes;

  # ── SRCDS ────────────────────────────────────────────────────────────────
  srcdsBaseDir =
    if cfg.srcds.localArmazenamento == "home"
    then "${homeDir}/srcds"
    else cfg.srcds.caminhoCustom;

  dirDoServidor = nome: srv:
    if (srv ? customDir && srv.customDir != null)
    then srv.customDir
    else "${srcdsBaseDir}/${nome}";

  servidoresAtivos = lib.filterAttrs (_: srv: srv.enable) cfg.srcds.servidores;

  aliasesSrcds = lib.foldl' (acc: nome:
    let
      srv = cfg.srcds.servidores.${nome};
      dir = dirDoServidor nome srv;
    in acc // {
      "srcds-${nome}-dir"     = "cd '${dir}'";
      "srcds-${nome}-update"  = "HOME='${srcdsBaseDir}' steamcmd +force_install_dir '${dir}' +login anonymous +app_update ${toString srv.appId} validate +quit";
      "srcds-${nome}-start"   = "sudo systemctl start srcds-${nome}";
      "srcds-${nome}-stop"    = "sudo systemctl stop srcds-${nome}";
      "srcds-${nome}-restart" = "sudo systemctl restart srcds-${nome}";
      "srcds-${nome}-status"  = "systemctl status srcds-${nome}";
      "srcds-${nome}-logs"    = "journalctl -u srcds-${nome} -f";
    }
  ) {} (lib.attrNames cfg.srcds.servidores);

  # ── ESTÚDIO SOURCE ───────────────────────────────────────────────────────
  ferramentasDir = "${homeDir}/${cs.pastaFerramentas}";
  projetosDir    = "${homeDir}/${cs.pastaProjetos}";
  prefixoWine    = "${homeDir}/${cs.prefixoWine}";

  wineModding =
    if cs.wineVariante == "classico"
    then pkgs.wineWowPackages.stable
    else pkgs.wineWow64Packages.stable;

  binPathSourceTools = lib.makeBinPath ((with pkgs; [
    coreutils findutils gnused gnugrep gawk which
    curl jq fzf unzip p7zip gnutar gzip xz cabextract
    winetricks steam-run appimage-run xdg-utils
  ]) ++ [ wineModding ] ++ lib.optional cs.mapeamento pkgs.jre);

  # ────────────────────────────────────────────────────────────────────────
  # source-tools: gerenciador do estúdio Source (prefixo Wine, downloads
  # das releases oficiais no GitHub e lançadores de cada ferramenta).
  # ────────────────────────────────────────────────────────────────────────
  sourceTools = pkgs.writeShellScriptBin "source-tools" ''
    set -euo pipefail
    export PATH="${binPathSourceTools}:$PATH"

    FERRAMENTAS="''${SOURCE_TOOLS_DIR:-${ferramentasDir}}"
    PROJETOS="${projetosDir}"
    export WINEPREFIX="''${SOURCE_WINEPREFIX:-${prefixoWine}}"
    export WINEARCH=win64
    export WINEDEBUG="''${WINEDEBUG:--all}"
    export WINE="${wineModding}/bin/wine"
    export WINESERVER="${wineModding}/bin/wineserver"
    export WINEDLLOVERRIDES="''${WINEDLLOVERRIDES:-winemenubuilder.exe=d}"
    STEAM_ROOT="''${STEAM_ROOT:-$HOME/.local/share/Steam}"

    cor()   { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
    aviso() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
    erro()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

    # ---------- GitHub ----------
    api() {
      local url="https://api.github.com/repos/$1/releases/latest"
      if [ -n "''${GITHUB_TOKEN:-}" ]; then
        curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" "$url"
      else
        curl -fsSL "$url"
      fi
    }

    extrair() {
      local arq="$1" dst="$2"
      mkdir -p "$dst"
      case "$arq" in
        *.zip|*.ZIP)    unzip -oq "$arq" -d "$dst" ;;
        *.7z)           7z x -y -o"$dst" "$arq" >/dev/null ;;
        *.tar.gz|*.tgz) tar -xzf "$arq" -C "$dst" ;;
        *.tar.xz)       tar -xJf "$arq" -C "$dst" ;;
        *.AppImage|*.appimage) cp -f "$arq" "$dst/"; chmod +x "$dst/$(basename "$arq")" ;;
        *)              cp -f "$arq" "$dst/" ;;
      esac
    }

    # baixar <nome> <dono/repo> <extrair|copiar> <regex1> [regex2...]
    baixar() {
      local nome="$1" repo="$2" modo="$3"
      shift 3
      local dst="$FERRAMENTAS/$nome" json tag url="" re arq tmp
      cor "$nome  <-  github.com/$repo"
      if ! json="$(api "$repo")"; then
        aviso "Falha ao consultar a API do GitHub ($repo). Sem internet ou limite de requisições? (defina GITHUB_TOKEN)"
        return 0
      fi
      tag="$(jq -r '.tag_name // "desconhecida"' <<<"$json")"
      if [ -f "$dst/.versao" ] && [ "$(cat "$dst/.versao")" = "$tag" ]; then
        echo "    já está na versão mais recente ($tag)"
        return 0
      fi
      for re in "$@"; do
        url="$(jq -r --arg re "$re" '[.assets[] | select(.name | test($re; "i"))][0].browser_download_url // empty' <<<"$json")"
        if [ -n "$url" ]; then break; fi
      done
      if [ -z "$url" ]; then
        aviso "Nenhum arquivo compatível na release $tag. Baixe manualmente: https://github.com/$repo/releases"
        return 0
      fi
      tmp="$(mktemp -d)"
      arq="$tmp/$(basename "$url")"
      curl -fL --progress-bar -o "$arq" "$url"
      rm -rf "$dst"
      mkdir -p "$dst"
      if [ "$modo" = "extrair" ]; then extrair "$arq" "$dst"; else cp -f "$arq" "$dst/"; fi
      rm -rf "$tmp"
      chmod -R u+rwX "$dst"
      printf '%s\n' "$tag" > "$dst/.versao"
      echo "    OK: $tag -> $dst"
    }

    baixar_um() {
      case "$1" in
        crowbar)          baixar crowbar          ZeqMacaw/Crowbar                         extrair 'crowbar.*\.(zip|7z)$' '\.exe$' '\.(zip|7z)$' ;;
        compilepal)       baixar compilepal       ruarai/CompilePal                        extrair '\.zip$' ;;
        bspsrc)           baixar bspsrc           ata4/bspsrc                              extrair 'linux.*\.zip$' '\.jar$' '\.zip$' ;;
        lumper)           baixar lumper           momentum-mod/lumper                      extrair 'linux.*\.(zip|tar\.gz|appimage)$' ;;
        maretf)           baixar maretf           craftablescience/MareTF                  extrair 'linux.*standalone.*\.(zip|tar\.gz|7z)$' 'linux.*\.(zip|tar\.gz|7z)$' '\.appimage$' ;;
        s2v)              baixar s2v              ValveResourceFormat/ValveResourceFormat  extrair '^source2viewer\.exe$' '^source2viewer.*win.*\.(zip|exe)$' ;;
        s2v-cli)          baixar s2v-cli          ValveResourceFormat/ValveResourceFormat  extrair 'cli-linux-x64\.zip$' 'cli.*linux.*\.zip$' ;;
        fastgmad)         baixar fastgmad         WilliamVenner/fastgmad                   extrair 'linux' ;;
        glualint)         baixar glualint         FPtje/GLuaFixer                          extrair 'linux.*\.zip$' 'linux' ;;
        *) aviso "Ferramenta desconhecida: $1" ;;
      esac
    }

    TODAS="crowbar compilepal bspsrc lumper maretf s2v s2v-cli fastgmad glualint"

    # ---------- Localizar e executar ----------
    achar() {
      local dir="$FERRAMENTAS/$1" p r
      shift
      [ -d "$dir" ] || return 0
      for p in "$@"; do
        r="$(find "$dir" -type f -iname "$p" -print -quit 2>/dev/null || true)"
        if [ -n "$r" ]; then printf '%s\n' "$r"; return 0; fi
      done
    }

    exigir() {
      [ -n "$2" ] || erro "$1 não encontrado. Rode: source-tools baixar $1"
    }

    rodar_exe() {
      local exe="$1"
      shift
      if [ ! -f "$WINEPREFIX/.source-tools-ok" ]; then
        aviso "Prefixo Wine ainda não preparado (rode: source-tools setup). Tentando mesmo assim..."
      fi
      cd "$(dirname "$exe")"
      exec "$WINE" "$exe" "$@"
    }

    rodar_nativo() {
      local bin="$1"
      shift
      chmod +x "$bin" 2>/dev/null || true
      cd "$(dirname "$bin")"
      export GLIBC_TUNABLES="''${GLIBC_TUNABLES:-glibc.rtld.execstack=2}"
      case "$bin" in
        *.AppImage|*.appimage) exec appimage-run "$bin" "$@" ;;
        *)                     exec steam-run "$bin" "$@" ;;
      esac
    }

    bibliotecas_steam() {
      local vdf="$STEAM_ROOT/steamapps/libraryfolders.vdf"
      printf '%s\n' "$STEAM_ROOT"
      if [ -f "$vdf" ]; then
        sed -nE 's/.*"path"[[:space:]]+"([^"]+)".*/\1/p' "$vdf"
      fi
    }

    # ---------- Comandos ----------
    cmd_setup() {
      mkdir -p "$WINEPREFIX" "$FERRAMENTAS"
      cor "Inicializando prefixo Wine em $WINEPREFIX"
      "$WINE" wineboot -u
      "$WINESERVER" -w
      cor "Instalando dependências (o dotnet48 leva 10-20 min, é normal parecer travado)"
      winetricks -q --force corefonts vcrun2022 d3dx9 d3dcompiler_47 dotnet48
      winetricks -q win10
      "$WINESERVER" -w
      touch "$WINEPREFIX/.source-tools-ok"
      cor "Prefixo pronto! Próximo passo: source-tools baixar"
    }

    cmd_baixar() {
      mkdir -p "$FERRAMENTAS"
      if [ $# -eq 0 ] || [ "$1" = "tudo" ]; then
        for t in $TODAS; do baixar_um "$t"; done
      else
        for t in "$@"; do baixar_um "$t"; done
      fi
      cor "Concluído. Veja o estado com: source-tools status"
    }

    cmd_status() {
      cor "Ferramentas em $FERRAMENTAS"
      for t in $TODAS; do
        if [ -f "$FERRAMENTAS/$t/.versao" ]; then
          printf '  %-18s %s\n' "$t" "$(cat "$FERRAMENTAS/$t/.versao")"
        else
          printf '  %-18s %s\n' "$t" "(não baixado)"
        fi
      done
      if [ -d "$FERRAMENTAS/hammerpp" ]; then
        printf '  %-18s %s\n' "hammerpp" "$(ls "$FERRAMENTAS/hammerpp" | tr '\n' ' ')"
      fi
      cor "Prefixo Wine: $WINEPREFIX"
      if [ -f "$WINEPREFIX/.source-tools-ok" ]; then echo "  preparado"; else echo "  NÃO preparado (source-tools setup)"; fi
      cor "Wine: $("$WINE" --version 2>/dev/null || echo '?')"
    }

    cmd_hammerpp() {
      local json escolha url dst tmp
      json="$(api ficool2/HammerPlusPlus-Website)" || erro "Falha ao consultar releases do Hammer++"
      escolha="$(jq -r '.assets[].name' <<<"$json" | fzf --prompt='Build do Hammer++ para qual jogo? > ')" || exit 0
      url="$(jq -r --arg n "$escolha" '.assets[] | select(.name == $n) | .browser_download_url' <<<"$json")"
      dst="$FERRAMENTAS/hammerpp/''${escolha%.*}"
      tmp="$(mktemp -d)"
      curl -fL --progress-bar -o "$tmp/$escolha" "$url"
      rm -rf "$dst"
      extrair "$tmp/$escolha" "$dst"
      rm -rf "$tmp"
      cor "Hammer++ extraído em: $dst"
      echo "    Copie o conteúdo para a pasta bin/ do jogo (a versão WINDOWS do jogo/SDK)."
      echo "    Dica: em Steam > Propriedades > Compatibilidade, force Proton para baixar os .exe do jogo."
      echo "    Depois rode: source-tools hammer"
    }

    cmd_hammer() {
      local lista exe
      lista="$(bibliotecas_steam | sort -u | while read -r lib; do
        if [ -d "$lib/steamapps/common" ]; then
          find "$lib/steamapps/common" -maxdepth 4 -type f \( -iname 'hammerplusplus.exe' -o -iname 'hammer.exe' \) 2>/dev/null || true
        fi
      done)"
      [ -n "$lista" ] || erro "Nenhum hammer.exe/hammerplusplus.exe nas bibliotecas Steam. Instale o jogo/SDK (versão Windows via Proton) e o Hammer++ (source-tools hammerpp)."
      exe="$(fzf --prompt='Abrir qual Hammer? > ' <<<"$lista")" || exit 0
      rodar_exe "$exe" -nop4 "$@"
    }

    cmd_hlmv() {
      local lista exe
      lista="$(bibliotecas_steam | sort -u | while read -r lib; do
        if [ -d "$lib/steamapps/common" ]; then
          find "$lib/steamapps/common" -maxdepth 4 -type f \( -iname 'hlmv.exe' -o -iname 'hlmvplusplus.exe' \) 2>/dev/null || true
        fi
      done)"
      [ -n "$lista" ] || erro "Nenhum hlmv.exe encontrado nas bibliotecas Steam."
      exe="$(fzf --prompt='Abrir qual HLMV? > ' <<<"$lista")" || exit 0
      rodar_exe "$exe" "$@"
    }

    cmd_steam() {
      local escolha
      escolha="$(printf '%s\n' \
        "365670  Blender (Steam)" \
        "4000    Garry's Mod (traz studiomdl, hlmv, gmad, vbsp/vvis/vrad)" \
        "243750  Source SDK Base 2013 Multiplayer" \
        "243730  Source SDK Base 2013 Singleplayer" \
        "211     Source SDK (legado: Hammer/Model Viewer/Face Poser)" \
        "1840    Source Filmmaker (Windows -> rode via Proton)" \
        "440     Team Fortress 2 (bin/ com ferramentas de mapa)" \
        "240     Counter-Strike: Source" \
        "220     Half-Life 2" \
        | fzf --prompt='Instalar pela Steam > ')" || exit 0
      xdg-open "steam://install/''${escolha%% *}"
    }

    cmd_exe() {
      [ $# -ge 1 ] || erro "uso: source-tools exe <arquivo.exe> [args]"
      local exe
      exe="$(realpath "$1")"
      shift
      rodar_exe "$exe" "$@"
    }

    cmd_ajuda() {
      cat <<'AJUDA'
    source-tools — Estúdio de criação Source Engine no NixOS

    PREPARAÇÃO
      setup                 Cria o prefixo Wine dedicado (.NET 4.8, VC++ 2022, d3dx9, fontes)
      baixar [nomes|tudo]   Baixa/atualiza ferramentas das releases oficiais do GitHub
      status                Mostra versões instaladas e estado do prefixo
      hammerpp              Escolhe (fzf) e baixa a build do Hammer++ do seu jogo
      steam                 Instala jogos/SDKs com ferramentas (GMod, SDK 2013, SFM, Blender...)

    FERRAMENTAS VIA WINE (prefixo dedicado)
      crowbar               Compilar/decompilar modelos (.mdl <-> .qc/.smd)
      compilepal            Compilação de mapas avançada (VBSP/VVIS/VRAD + empacotamento)
      hammer                Abre Hammer/Hammer++ encontrado nas bibliotecas Steam
      hlmv                  Abre o Half-Life Model Viewer do jogo
      s2v                   Source 2 Viewer (GUI)
      exe <arquivo.exe>     Roda qualquer .exe no prefixo de modding
      winecfg | winetricks  Configura o prefixo de modding

    FERRAMENTAS NATIVAS (baixadas do GitHub)
      bspsrc                Decompilador de mapas BSP -> VMF (BSPSource)
      lumper                Editor de lumps/entidades/pakfile de BSP (Momentum Mod)
      maretf | maretfcli    Criar/editar/converter VTF (substituto moderno do VTFEdit)
      s2v-cli               Source 2 Viewer em linha de comando
      fastgmad              Criar/extrair/publicar .gma (Garry's Mod)
      glualint              Linter/formatador de GLua

    JÁ INSTALADOS PELO NIXOS (menu de apps / terminal)
      vpkedit, vtfedit, f3d, gimp, krita, inkscape, audacity, lua-language-server...

    VARIÁVEIS: SOURCE_TOOLS_DIR, SOURCE_WINEPREFIX, STEAM_ROOT, GITHUB_TOKEN
    AJUDA
    }

    cmd="''${1:-ajuda}"
    if [ $# -gt 0 ]; then shift; fi

    case "$cmd" in
      setup|preparar)    cmd_setup "$@" ;;
      baixar|atualizar)  cmd_baixar "$@" ;;
      status)            cmd_status ;;
      hammerpp)          cmd_hammerpp ;;
      hammer)            cmd_hammer "$@" ;;
      hlmv)              cmd_hlmv "$@" ;;
      steam)             cmd_steam ;;
      exe)               cmd_exe "$@" ;;
      winecfg)           exec "$WINE" winecfg ;;
      winetricks)        exec winetricks "$@" ;;
      projetos)          exec xdg-open "$PROJETOS" ;;
      pasta)             exec xdg-open "$FERRAMENTAS" ;;
      crowbar)    e="$(achar crowbar 'Crowbar.exe' 'crowbar*.exe' '*.exe')";              exigir crowbar "$e";    rodar_exe "$e" "$@" ;;
      compilepal) e="$(achar compilepal 'CompilePalX.exe' 'compile*pal*.exe')";          exigir compilepal "$e"; rodar_exe "$e" "$@" ;;
      s2v)        e="$(achar s2v 'Source2Viewer.exe' 'source2viewer*.exe')";             exigir s2v "$e";        rodar_exe "$e" "$@" ;;
      s2v-cli)    e="$(achar s2v-cli 'Source2Viewer-CLI' 'source2viewer*cli*')";         exigir s2v-cli "$e";    rodar_nativo "$e" "$@" ;;
      lumper)     e="$(achar lumper 'Lumper.UI' 'Lumper' 'lumper*.appimage')";           exigir lumper "$e";     rodar_nativo "$e" "$@" ;;
      maretf)     e="$(achar maretf 'maretf' 'MareTF' 'maretf*.appimage')";              exigir maretf "$e";     rodar_nativo "$e" "$@" ;;
      maretfcli)  e="$(achar maretf 'maretfcli' 'maretf-cli')";                          exigir maretf "$e";     rodar_nativo "$e" "$@" ;;
      fastgmad)   e="$(achar fastgmad 'fastgmad')";                                      exigir fastgmad "$e";   rodar_nativo "$e" "$@" ;;
      glualint)   e="$(achar glualint 'glualint')";                                      exigir glualint "$e";   rodar_nativo "$e" "$@" ;;
      bspsrc)
        e="$(achar bspsrc 'bspsrc.sh' 'bspsrc')"
        if [ -n "$e" ]; then rodar_nativo "$e" "$@"; fi
        e="$(achar bspsrc 'bspsrc*.jar')"
        exigir bspsrc "$e"
        exec java -jar "$e" "$@"
        ;;
      ajuda|help|-h|--help) cmd_ajuda ;;
      *) aviso "Comando desconhecido: $cmd"; cmd_ajuda; exit 1 ;;
    esac
  '';

  # Atalhos no menu de aplicativos
  atalhosSource = map (a: pkgs.makeDesktopItem {
    name        = "source-${a.id}";
    desktopName = a.nome;
    comment     = a.desc;
    exec        = "source-tools ${a.id}";
    icon        = a.icone;
    terminal    = a.terminal or false;
    categories  = a.cat;
  }) ([
    { id = "baixar";  nome = "Source Tools — Baixar/Atualizar"; desc = "Baixa/atualiza ferramentas de modding Source"; icone = "system-software-update"; cat = [ "Development" ]; terminal = true; }
    { id = "setup";   nome = "Source Tools — Preparar Wine";    desc = "Cria o prefixo Wine de modding (.NET 4.8)";    icone = "wine";                   cat = [ "Development" ]; terminal = true; }
    { id = "crowbar"; nome = "Crowbar";                         desc = "Compilar/decompilar modelos Source";           icone = "applications-graphics";  cat = [ "Graphics" "Development" ]; }
    { id = "maretf";  nome = "MareTF";                          desc = "Editor de texturas VTF nativo";                icone = "applications-graphics";  cat = [ "Graphics" ]; }
  ]
  ++ lib.optionals cs.mapeamento [
    { id = "hammer";     nome = "Hammer / Hammer++"; desc = "Editor de mapas Source (via Wine)";        icone = "applications-engineering"; cat = [ "Development" ]; terminal = true; }
    { id = "compilepal"; nome = "CompilePal";        desc = "Compilador de mapas Source";               icone = "applications-engineering"; cat = [ "Development" ]; }
    { id = "bspsrc";     nome = "BSPSource";         desc = "Decompilador de mapas BSP -> VMF";         icone = "applications-engineering"; cat = [ "Development" ]; }
    { id = "lumper";     nome = "Lumper";            desc = "Editor de lumps BSP (Momentum Mod)";       icone = "applications-engineering"; cat = [ "Development" ]; }
  ]
  ++ lib.optionals cs.source2 [
    { id = "s2v"; nome = "Source 2 Viewer"; desc = "Navegar/extrair assets Source 2 (CS2, Dota 2, Deadlock)"; icone = "applications-graphics"; cat = [ "Graphics" ]; }
  ]);

  # Pacotes do estúdio Source (nixpkgs)
  pacotesCriacao = lib.optionals cs.enable (
    [ sourceTools ]
    ++ lib.optionals cs.atalhosMenu atalhosSource
    ++ (with pkgs; [ winetricks bottles p7zip unzip cabextract zstd imagemagick jq fzf ])
    ++ tentar [ "vpkedit" ]                                 # VPK/GMA/BSP/GCF (nativo, substitui GCFScape)
    ++ lib.optionals cs.modelagem (with pkgs; [ f3d ])
    ++ lib.optionals cs.texturas ((with pkgs; [ gimp krita inkscape ])
         ++ tentar [ "vtfedit" "maretf" "upscayl" "material-maker" ])
    ++ lib.optionals cs.audio (with pkgs; [ audacity sox ])
    ++ lib.optionals cs.mapeamento ([ pkgs.jre ] ++ tentar [ "bspsrc" ])
    ++ lib.optionals cs.garrysmod ((with pkgs; [ lua-language-server stylua luajit ])
         ++ tentar [ "glualint" "fastgmad" ])
    ++ lib.optionals cs.source2 (tentar [ "source2viewer" "valve-resource-format" ])
  );

  # ── HOME MANAGER (ativado se o módulo home-manager estiver carregado) ─────
  hmDisponivel = cfg.usarHomeManager && (options ? home-manager);

  # ────────────────────────────────────────────────────────────────────────
  # nixos-guia (aliases: 'guia', 'ajuda', 'manual'):
  # Central interativa completa no terminal (TUI com fzf + preview colorido)
  # ────────────────────────────────────────────────────────────────────────
  resumoServidoresSrcds = lib.concatStringsSep "\n" (lib.mapAttrsToList (nome: srv:
    "  • ${nome} (AppID ${toString srv.appId}) — Ativo: ${lib.boolToString srv.enable} | Pasta: ${dirDoServidor nome srv}\n"
    + "    Comandos: srcds-${nome}-update | srcds-${nome}-start | srcds-${nome}-stop | srcds-${nome}-logs | srcds-${nome}-dir"
  ) cfg.srcds.servidores);

  guiaInterativo = pkgs.writeShellScriptBin "nixos-guia" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath (with pkgs; [ coreutils gnugrep gnused gawk fzf less ncurses ])}:$PATH"

     DOC_DIR="$(mktemp -d)"
    trap 'rm -rf "$DOC_DIR"' EXIT

    C_TIT=$'\033[1;36m'
    C_SUB=$'\033[1;33m'
    C_CMD=$'\033[1;32m'
    C_OBS=$'\033[1;35m'
    C_DIM=$'\033[0;90m'
    C_RST=$'\033[0m'

    cat > "$DOC_DIR/01-visao-geral.txt" <<EOF
''${C_TIT}==============================================================================
 01. VISÃO GERAL, ARQUITETURA & PAINEL DE CONTROLE
==============================================================================''${C_RST}

''${C_SUB}>> Estado Atual do Seu Sistema (lido do configuration.nix)''${C_RST}
  • Usuário / Hostname : ''${C_CMD}${cfg.usuario}@${cfg.hostname}''${C_RST}
  • Shell Padrão       : ''${C_CMD}${cfg.shellPadrao}''${C_RST} (Bash continua como login shell POSIX seguro)
  • Kernel Ativo       : ''${C_CMD}${cfg.kernel}''${C_RST} | Governador CPU: ''${C_CMD}${cfg.cpuGovernor}''${C_RST}
  • Nvidia Open Module : ''${C_CMD}${lib.boolToString cfg.nvidiaOpen}''${C_RST}
  • Ambientes Gráficos : Plasma=''${C_CMD}${lib.boolToString cfg.desktop.plasma}''${C_RST} | Hyprland=''${C_CMD}${lib.boolToString cfg.desktop.hyprland}''${C_RST} | i3=''${C_CMD}${lib.boolToString cfg.desktop.i3}''${C_RST}
  • Home Manager       : ''${C_CMD}${lib.boolToString cfg.usarHomeManager}''${C_RST}
  • Estúdio Source     : ''${C_CMD}${lib.boolToString cs.enable}''${C_RST}
    - Ferramentas      : ${ferramentasDir}
    - Projetos         : ${projetosDir}
    - Prefixo Wine     : ${prefixoWine}
  • Base Multi-SRCDS   : ${srcdsBaseDir}
  • NixOS StateVersion : ''${C_CMD}${cfg.stateVersion}''${C_RST}

''${C_SUB}>> Os 3 Arquivos Principais em /etc/nixos/''${C_RST}
  1. ''${C_CMD}hardware-configuration.nix''${C_RST}
     Gerado pelo instalador do NixOS com os UUIDs reais das suas partições.
     ''${C_OBS}NUNCA apague nem substitua este arquivo!''${C_RST}

  2. ''${C_CMD}flake.nix''${C_RST}  (atalho para editar: ''${C_CMD}nflake''${C_RST})
     Define as fontes de pacotes:
     • 1º Canal: ''${C_CMD}nixpkgs''${C_RST} (nixos-26.05 estável — base sólida, drivers, kernel)
     • 2º Canal: ''${C_CMD}nixpkgs-unstable''${C_RST} (pacotes sempre na última versão)
     • 3º Canal: ''${C_CMD}inputs''${C_RST} (Flakes externos do GitHub/Git, como Home Manager e srcds-nix)

  3. ''${C_CMD}configuration.nix''${C_RST}  (atalho para editar: ''${C_CMD}nconf''${C_RST})
     No topo dele fica o ''${C_CMD}PAINEL DE CONTROLE RÁPIDO (cfg = { ... })''${C_RST}.
     Quase tudo no sistema (ligar/desligar módulos, trocar kernel, ativar servidores,
     habilitar 2º SSD ou recursos do Estúdio Source) é feito mudando ''${C_CMD}true''${C_RST}/''${C_CMD}false''${C_RST} lá.

''${C_SUB}>> Fluxo Básico de Qualquer Alteração''${C_RST}
  • ''${C_OBS}Modo Visual Rápido (TUI):''${C_RST} digite ''${C_CMD}painel''${C_RST} (ou ''${C_CMD}configurar''${C_RST} / ''${C_CMD}ntui''${C_RST}) para ligar/desligar
    módulos, configurar o 2º SSD automaticamente, gerenciar servidores SRCDS, trocar
    kernel/governador e aplicar tudo pelo menu interativo!
  • ''${C_OBS}Modo Editor Manual:''${C_RST}
    1. Edite a configuração : ''${C_CMD}nconf''${C_RST}
    2. Teste sem gravar boot: ''${C_CMD}nrt''${C_RST}   (opcional, ótimo para testar mudanças arriscadas)
    3. Aplique de vez       : ''${C_CMD}nrs''${C_RST}
    4. Deu algo errado?     : ''${C_CMD}nroll''${C_RST} (volta imediatamente para a geração anterior)
EOF

    cat > "$DOC_DIR/02-aliases.txt" <<EOF
''${C_TIT}==============================================================================
 02. TODOS OS ALIASES (ATALHOS DE TERMINAL) DO SISTEMA
==============================================================================''${C_RST}

''${C_SUB}>> Painel de Controle TUI & Guia Interativo''${C_RST}
  ''${C_CMD}painel''${C_RST} / ''${C_CMD}configurar''${C_RST} / ''${C_CMD}ntui''${C_RST}  Abre o Painel TUI que edita o configuration.nix ao vivo
  ''${C_CMD}guia''${C_RST} / ''${C_CMD}ajuda''${C_RST} / ''${C_CMD}manual''${C_RST}      Abre esta central interativa de documentação no terminal
  ''${C_CMD}guia <palavra>''${C_RST}              Pesquisa uma palavra diretamente em todo o manual
  ''${C_CMD}guia tudo''${C_RST}                   Abre o manual inteiro de uma vez para leitura contínua

''${C_SUB}>> Gerenciamento do NixOS e Flakes''${C_RST}
  ''${C_CMD}nrs''${C_RST}        Aplica alterações (sudo nixos-rebuild switch --flake /etc/nixos#${cfg.hostname})
  ''${C_CMD}nrt''${C_RST}        Testa alterações na sessão atual sem criar entrada no boot
  ''${C_CMD}nroll''${C_RST}      Faz rollback imediato para a geração anterior do sistema
  ''${C_CMD}nconf''${C_RST}      Abre o /etc/nixos/configuration.nix no Neovim com sudo
  ''${C_CMD}nflake''${C_RST}     Abre o /etc/nixos/flake.nix no Neovim com sudo
  ''${C_CMD}nup''${C_RST}        Atualiza o flake.lock (todos os canais) e já aplica com rebuild switch
  ''${C_CMD}ngc''${C_RST}        Limpa gerações antigas (root + usuário) e libera espaço em disco
  ''${C_CMD}nopt''${C_RST}       Otimiza a /nix/store deduplicando arquivos idênticos via hardlinks
  ''${C_CMD}ngen''${C_RST}       Lista todas as gerações instaladas do sistema com datas

''${C_SUB}>> Estúdio de Criação Source Engine''${C_RST}
  ''${C_CMD}st''${C_RST}         Atalho principal para o gerenciador ''${C_CMD}source-tools''${C_RST} (veja: ''${C_CMD}st ajuda''${C_RST})
  ''${C_CMD}crowbar''${C_RST}    Abre o Crowbar (compilador/decompilador de .mdl) no prefixo Wine dedicado
  ''${C_CMD}hammer''${C_RST}     Localiza e abre o Hammer / Hammer++ instalado nas bibliotecas Steam
  ''${C_CMD}s2v''${C_RST}        Abre o Source 2 Viewer (GUI) para CS2 / Deadlock / Dota 2 / HL:Alyx
  ''${C_CMD}sp''${C_RST}         Vai para a sua pasta de projetos (${projetosDir})
  ''${C_CMD}sp-tools''${C_RST}   Vai para a pasta de ferramentas baixadas (${ferramentasDir})

''${C_SUB}>> Multi-SRCDS (Gerados Dinamicamente para Seus Servidores)''${C_RST}
${resumoServidoresSrcds}

''${C_SUB}>> Monitoramento, Segurança e Rede''${C_RST}
  ''${C_CMD}top''${C_RST}        Monitor de recursos completo (btop)
  ''${C_CMD}gpu''${C_RST}        Monitor da placa de vídeo Nvidia em tempo real (nvtop)
  ''${C_CMD}ports''${C_RST}      Lista todas as portas TCP/UDP abertas e qual processo é dono (ss -tulanp)
  ''${C_CMD}myip''${C_RST}       Mostra seu IP público externo
  ''${C_CMD}espaco''${C_RST}     Uso de disco limpo (ignora tmpfs/devtmpfs)
  ''${C_CMD}limpar-ram''${C_RST} Esvazia caches de página da memória RAM com segurança
  ''${C_CMD}erros-boot''${C_RST} Mostra apenas erros críticos (prioridade 3) do boot atual no systemd

''${C_SUB}>> Git & Docker''${C_RST}
  ''${C_CMD}lg''${C_RST}         Interface visual completa para Git no terminal (lazygit)
  ''${C_CMD}gs''${C_RST}         git status curto e limpo (-sb)
  ''${C_CMD}ga''${C_RST}         git add .
  ''${C_CMD}gc''${C_RST}         git commit -m
  ''${C_CMD}gp''${C_RST}         git push
  ''${C_CMD}dps''${C_RST}        Lista containers Docker ativos em tabela formatada
  ''${C_CMD}dcu''${C_RST}        docker compose up -d
  ''${C_CMD}dcd''${C_RST}        docker compose down
  ''${C_CMD}dlogs''${C_RST}      docker compose logs -f
EOF

    cat > "$DOC_DIR/03-instalar-programas.txt" <<EOF
''${C_TIT}==============================================================================
 03. COMO INSTALAR PROGRAMAS (OS 3 CANAIS + TEMPORÁRIOS)
==============================================================================''${C_RST}

Pesquise o nome exato de qualquer pacote em: ''${C_CMD}https://search.nixos.org/packages''${C_RST}

''${C_SUB}>> 1º Canal: STABLE (Padrão — 95% dos programas)''${C_RST}
  Estável, testado e nunca quebra. Basta colocar o nome na lista ''${C_CMD}environment.systemPackages''${C_RST}
  (ou em ''${C_CMD}home.packages''${C_RST}) dentro do ''${C_CMD}configuration.nix''${C_RST}:
    ''${C_CMD}environment.systemPackages = (with pkgs; [''${C_RST}
      ''${C_CMD}vlc''${C_RST}
      ''${C_CMD}gimp''${C_RST}
    ''${C_CMD}]);''${C_RST}
  Depois salve e rode: ''${C_CMD}nrs''${C_RST}

''${C_SUB}>> 2º Canal: UNSTABLE (Pacotes na última versão lançada hoje)''${C_RST}
  Quer um programa recém-atualizado sem tirar o resto do PC do canal estável?
  Adicione o prefixo ''${C_CMD}pkgsUnstable.''${C_RST} antes do nome:
    ''${C_CMD}pkgsUnstable.proton-vpn''${C_RST}
    ''${C_CMD}pkgsUnstable.obsidian''${C_RST}
  Para forçar um serviço do NixOS (como o ''${C_CMD}services.i2p''${C_RST}) a usar o pacote do Unstable,
  usamos ''${C_CMD}nixpkgs.overlays''${C_RST} (já configurado para o ''${C_CMD}i2p = pkgsUnstable.i2p;''${C_RST}).

''${C_SUB}>> 3º Canal: FLAKES DE TERCEIROS (Programas direto do GitHub/Git)''${C_RST}
  1. Abra o ''${C_CMD}flake.nix''${C_RST} (''${C_CMD}nflake''${C_RST}) e adicione a URL em ''${C_CMD}inputs''${C_RST}:
       ''${C_CMD}zen-browser.url = "github:0xc000022070/zen-browser-flake";''${C_RST}
  2. No ''${C_CMD}configuration.nix''${C_RST} (''${C_CMD}nconf''${C_RST}), adicione em ''${C_CMD}home.packages''${C_RST} ou ''${C_CMD}systemPackages''${C_RST}:
       ''${C_CMD}inputs.zen-browser.packages.\''${pkgs.stdenv.hostPlatform.system}.default''${C_RST}
  3. Rode ''${C_CMD}nrs''${C_RST}.
  ''${C_OBS}Dica Source Engine:''${C_RST} Descomentando ''${C_CMD}srcds-nix''${C_RST} no ''${C_CMD}flake.nix''${C_RST}, o ''${C_CMD}configuration.nix''${C_RST}
  passa a puxar pacotes nativos como ''${C_CMD}maretf''${C_RST} direto dele automaticamente!

''${C_SUB}>> Testar um Programa Agora Sem Instalar (Shell Temporário)''${C_RST}
  Precisa usar uma ferramenta só uma vez?
    ''${C_CMD}nix-shell -p ffmpeg imagemagick''${C_RST}
  Ou executar direto via Flake:
    ''${C_CMD}nix run nixpkgs#fastfetch''${C_RST}
  Quando fechar o terminal, tudo some sem sujar o sistema.

''${C_SUB}>> Flatpak e AppImage''${C_RST}
  • ''${C_CMD}Flatpak''${C_RST} (Flathub já vem configurado automaticamente no boot):
      ''${C_CMD}flatpak install flathub com.spotify.Client''${C_RST}
  • ''${C_CMD}AppImage''${C_RST} (''${C_CMD}binfmt''${C_RST} ativado no kernel):
      Basta dar permissão de execução (''${C_CMD}chmod +x arquivo.AppImage''${C_RST}) e abrir com 2 cliques
      ou rodar ''${C_CMD}appimage-run arquivo.AppImage''${C_RST}.
EOF

    cat > "$DOC_DIR/04-home-manager.txt" <<EOF
''${C_TIT}==============================================================================
 04. HOME MANAGER NA PRÁTICA (DOTFILES & APPS DO USUÁRIO)
==============================================================================''${C_RST}

O Home Manager já está embutido dentro do seu ''${C_CMD}configuration.nix''${C_RST} (em ''${C_CMD}moduloHomeManager''${C_RST}).
Você não precisa rodar comandos separados: um simples ''${C_CMD}nrs''${C_RST} reconstrói o sistema e a sua ''${C_CMD}\$HOME''${C_RST}.

''${C_SUB}>> Onde Editar''${C_RST}
  Procure por ''${C_CMD}moduloHomeManager''${C_RST} no ''${C_CMD}configuration.nix''${C_RST} (''${C_CMD}nconf''${C_RST}).

''${C_SUB}>> O Que Já Está Configurado Nele''${C_RST}
  • ''${C_CMD}programs.git.settings''${C_RST} (nova sintaxe do HM 25.11/26.05+):
    Define seu nome (''${C_CMD}cfg.gitUser''${C_RST}), e-mail (''${C_CMD}cfg.gitEmail''${C_RST}) e branch padrão ''${C_CMD}main''${C_RST}.
  • ''${C_CMD}programs.fish''${C_RST} + ''${C_CMD}programs.starship''${C_RST}:
    Integra o prompt Starship automaticamente ao seu shell Fish.
  • ''${C_CMD}xdg.userDirs''${C_RST}:
    Cria e mantém as pastas padrão da sua ''${C_CMD}\$HOME''${C_RST}.

''${C_SUB}>> Como Declarar Configs de Programas (Exemplos)''${C_RST}
  Quer configurar o Kitty ou criar um arquivo de config declarativo na ''${C_CMD}\$HOME''${C_RST}?
  Dentro de ''${C_CMD}users.\''${cfg.usuario} = { pkgs, ... }: {''${C_RST} adicione:

    ''${C_CMD}programs.kitty = {''${C_RST}
      ''${C_CMD}enable = true;''${C_RST}
      ''${C_CMD}settings = {''${C_RST}
        ''${C_CMD}font_size = 12;''${C_RST}
        ''${C_CMD}background_opacity = "0.92";''${C_RST}
      ''${C_CMD}};''${C_RST}
    ''${C_CMD}};''${C_RST}

  Ou para gravar qualquer arquivo em ''${C_CMD}~/.config/''${C_RST}:
    ''${C_CMD}xdg.configFile."hypr/hyprpaper.conf".text = "preload = ~/Pictures/wall.png";''${C_RST}

''${C_SUB}>> E se já existir um arquivo antigo na minha \$HOME?''${C_RST}
  A opção ''${C_CMD}backupFileExtension = "backup"''${C_RST} está ativa: o Home Manager nunca trava o build
  por conflito de arquivo — ele renomeia o antigo para ''${C_CMD}.backup''${C_RST} e aplica o novo.
EOF

    cat > "$DOC_DIR/05-source-inicio.txt" <<EOF
''${C_TIT}==============================================================================
 05. ESTÚDIO SOURCE ENGINE — PRIMEIROS PASSOS (source-tools)
==============================================================================''${C_RST}

Seu NixOS vem com um gerenciador próprio chamado ''${C_CMD}source-tools''${C_RST} (atalho: ''${C_CMD}st''${C_RST}).
Ele resolve os 2 maiores desafios de trabalhar com Source Engine no Linux:
  1. ''${C_OBS}Ferramentas Windows (.NET 4.8 / MFC / WinForms)''${C_RST}: cria um prefixo Wine 64-bit isolado e
     pré-configurado com ''${C_CMD}dotnet48''${C_RST}, ''${C_CMD}vcrun2022''${C_RST}, ''${C_CMD}d3dx9''${C_RST}, ''${C_CMD}d3dcompiler_47''${C_RST} e ''${C_CMD}corefonts''${C_RST}.
  2. ''${C_OBS}Releases no GitHub''${C_RST}: baixa e atualiza automaticamente os binários oficiais (Linux e Windows)
     direto das releases dos criadores.

''${C_SUB}>> Passo a Passo de Preparação Inicial (Rode 1 vez)''${C_RST}
  1. Prepare o prefixo Wine de modding (leva de 10 a 20 min por causa do .NET 4.8):
       ''${C_CMD}st setup''${C_RST}
  2. Baixe todas as ferramentas do GitHub de uma vez:
       ''${C_CMD}st baixar''${C_RST}
  3. Confira se está tudo instalado e atualizado:
       ''${C_CMD}st status''${C_RST}

''${C_SUB}>> Onde Ficam as Pastas''${C_RST}
  • Projetos (''${C_CMD}sp''${C_RST} no terminal ou ''${C_CMD}st projetos''${C_RST}):
      ''${C_CMD}${projetosDir}/''${C_RST}
        ├── ''${C_CMD}modelos/''${C_RST}       (.blend, .smd, .dmx, .qc)
        ├── ''${C_CMD}materiais/''${C_RST}     (.vtf, .vmt, .psd, .png)
        ├── ''${C_CMD}mapas/''${C_RST}         (.vmf, .bsp)
        ├── ''${C_CMD}sons/''${C_RST}          (.wav PCM 16-bit 44.1 kHz)
        ├── ''${C_CMD}addons/''${C_RST}        (addons de Garry's Mod)
        └── ''${C_CMD}decompilados/''${C_RST}  (saídas do Crowbar, BSPSource e Source2Viewer)
  • Ferramentas baixadas (''${C_CMD}sp-tools''${C_RST} ou ''${C_CMD}st pasta''${C_RST}):
      ''${C_CMD}${ferramentasDir}/''${C_RST}
  • Prefixo Wine exclusivo:
      ''${C_CMD}${prefixoWine}/''${C_RST}

''${C_SUB}>> Como Rodar Qualquer Outro .exe de Modding no Mesmo Prefixo''${C_RST}
  Baixou uma ferramenta avulsa de Source (ex: ''${C_CMD}GCFScape.exe''${C_RST}, ''${C_CMD}Packbsp.exe''${C_RST}, ''${C_CMD}VIDE.exe''${C_RST})?
    ''${C_CMD}st exe /caminho/para/Programa.exe''${C_RST}
EOF

    cat > "$DOC_DIR/06-source-modelos.txt" <<EOF
''${C_TIT}==============================================================================
 06. COMO FAZER: MODELOS 3D (CROWBAR + BLENDER + STUDIOMDL + HLMV)
==============================================================================''${C_RST}

''${C_SUB}>> 1. Abrir o Crowbar (Compilar / Decompilar .mdl)''${C_RST}
  No terminal (ou pelo menu de aplicativos):
    ''${C_CMD}crowbar''${C_RST}   (ou ''${C_CMD}st crowbar''${C_RST})

''${C_SUB}>> 2. Como Apontar o studiomdl.exe no Crowbar (Pulo do Gato no Linux!)''${C_RST}
  Dentro do Wine, a raiz do seu Linux (''${C_CMD}/''${C_RST}) fica mapeada na letra ''${C_CMD}Z:\\''${C_RST}.
  • Na aba ''${C_CMD}Set Up Games''${C_RST} do Crowbar, aponte para o ''${C_CMD}studiomdl.exe''${C_RST} da sua Steam:
      ''${C_CMD}Z:\\home\\${cfg.usuario}\\.local\\share\\Steam\\steamapps\\common\\GarrysMod\\bin\\studiomdl.exe''${C_RST}
    (ou da pasta ''${C_CMD}bin\\''${C_RST} do ''${C_CMD}Source SDK Base 2013''${C_RST} / ''${C_CMD}Counter-Strike Source''${C_RST}).
  • ''${C_OBS}Importante:''${C_RST} se na pasta ''${C_CMD}bin/''${C_RST} do jogo só houver binários Linux (''${C_CMD}studiomdl_linux''${C_RST}) e faltar
    o ''${C_CMD}studiomdl.exe''${C_RST}, clique com o botão direito no jogo/SDK na Steam > ''${C_CMD}Propriedades''${C_RST} >
    ''${C_CMD}Compatibilidade''${C_RST} > marque ''${C_CMD}Forçar o uso de ferramenta Steam Play (Proton)''${C_RST}. A Steam
    baixará os '.exe' de Windows imediatamente!

''${C_SUB}>> 3. Blender (via Steam) e Addons (Source 1 & Source 2)''${C_RST}
  • Instale o ''${C_CMD}Blender''${C_RST} diretamente pela sua ''${C_CMD}Steam''${C_RST} e instale as extensões manualmente em
    ''${C_CMD}Edit > Preferences > Add-ons / Get Extensions''${C_RST}:
     • ''${C_CMD}Blender Source Tools''${C_RST}: exporta suas malhas e animações em '.smd' / '.dmx' prontos
       para compilar com seu arquivo '.qc' no Crowbar.
     • ''${C_CMD}SourceIO (REDxEYE)''${C_RST}: importa direto '.mdl', '.vtf', '.vmt', mapas '.bsp' (Source 1)
       e '.vmdl_c', '.vtex_c', '.vpk' (Source 2).
     • ''${C_CMD}BlenderSource2Tools (FellOffFuji)''${C_RST}: fork atualizado para Blender 4.2 a 5.0 focado em
       exportar DMX para Source 2 (CS2 / Deadlock).

''${C_SUB}>> 4. Visualizar Modelos Rápido (F3D e HLMV)''${C_RST}
  • ''${C_CMD}f3d modelo.obj''${C_RST} (ou '.gltf', '.fbx', '.stl', '.ply') — visualizador 3D instantâneo nativo.
  • ''${C_CMD}st hlmv''${C_RST} — procura automaticamente o ''${C_CMD}hlmv.exe''${C_RST} (Half-Life Model Viewer) nos seus jogos
    da Steam e abre via Wine para inspecionar hitboxes, bones, attachments e materiais '.vmt'.
EOF

    cat > "$DOC_DIR/07-source-texturas-audio.txt" <<EOF
''${C_TIT}==============================================================================
 07. COMO FAZER: TEXTURAS (.VTF/.VMT), PACOTES (.VPK/.GMA) E ÁUDIO (.WAV)
==============================================================================''${C_RST}

''${C_SUB}>> 1. MareTF vs VTFEdit (Texturas .vtf e Materiais .vmt)''${C_RST}
  Você tem ''${C_OBS}duas opções''${C_RST} instaladas para trabalhar com VTF:

  • ''${C_CMD}MareTF''${C_RST} (Nativo de Linux — Recomendado!):
    Criado pela 'craftablescience' (mesmo autor do VPKEdit), é o substituto moderno e nativo
    do VTFEdit e do vtex2. Suporta todas as versões de VTF (7.0 a 7.6 / Strata Source),
    converte PNG/TGA/PSD/EXR/HDR/GIF/WebP, gera mipmaps e cubemaps HDRI.
      GUI : ''${C_CMD}st maretf''${C_RST}  (ou pelo menu de aplicativos)
      CLI : ''${C_CMD}st maretfcli''${C_RST}

  • ''${C_CMD}VTFEdit''${C_RST} (Clássico de Windows):
    Instalado diretamente pelo 'nixpkgs' (já empacotado com wrapper Wine próprio):
      GUI : digite ''${C_CMD}vtfedit''${C_RST} no terminal ou abra pelo menu de apps.

  • Edição de imagem 2D / Normal Maps / PBR:
    ''${C_CMD}gimp''${C_RST}, ''${C_CMD}krita''${C_RST}, ''${C_CMD}inkscape''${C_RST}, ''${C_CMD}upscayl''${C_RST} (upscale por IA) e ''${C_CMD}magick''${C_RST} (ImageMagick CLI).

''${C_SUB}>> 2. VPKEdit (Substituto Nativo do GCFScape)''${C_RST}
  Abre, inspeciona, extrai e cria arquivos '.vpk', '.gma' (GMod), '.bsp' (pakfile embutido),
  '.wad' (GoldSrc/HL1), '.gcf' e '.pak' — com preview de texturas, áudio e modelos 3D:
    GUI : ''${C_CMD}vpkedit''${C_RST}
    CLI : ''${C_CMD}vpkeditcli''${C_RST}

''${C_SUB}>> 3. Áudio para Source Engine (Audacity + SoX)''${C_RST}
  A Source Engine exige arquivos '.wav' em ''${C_OBS}PCM 16-bit, 44100 Hz (ou 22050 Hz)''${C_RST}.
  • Para converter qualquer áudio instantaneamente via terminal com ''${C_CMD}sox''${C_RST}:
      ''${C_CMD}sox entrada.mp3 -b 16 -e signed-integer -r 44100 saida.wav''${C_RST}
  • Para loopings (cue points) e edição multipista: abra o ''${C_CMD}audacity''${C_RST}.
EOF

    cat > "$DOC_DIR/08-source-mapas.txt" <<EOF
''${C_TIT}==============================================================================
 08. COMO FAZER: MAPAS (HAMMER++, COMPILEPAL, BSPSOURCE, LUMPER)
==============================================================================''${C_RST}

''${C_SUB}>> 1. Como Instalar e Abrir o Hammer++ no Linux''${C_RST}
  O Hammer e o Hammer++ usam APIs Win32/MFC de Windows. Para rodar perfeitamente:
  1. Na Steam, ative o ''${C_CMD}Proton''${C_RST} nas 'Propriedades > Compatibilidade' do jogo/SDK
     (ex: 'Source SDK Base 2013 Multiplayer', 'Garrys Mod', 'TF2' ou 'CS:S') para que a Steam
     baixe a pasta ''${C_CMD}bin/''${C_RST} de Windows (com 'hammer.exe', 'vbsp.exe', 'vvis.exe', 'vrad.exe').
  2. Baixe a build correspondente do Hammer++ pelo seletor interativo:
       ''${C_CMD}st hammerpp''${C_RST}
  3. Copie os arquivos extraídos (mostrados pelo comando) para dentro da pasta ''${C_CMD}bin/''${C_RST} do jogo.
  4. Para abrir o Hammer++ a qualquer momento:
       ''${C_CMD}hammer''${C_RST}   (ou ''${C_CMD}st hammer''${C_RST})
     Ele vasculha todas as suas bibliotecas Steam (inclusive no 2º SSD) e abre com '-nop4'.

''${C_SUB}>> 2. Dicas Importantes de Compilação no Hammer++ (F9)''${C_RST}
  • Nos parâmetros do modo Expert (F9), se o compilador reclamar que não achou o arquivo,
    adicione a extensão explícita ''${C_CMD}.\$ext''${C_RST} após ''${C_CMD}\$file''${C_RST} (ex: '"\$path\\\$file.\$ext"').
  • ''${C_OBS}Case-Sensitivity no Linux:''${C_RST} no Windows, 'Materials/MeuMod/Tex.vmt' e 'materials/meumod/tex.vmt'
    são iguais; no Linux ('ext4'/'btrfs'), letras maiúsculas e minúsculas importam! Use sempre
    nomes de pastas e materiais em ''${C_CMD}minúsculas''${C_RST}.

''${C_SUB}>> 3. CompilePal, BSPSource e Lumper''${C_RST}
  • ''${C_CMD}st compilepal''${C_RST} : Abre o 'CompilePal' (compilação em lote + 'Pack' automático de assets
    customizados dentro do '.bsp').
  • ''${C_CMD}st bspsrc''${C_RST}     : Abre o 'BSPSource' (nativo em Java) para decompilar mapas '.bsp' de volta
    para '.vmf' editáveis no Hammer.
  • ''${C_CMD}st lumper''${C_RST}     : Abre o 'Lumper' (da equipe do Momentum Mod, nativo) para inspecionar e
    editar entidades, pakfile/texturas embutidas e lumps de um '.bsp' sem precisar recompilar!
EOF

    cat > "$DOC_DIR/09-source-gmod-s2.txt" <<EOF
''${C_TIT}==============================================================================
 09. COMO FAZER: ADDONS DE GARRY'S MOD (GLUA/GMA) & SOURCE 2 (CS2/DEADLOCK)
==============================================================================''${C_RST}

''${C_SUB}>> 1. Desenvolvimento GLua (Garry's Mod)''${C_RST}
  Já vêm instalados no sistema:
  • ''${C_CMD}lua-language-server''${C_RST} e ''${C_CMD}stylua''${C_RST} (prontos para VSCode / Neovim)
  • ''${C_CMD}luajit''${C_RST} (mesma engine JIT usada pelo GMod)
  • ''${C_CMD}st glualint <pasta/lua>''${C_RST} — executa o 'GLuaFixer' para achar erros de sintaxe, variáveis
    globais vazadas e formatar código GLua.

''${C_SUB}>> 2. Empacotar, Extrair e Publicar .GMA Ultra-Rápido (fastgmad)''${C_RST}
  O 'fastgmad' substitui o 'gmad' e o 'gmpublish' sendo até 100x mais rápido:
  • Criar um arquivo '.gma' a partir da pasta do seu addon:
      ''${C_CMD}st fastgmad create -folder ~/SourceProjects/addons/meu_addon -out ~/SourceProjects/meu_addon.gma''${C_RST}
  • Extrair um '.gma':
      ''${C_CMD}st fastgmad extract -file arquivo.gma -out ~/SourceProjects/decompilados/addon''${C_RST}
  • Alternativa com interface gráfica: abra qualquer '.gma' direto no ''${C_CMD}vpkedit''${C_RST}!

''${C_SUB}>> 3. Source 2 (Counter-Strike 2, Deadlock, Dota 2, Half-Life: Alyx)''${C_RST}
  • ''${C_CMD}s2v''${C_RST} (ou ''${C_CMD}st s2v''${C_RST}):
    Abre o 'Source 2 Viewer' (ValveResourceFormat) com interface gráfica para navegar em
    arquivos 'pak01_dir.vpk', visualizar modelos/mapas/materiais/partículas e decompilar
    '.vmdl_c' -> '.gltf'/'.vmdl', '.vtex_c' -> '.png' e '.vmap_c' -> '.vmap'.
  • ''${C_CMD}st s2v-cli''${C_RST}:
    Versão nativa Linux em linha de comando para extração em lote por script:
      ''${C_CMD}st s2v-cli -i pak01_dir.vpk -o ~/SourceProjects/decompilados/cs2 -d''${C_RST}
EOF

    cat > "$DOC_DIR/10-multi-srcds.txt" <<EOF
''${C_TIT}==============================================================================
 10. MULTI-SRCDS: SERVIDORES DEDICADOS (GMOD, CS2, TF2, CSS...)
==============================================================================''${C_RST}

O 'configuration.nix' possui um gerador automático de servidores dedicados isolados.
Para cada servidor em ''${C_CMD}cfg.srcds.servidores''${C_RST}, o NixOS cria:
  • As pastas automaticamente via 'systemd-tmpfiles'
  • A abertura dinâmica apenas das portas TCP/UDP dos servidores ativos no firewall
  • Um serviço 'systemd' blindado contra RCE ('ProtectHome=tmpfs', 'NoNewPrivileges',
    bloqueio de 'docker.sock', 'ProtectKernelTunables') e com 'GLIBC_TUNABLES' p/ Glibc 2.42
  • 7 aliases automáticos no terminal!

''${C_SUB}>> Servidores Configurados Atualmente''${C_RST}
${resumoServidoresSrcds}

''${C_SUB}>> Passo a Passo para Ligar um Servidor (Ex: Garry's Mod)''${C_RST}
  1. Baixe os arquivos do servidor via SteamCMD (não precisa estar com 'enable = true' ainda):
       ''${C_CMD}srcds-gmod-update''${C_RST}
  2. Abra o ''${C_CMD}nconf''${C_RST}, vá em ''${C_CMD}cfg.srcds.servidores.gmod''${C_RST} e mude:
       ''${C_CMD}enable = true;''${C_RST}
  3. Aplique com ''${C_CMD}nrs''${C_RST} (isso cria o serviço systemd e abre a porta 27015 no firewall).
  4. Controle o servidor:
       ''${C_CMD}srcds-gmod-start''${C_RST}    (inicia)
       ''${C_CMD}srcds-gmod-logs''${C_RST}     (acompanha o console em tempo real; Ctrl+C sai do log)
       ''${C_CMD}srcds-gmod-restart''${C_RST}  (reinicia)
       ''${C_CMD}srcds-gmod-stop''${C_RST}     (para)
       ''${C_CMD}srcds-gmod-dir''${C_RST}      (entra na pasta do servidor para editar server.cfg / addons)

''${C_SUB}>> Como Adicionar um Novo Servidor (Ex: Team Fortress 2 — AppID 232250)''${C_RST}
  Basta copiar o bloco 'gmod' dentro de ''${C_CMD}cfg.srcds.servidores''${C_RST} com o nome ''${C_CMD}tf2''${C_RST}, mudar
  o 'appId = 232250;', a porta (ex: '27017') e rodar ''${C_CMD}nrs''${C_RST}. Os comandos 'srcds-tf2-*'
  aparecerão automaticamente!
EOF

    cat > "$DOC_DIR/11-manutencao-dicas.txt" <<EOF
''${C_TIT}==============================================================================
 11. COMO FAZER: 2º SSD, ROLLBACK, NVIDIA, DOCKER & I2P
==============================================================================''${C_RST}

''${C_SUB}>> 1. Montar um 2º SSD / NVMe Automaticamente no Boot''${C_RST}
  1. Descubra o UUID e o tipo da partição rodando no terminal:
       ''${C_CMD}lsblk -f''${C_RST}
  2. Abra o ''${C_CMD}nconf''${C_RST} e edite ''${C_CMD}cfg.discoSecundario''${C_RST}:
       ''${C_CMD}enable = true;''${C_RST}
       ''${C_CMD}uuid = "SEU-UUID-AQUI";''${C_RST}
       ''${C_CMD}fsType = "ext4";''${C_RST}  (ou "btrfs" ou "ntfs3" se for compartilhado com Windows)
  3. Rode ''${C_CMD}nrs''${C_RST}. Ele usa 'nofail' (se desconectar o disco, o PC continua dando boot normal).

''${C_SUB}>> 2. Rollback e Recuperação de Desastres''${C_RST}
  • Se o sistema está ligado mas algo quebrou após um update: ''${C_CMD}nroll''${C_RST}
  • Se não entrar na interface gráfica: no menu do 'systemd-boot' ao ligar o PC, basta
    escolher a geração anterior com as setas do teclado!

''${C_SUB}>> 3. Nvidia + Wayland (KDE Plasma 6 & Hyprland)''${C_RST}
  • Na tela de login (SDDM), você pode alternar entre ''${C_CMD}Plasma (Wayland)''${C_RST} e ''${C_CMD}Hyprland (UWSM)''${C_RST}.
  • Placas RTX série 20 (Turing) ou mais novas (RTX 30/40/50): recomenda-se mudar
    ''${C_CMD}nvidiaOpen = true;''${C_RST} no Painel de Controle. Placas GTX 900/10xx: mantenha ''${C_CMD}false''${C_RST}.

''${C_SUB}>> 4. Docker Blindado (dockerLocalOnly)''${C_RST}
  Por padrão, o Docker ignora o firewall e expõe portas '-p 8080:80' para toda a sua rede Wi-Fi/LAN.
  Com ''${C_CMD}dockerLocalOnly = true''${C_RST} no painel, qualquer container só escuta em '127.0.0.1'
  (sua máquina), protegendo seu PC em redes locais.

''${C_SUB}>> 5. Roteador I2P (via Canal Unstable)''${C_RST}
  O módulo 'services.i2p' está configurado com um overlay que puxa o pacote ''${C_CMD}i2p''${C_RST} sempre atualizado
  direto do 'pkgsUnstable'. Para verificar o serviço: ''${C_CMD}systemctl status i2p''${C_RST}.
EOF

    cat > "$DOC_DIR/12-faq.txt" <<EOF
''${C_TIT}==============================================================================
 12. FAQ & RESOLUÇÃO DE PROBLEMAS (TROUBLESHOOTING)
==============================================================================''${C_RST}

''${C_SUB}P: Criei um arquivo .nix novo em /etc/nixos/ e o 'nrs' diz que ele não existe!''${C_RST}
  R: Quando a pasta '/etc/nixos' usa Git, o Nix Flakes ignora arquivos não rastreados.
     Basta rodar: ''${C_CMD}cd /etc/nixos && sudo git add .''${C_RST} (não precisa nem dar commit).

''${C_SUB}P: O 'st setup' falhou ao instalar o dotnet48 no Wine. Como resolver?''${C_RST}
  R: Algumas versões do Wine no modo novo WoW64 ('wineWow64Packages') podem conflitar com o
     instalador do .NET 4.8. Se acontecer:
     1. No 'configuration.nix' ('nconf'), mude ''${C_CMD}wineVariante = "classico";''${C_RST} em 'criacaoSource'.
     2. Rode ''${C_CMD}nrs''${C_RST}.
     3. Apague o prefixo antigo (''${C_CMD}rm -rf ${prefixoWine}''${C_RST}) e rode ''${C_CMD}st setup''${C_RST} novamente,
        ou use o ''${C_CMD}bottles''${C_RST} (já instalado no menu de apps) para criar uma garrafa com 'dotnet48'.

''${C_SUB}P: Meu servidor Garry's Mod / binário Source 1 deu erro 'cannot enable executable stack'!''${C_RST}
  R: Isso ocorre no Glibc 2.41/2.42+ (NixOS 26.05) com binários antigos da Valve.
     Os serviços 'srcds-*' e o 'source-tools' já injetam ''${C_CMD}GLIBC_TUNABLES=glibc.rtld.execstack=2''${C_RST}
     automaticamente! Se for rodar um binário manualmente fora deles ou nas opções de arranque
     da Steam, use:
       ''${C_CMD}GLIBC_TUNABLES=glibc.rtld.execstack=2 %command%''${C_RST}

''${C_SUB}P: As janelas flutuantes do Hammer++ somem atrás da janela principal no Wayland!''${C_RST}
  R: No 'st winecfg', na aba 'Graphics', marque ''${C_CMD}Emulate a virtual desktop''${C_RST} (ex: '1920x1080').
     Isso mantém todos os diálogos de textura/entidade do Hammer++ contidos dentro de uma
     única janela perfeitamente comportada tanto no Hyprland quanto no Plasma Wayland.

''${C_SUB}P: Como liberar bastante espaço em disco quando o SSD encher?''${C_RST}
  R: Rode ''${C_CMD}ngc''${C_RST} (apaga gerações antigas) seguido de ''${C_CMD}nopt''${C_RST} (deduplica a '/nix/store').
EOF

    mostrar_arquivo() {
      less -R -f "$1"
    }

    buscar_global() {
      local linha arq
      linha="$(grep -rn --color=always "" "$DOC_DIR"/*.txt \
        | sed "s|$DOC_DIR/||" \
        | fzf --ansi \
              --prompt="Pesquisar em todo o guia > " \
              --header="Digite qualquer termo (ex: crowbar,hammer,srcds,ssd,flake,wine) | ENTER abre a seção | ESC volta" \
              --delimiter=: \
              --preview="sed -n '1,120p' '$DOC_DIR/'{1}" \
              --preview-window="right:62%:wrap")" || return 0
      arq="$(cut -d: -f1 <<<"$linha")"
      mostrar_arquivo "$DOC_DIR/$arq"
    }

    # Modo direto por argumento: 'guia tudo' ou 'guia <termo>'
    if [ $# -gt 0 ]; then
      case "$1" in
        tudo|all)
          cat "$DOC_DIR"/*.txt | less -R
          exit 0
          ;;
        *)
          grep -rn --color=always -i "$*" "$DOC_DIR"/*.txt | sed "s|$DOC_DIR/||" | less -R
          exit 0
          ;;
      esac
    fi

    MENU="$(cat <<'ITENS'
01-visao-geral.txt	01. Visão Geral, Arquitetura & Painel de Controle
02-aliases.txt	02. Todos os Aliases (Atalhos de Terminal) do Sistema
03-instalar-programas.txt	03. Como Instalar Programas (Stable, Unstable, Flakes, Flatpak)
04-home-manager.txt	04. Home Manager na Prática (Dotfiles, Git & Apps do Usuário)
05-source-inicio.txt	05. Estúdio Source Engine — Primeiros Passos (source-tools)
06-source-modelos.txt	06. Como Fazer: Modelos 3D (Crowbar + Blender + studiomdl + HLMV)
07-source-texturas-audio.txt	07. Como Fazer: Texturas (MareTF/VTFEdit), VPKEdit & Áudio (.wav)
08-source-mapas.txt	08. Como Fazer: Mapas (Hammer++, CompilePal, BSPSource, Lumper)
09-source-gmod-s2.txt	09. Como Fazer: Addons de Garry's Mod (GLua/GMA) & Source 2 (CS2)
10-multi-srcds.txt	10. Multi-SRCDS: Servidores Dedicados (GMod, CS2, TF2...)
11-manutencao-dicas.txt	11. Como Fazer: 2º SSD, Rollback, Nvidia, Docker & I2P
12-faq.txt	12. FAQ & Resolução de Problemas (Troubleshooting)
BUSCA	13. [Pesquisa Global] Procurar uma palavra em todas as seções
TUDO	14. [Modo Livro] Ler o manual completo de ponta a ponta
SAIR	00. Sair do Guia
ITENS
)"

    while true; do
      escolha="$(printf '%s\n' "$MENU" | fzf \
        --ansi \
        --layout=reverse \
        --height=95% \
        --border=rounded \
        --prompt="Guia NixOS (${cfg.usuario}@${cfg.hostname}) > " \
        --header="↑/↓ navega (preview ao lado) | Digite p/ filtrar | ENTER abre tela cheia (q volta) | ESC sai" \
        --delimiter=$'\t' \
        --with-nth=2 \
        --preview="if [ -f '$DOC_DIR/'{1} ]; then cat '$DOC_DIR/'{1}; elif [ {1} = BUSCA ]; then printf '\033[1;36mPesquisa Global\033[0m\n\nPressione ENTER para pesquisar qualquer comando, ferramenta ou dúvida em todas as páginas do guia simultaneamente.'; elif [ {1} = TUDO ]; then printf '\033[1;36mModo Livro Completo\033[0m\n\nPressione ENTER para abrir todas as 12 seções concatenadas em sequência.'; else printf 'Encerra o guia interativo.'; fi" \
        --preview-window="right:65%:wrap")" || break

      id="''${escolha%%$'\t'*}"
      case "$id" in
        SAIR|"") break ;;
        BUSCA)   buscar_global ;;
        TUDO)    cat "$DOC_DIR"/*.txt | less -R ;;
        *)       mostrar_arquivo "$DOC_DIR/$id" ;;
      esac
    done
  '';

  # ────────────────────────────────────────────────────────────────────────
  # nixos-painel (aliases: 'painel', 'configurar', 'ntui'):
  # Utilitário TUI interativo que lê e edita o Painel de Controle (cfg) do
  # /etc/nixos/configuration.nix ao vivo, configura 2º SSD via lsblk,
  # gerencia servidores SRCDS e aplica/testa alterações com segurança.
  # ────────────────────────────────────────────────────────────────────────
  painelInterativo = pkgs.writeShellScriptBin "nixos-painel" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath (with pkgs; [ coreutils gnugrep gnused gawk fzf less diffutils util-linux python3 git neovim ])}:$PATH"

    CONFIG_FILE="''${NIXOS_CONFIG_FILE:-/etc/nixos/configuration.nix}"
    FLAKE_FILE="''${NIXOS_FLAKE_FILE:-/etc/nixos/flake.nix}"

    if [ ! -f "$CONFIG_FILE" ]; then
      printf '\033[1;31m[x] Arquivo não encontrado: %s\033[0m\n' "$CONFIG_FILE" >&2
      printf '    Defina NIXOS_CONFIG_FILE=/caminho/para/configuration.nix se estiver em outro local.\n' >&2
      exit 1
    fi

    WORK_DIR="$(mktemp -d)"
    trap 'rm -rf "$WORK_DIR"' EXIT
    BACKUP_FILE="$WORK_DIR/configuration.nix.orig"
    cp -f "$CONFIG_FILE" "$BACKUP_FILE"
    CFG_TOOL="$WORK_DIR/cfg_tool.py"

    cat > "$CFG_TOOL" <<'PYEOF'
import re
import sys
import subprocess

G = "\033[1;32m"
R = "\033[1;31m"
C = "\033[1;36m"
Y = "\033[1;33m"
M = "\033[1;35m"
D = "\033[0;90m"
Z = "\033[0m"

def strip_line(line):
    out = []
    in_str = False
    i = 0
    while i < len(line):
        ch = line[i]
        if ch == "\\" and in_str:
            i += 2
            continue
        if ch == '"':
            in_str = not in_str
            i += 1
            continue
        if ch == "#" and not in_str:
            break
        if not in_str:
            out.append(ch)
        i += 1
    return "".join(out)

def parse_cfg(lines):
    in_cfg = False
    stack = []
    entries = {}
    servers = {}
    servidores_close_idx = None
    servidores_indent = "      "

    re_cfg_start = re.compile(r"^\s*cfg\s*=\s*\{\s*(?:#.*)?$")
    re_block_open = re.compile(r"^(\s*)([A-Za-z0-9_]+)\s*=\s*\{\s*(?:#.*)?$")
    re_kv = re.compile(r"^(\s*)([A-Za-z0-9_]+)(\s*=\s*)(true|false|\"[^\"]*\"|-?[0-9]+|\[[^\]]*\])(\s*;.*)$")

    for idx, raw in enumerate(lines):
        clean = strip_line(raw)
        if not in_cfg:
            if re_cfg_start.match(raw):
                in_cfg = True
                stack = ["cfg"]
            continue

        m_open = re_block_open.match(raw)
        if m_open:
            name = m_open.group(2)
            stack.append(name)
            if stack[:3] == ["cfg", "srcds", "servidores"] and len(stack) == 4:
                servers[name] = {}
            continue

        m_kv = re_kv.match(raw)
        if m_kv and len(stack) >= 1:
            key = m_kv.group(2)
            val = m_kv.group(4)
            rel_path = ".".join(stack[1:] + [key])
            entries[rel_path] = {
                "idx": idx,
                "prefix": m_kv.group(1) + m_kv.group(2) + m_kv.group(3),
                "val": val,
                "suffix": m_kv.group(5),
            }
            if stack[:3] == ["cfg", "srcds", "servidores"] and len(stack) == 4:
                srv_name = stack[3]
                servers.setdefault(srv_name, {})[key] = val

        opens = clean.count("{")
        closes = clean.count("}")
        for _ in range(closes - opens):
            if stack == ["cfg", "srcds", "servidores"]:
                servidores_close_idx = idx
                m_ind = re.match(r"^(\s*)", raw)
                if m_ind:
                    servidores_indent = m_ind.group(1)
            if stack:
                stack.pop()
            if not stack:
                in_cfg = False
                break

    return entries, servers, servidores_close_idx, servidores_indent

def unquote(v):
    if len(v) >= 2 and v.startswith('"') and v.endswith('"'):
        return v[1:-1]
    return v

def badge(v):
    if v == "true":
        return f"{G}[ON] {Z}"
    if v == "false":
        return f"{R}[OFF]{Z}"
    return f"{C}{v}{Z}"

def get_val(entries, path, default="?"):
    if path in entries:
        return entries[path]["val"]
    return default

def cmd_get(filepath, path):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()
    entries, _, _, _ = parse_cfg(lines)
    print(unquote(get_val(entries, path, "")))

def cmd_toggle(filepath, paths):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()
    entries, _, _, _ = parse_cfg(lines)
    for p in paths:
        if p in entries:
            cur = entries[p]["val"]
            new_v = "false" if cur == "true" else "true"
            idx = entries[p]["idx"]
            nl = "\n" if lines[idx].endswith("\n") else ""
            lines[idx] = entries[p]["prefix"] + new_v + entries[p]["suffix"].rstrip("\r\n") + nl
    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(lines)

def cmd_set(filepath, pairs):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()
    entries, _, _, _ = parse_cfg(lines)
    for pair in pairs:
        if "=" not in pair:
            continue
        p, new_raw = pair.split("=", 1)
        if p in entries:
            old_v = entries[p]["val"]
            if old_v.startswith('"') and not new_raw.startswith('"'):
                escaped = new_raw.replace('\\', '\\\\').replace('"', '\\"')
                new_v = f'"{escaped}"'
            else:
                new_v = new_raw
            idx = entries[p]["idx"]
            nl = "\n" if lines[idx].endswith("\n") else ""
            lines[idx] = entries[p]["prefix"] + new_v + entries[p]["suffix"].rstrip("\r\n") + nl
    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(lines)

def cmd_add_server(filepath, name, app_id, exec_bin, exec_args, port):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()
    _, servers, close_idx, indent = parse_cfg(lines)
    if name in servers:
        sys.exit(f"Servidor '{name}' já existe em cfg.srcds.servidores.")
    if close_idx is None:
        sys.exit("Bloco srcds.servidores não encontrado.")
    sub = indent + "  "
    kv = sub + "  "
    block = (
        f"\n"
        f"{sub}{name} = {{\n"
        f"{kv}enable    = false;\n"
        f"{kv}autoStart = false;\n"
        f"{kv}appId     = {app_id};\n"
        f"{kv}execBin   = \"{exec_bin}\";\n"
        f"{kv}execArgs  = \"{exec_args}\";\n"
        f"{kv}portasUDP = [ {port} ];\n"
        f"{kv}portasTCP = [ {port} ];\n"
        f"{sub}}};\n"
    )
    lines.insert(close_idx, block)
    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(lines)

def cmd_summary(filepath, backup_path):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()
    entries, servers, _, _ = parse_cfg(lines)
    v = lambda p: get_val(entries, p, "?")

    diff_proc = subprocess.run(
        ["diff", "-u", "--color=always", backup_path, filepath],
        capture_output=True, text=True
    )
    has_changes = diff_proc.returncode != 0

    print(f"{C}===================================================================={Z}")
    if has_changes:
        print(f" {Y}[*] HÁ ALTERAÇÕES PENDENTES (selecione 'Aplicar Agora (nrs)'){Z}")
    else:
        print(f" {G}[✓] Configuração sincronizada (sem alterações não salvas){Z}")
    print(f"{C}===================================================================={Z}\n")

    print(f"{Y}>> Identidade & Sistema{Z}")
    print(f"  Usuário / Host : {C}{unquote(v('usuario'))}@{unquote(v('hostname'))}{Z}  |  Shell: {C}{unquote(v('shellPadrao'))}{Z}")
    print(f"  Git            : {C}{unquote(v('gitUser'))} <{unquote(v('gitEmail'))}>{Z}")
    print(f"  Home Manager   : {badge(v('usarHomeManager'))}  |  Locale Extra PT: {badge(v('localeExtraPt'))}")
    print(f"  Kernel / CPU   : {C}{unquote(v('kernel'))}{Z} / {C}{unquote(v('cpuGovernor'))}{Z}  |  Nvidia Open: {badge(v('nvidiaOpen'))}")
    print(f"  ZRAM / TRIM    : {badge(v('zramEnable'))} ({v('zramPercent')}%)  |  TRIM: {badge(v('ssdTrim'))}  |  Bluetooth: {badge(v('bluetooth'))}\n")

    print(f"{Y}>> Ambientes Gráficos & 2º SSD{Z}")
    print(f"  Plasma 6: {badge(v('desktop.plasma'))}  |  Hyprland: {badge(v('desktop.hyprland'))}  |  i3wm: {badge(v('desktop.i3'))}  |  AutoLogin: {badge(v('desktop.autoLogin'))}")
    print(f"  2º SSD  : {badge(v('discoSecundario.enable'))}  ->  {C}{unquote(v('discoSecundario.pontoMontagem'))}{Z} ({unquote(v('discoSecundario.fsType'))} | UUID: {unquote(v('discoSecundario.uuid'))})\n")

    print(f"{Y}>> Módulos do Sistema{Z}")
    print(f"  Gaming   : {badge(v('modulos.gaming'))}   Dev      : {badge(v('modulos.dev'))}   Docker   : {badge(v('modulos.docker'))}")
    print(f"  VMware   : {badge(v('modulos.vmware'))}   Flatpak  : {badge(v('modulos.flatpak'))}   AppImage : {badge(v('modulos.appimage'))}")
    print(f"  I2P      : {badge(v('modulos.i2p'))}   SSH      : {badge(v('modulos.ssh'))}   EarlyOOM : {badge(v('modulos.earlyOom'))}\n")

    print(f"{Y}>> Estúdio Source Engine{Z}")
    print(f"  Ativo    : {badge(v('criacaoSource.enable'))}   Modelos  : {badge(v('criacaoSource.modelagem'))}   Texturas : {badge(v('criacaoSource.texturas'))}")
    print(f"  Mapas    : {badge(v('criacaoSource.mapeamento'))}   GMod/GLua: {badge(v('criacaoSource.garrysmod'))}   Source 2 : {badge(v('criacaoSource.source2'))}")
    print(f"  Áudio    : {badge(v('criacaoSource.audio'))}   Atalhos  : {badge(v('criacaoSource.atalhosMenu'))}   Wine     : {C}{unquote(v('criacaoSource.wineVariante'))}{Z}\n")

    print(f"{Y}>> Servidores Multi-SRCDS ({unquote(v('srcds.localArmazenamento'))}){Z}")
    for sname, sdata in servers.items():
        sen = badge(sdata.get("enable", "false"))
        sauto = badge(sdata.get("autoStart", "false"))
        sapp = sdata.get("appId", "?")
        sport = sdata.get("portasUDP", "[]")
        print(f"  • {C}{sname:<8}{Z} Ativo: {sen} | Boot: {sauto} | AppID: {sapp} | UDP: {sport}")

    if has_changes:
        print(f"\n{Y}>> Diff das Alterações Nesta Sessão:{Z}")
        for dline in diff_proc.stdout.splitlines()[2:35]:
            print("  " + dline)

def cmd_menu(filepath, section):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()
    entries, servers, _, _ = parse_cfg(lines)
    v = lambda p: get_val(entries, p, "?")
    b = lambda p: badge(v(p))
    u = lambda p: f"{C}{unquote(v(p))}{Z}"

    items = []
    if section == "modulos":
        specs = [
            ("modulos.gaming",     "Gaming (Steam, Proton-GE, Gamemode, Lutris, Heroic, MangoHud)"),
            ("modulos.dev",        "Desenvolvimento (VSCode, Neovim, Python, Node, Go, Rust, C/C++, Lazygit)"),
            ("modulos.docker",     "Docker (Containers + Docker Compose)"),
            ("modulos.vmware",     "VMware Workstation Pro + Módulos de Kernel"),
            ("modulos.flatpak",    "Flatpak + Repositório Flathub Automático"),
            ("modulos.appimage",   "AppImage (Execução direta com 2 cliques via binfmt)"),
            ("modulos.i2p",        "Roteador I2P (Puxado do canal Unstable via overlay)"),
            ("modulos.ssh",        "Servidor OpenSSH Blindado (Apenas chave pública, sem root)"),
            ("modulos.impressora", "Suporte a Impressoras (CUPS)"),
            ("modulos.earlyOom",   "EarlyOOM (Proteção contra congelamento por falta de RAM)"),
        ]
        for path, desc in specs:
            items.append(f"TOGGLE:{path}\t{b(path)}  {desc}")
        items.append("VOLTAR\t<< Voltar ao Menu Principal")

    elif section == "source":
        specs = [
            ("criacaoSource.enable",      "Estúdio Source Engine Completo (Mestre)"),
            ("criacaoSource.modelagem",   "Modelagem 3D (F3D — visualizador 3D rápido; Blender via Steam)"),
            ("criacaoSource.texturas",    "Texturas & 2D (MareTF, VTFEdit, GIMP, Krita, Inkscape, Upscayl)"),
            ("criacaoSource.audio",       "Áudio para Source (Audacity + SoX PCM 16-bit 44.1kHz)"),
            ("criacaoSource.mapeamento",  "Mapeamento (Hammer++, CompilePal, BSPSource, Lumper)"),
            ("criacaoSource.garrysmod",   "Garry's Mod / GLua (lua-language-server, StyLua, LuaJIT, fastgmad, glualint)"),
            ("criacaoSource.source2",     "Source 2 (Source 2 Viewer GUI & CLI — CS2, Deadlock, Dota 2)"),
            ("criacaoSource.atalhosMenu", "Atalhos no Menu de Aplicativos (Plasma / Hyprland / wofi)"),
        ]
        for path, desc in specs:
            items.append(f"TOGGLE:{path}\t{b(path)}  {desc}")
        items.append(f"CHOICE:criacaoSource.wineVariante:wow64,classico\t{u('criacaoSource.wineVariante')}  Variante do Wine do Prefixo de Modding (wow64 ou classico)")
        items.append("ACTION:st-setup\t[Ação] Preparar Prefixo Wine agora (source-tools setup)")
        items.append("ACTION:st-baixar\t[Ação] Baixar/Atualizar ferramentas do GitHub (source-tools baixar)")
        items.append("ACTION:st-hammerpp\t[Ação] Escolher e baixar build do Hammer++ (source-tools hammerpp)")
        items.append("VOLTAR\t<< Voltar ao Menu Principal")

    elif section == "hardware":
        items.append(f"CHOICE:kernel:stable,zen,latest\t{u('kernel')}  Kernel do Linux (stable = seguro p/ VMware/Nvidia | zen = jogos | latest)")
        items.append(f"TOGGLE:nvidiaOpen\t{b('nvidiaOpen')}  Módulo Nvidia Open-Source (true recomendado p/ RTX série 20/30/40/50)")
        items.append(f"CHOICE:cpuGovernor:schedutil,performance\t{u('cpuGovernor')}  Governador de Frequência da CPU (schedutil ou performance)")
        items.append(f"TOGGLE:ssdTrim\t{b('ssdTrim')}  TRIM Automático Semanal para SSD/NVMe (fstrim)")
        items.append(f"TOGGLE:zramEnable\t{b('zramEnable')}  Swap Compactada na RAM (ZRAM com algoritmo zstd)")
        items.append(f"CHOICE:zramPercent:25,50,75,100\t{C}{v('zramPercent')}%{Z}   Porcentagem da RAM dedicada ao ZRAM")
        items.append(f"TOGGLE:bluetooth\t{b('bluetooth')}  Bluetooth + Gerenciador Blueman")
        items.append("VOLTAR\t<< Voltar ao Menu Principal")

    elif section == "desktop":
        items.append(f"TOGGLE:desktop.plasma\t{b('desktop.plasma')}  KDE Plasma 6 (Wayland)")
        items.append(f"TOGGLE:desktop.hyprland\t{b('desktop.hyprland')}  Hyprland (Wayland Tiling WM + Waybar, Wofi, Mako, Hyprpaper)")
        items.append(f"TOGGLE:desktop.i3\t{b('desktop.i3')}  i3wm (X11 Tiling WM)")
        items.append(f"TOGGLE:desktop.autoLogin\t{b('desktop.autoLogin')}  Login Automático sem pedir senha ao ligar o PC")
        items.append("VOLTAR\t<< Voltar ao Menu Principal")

    elif section == "disco":
        items.append("WIZARD:ssd\t[Assistente Automático] Escolher partição real (lsblk) e configurar tudo sozinho")
        items.append(f"TOGGLE:discoSecundario.enable\t{b('discoSecundario.enable')}  Montar 2º SSD / NVMe automaticamente no boot")
        items.append(f"INPUT:discoSecundario.uuid\t{u('discoSecundario.uuid')}  UUID da Partição")
        items.append(f"CHOICE:discoSecundario.fsType:ext4,btrfs,ntfs3\t{u('discoSecundario.fsType')}  Sistema de Arquivos (ext4, btrfs ou ntfs3)")
        items.append(f"INPUT:discoSecundario.pontoMontagem\t{u('discoSecundario.pontoMontagem')}  Ponto de Montagem (ex: /mnt/ssd)")
        items.append("VOLTAR\t<< Voltar ao Menu Principal")

    elif section == "seguranca":
        items.append(f"TOGGLE:seguranca.dockerLocalOnly\t{b('seguranca.dockerLocalOnly')}  Docker Local-Only (Impede que containers exponham portas na LAN)")
        items.append(f"TOGGLE:seguranca.dockerRootless\t{b('seguranca.dockerRootless')}  Docker Rootless (Executa daemon Docker sem root)")
        items.append(f"TOGGLE:seguranca.dnsCriptografado\t{b('seguranca.dnsCriptografado')}  DNS Criptografado (DNS-over-TLS + DNSSEC via Quad9/Cloudflare)")
        items.append(f"TOGGLE:seguranca.sudoPedeSenha\t{b('seguranca.sudoPedeSenha')}  Sudo exige senha (false = roda sudo sem digitar senha)")
        items.append("VOLTAR\t<< Voltar ao Menu Principal")

    elif section == "identidade":
        items.append(f"CHOICE:shellPadrao:fish,zsh,bash\t{u('shellPadrao')}  Shell Interativo Padrão (fish, zsh ou bash)")
        items.append(f"TOGGLE:usarHomeManager\t{b('usarHomeManager')}  Usar Home Manager Embutido")
        items.append(f"INPUT:gitUser\t{u('gitUser')}  Nome nos Commits do Git (Home Manager)")
        items.append(f"INPUT:gitEmail\t{u('gitEmail')}  E-mail nos Commits do Git (Home Manager)")
        items.append(f"INPUT:hostname\t{u('hostname')}  Hostname da Máquina (se mudar, atualize no flake.nix)")
        items.append(f"TOGGLE:localeExtraPt\t{b('localeExtraPt')}  Datas, Moeda e Medidas em Português (pt_BR.UTF-8)")
        items.append(f"CHOICE:tecladoConsole:br-abnt2,us\t{u('tecladoConsole')}  Mapa de Teclado do Console TTY (br-abnt2 ou us)")
        items.append(f"CHOICE:tecladoGrafico:br,us\t{u('tecladoGrafico')}  Layout de Teclado Gráfico Wayland/X11 (br ou us)")
        items.append(f"TOGGLE:manutencao.gcAutomatico\t{b('manutencao.gcAutomatico')}  Limpeza Automática Semanal (Garbage Collector)")
        items.append(f"CHOICE:manutencao.gcManterDias:7d,14d,30d,60d\t{u('manutencao.gcManterDias')}  Período mantido pelo Garbage Collector")
        items.append("VOLTAR\t<< Voltar ao Menu Principal")

    elif section == "srcds":
        items.append(f"CHOICE:srcds.localArmazenamento:home,custom\t{u('srcds.localArmazenamento')}  Onde salvar servidores (home = ~/srcds | custom = caminhoCustom)")
        items.append(f"INPUT:srcds.caminhoCustom\t{u('srcds.caminhoCustom')}  Caminho Customizado (usado quando localArmazenamento = custom)")
        items.append("ADD_SRV\t+ [Assistente] Adicionar um Novo Servidor Dedicado (TF2, CS:S, L4D2, HL2DM...)")
        for sname, sdata in servers.items():
            sen = badge(sdata.get("enable", "false"))
            sauto = badge(sdata.get("autoStart", "false"))
            sapp = sdata.get("appId", "?")
            sport = sdata.get("portasUDP", "[]")
            items.append(f"SRV:{sname}\tServidor [{C}{sname}{Z}] — Ativo: {sen} | Boot: {sauto} | AppID: {sapp} | Portas: {sport}")
        items.append("VOLTAR\t<< Voltar ao Menu Principal")

    elif section.startswith("srv:"):
        sname = section.split(":", 1)[1]
        p_en = f"srcds.servidores.{sname}.enable"
        p_au = f"srcds.servidores.{sname}.autoStart"
        p_ar = f"srcds.servidores.{sname}.execArgs"
        p_ap = f"srcds.servidores.{sname}.appId"
        items.append(f"TOGGLE:{p_en}\t{b(p_en)}  Habilitar serviço systemd srcds-{sname} e abrir portas no Firewall")
        items.append(f"TOGGLE:{p_au}\t{b(p_au)}  Iniciar automaticamente junto com o boot do PC (autoStart)")
        items.append(f"INPUT:{p_ar}\t{u(p_ar)}  Argumentos de Inicialização (execArgs)")
        items.append(f"SRV_ACT:update:{sname}:{v(p_ap)}\t[SteamCMD] Baixar / Atualizar arquivos do servidor ({sname})")
        items.append(f"SRV_ACT:start:{sname}\t[Systemd] Iniciar servidor agora (sudo systemctl start srcds-{sname})")
        items.append(f"SRV_ACT:restart:{sname}\t[Systemd] Reiniciar servidor (sudo systemctl restart srcds-{sname})")
        items.append(f"SRV_ACT:stop:{sname}\t[Systemd] Parar servidor (sudo systemctl stop srcds-{sname})")
        items.append(f"SRV_ACT:logs:{sname}\t[Logs] Ver console/logs em tempo real (journalctl -u srcds-{sname} -f)")
        items.append("VOLTAR\t<< Voltar para Lista de Servidores")

    for it in items:
        print(it)

if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "get":
        cmd_get(sys.argv[2], sys.argv[3])
    elif cmd == "toggle":
        cmd_toggle(sys.argv[2], sys.argv[3:])
    elif cmd == "set":
        cmd_set(sys.argv[2], sys.argv[3:])
    elif cmd == "add-server":
        cmd_add_server(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7])
    elif cmd == "summary":
        cmd_summary(sys.argv[2], sys.argv[3])
    elif cmd == "menu":
        cmd_menu(sys.argv[2], sys.argv[3])
PYEOF

    rodar_cfg_write() {
      if [ -w "$CONFIG_FILE" ]; then
        python3 "$CFG_TOOL" "$@"
      else
        sudo python3 "$CFG_TOOL" "$@"
      fi
    }

    ler_cfg() {
      python3 "$CFG_TOOL" get "$CONFIG_FILE" "$1"
    }

    escolher_valor() {
      local caminho="$1" opcoes="$2" escolha
      escolha="$(printf '%s\n' "''${opcoes//,/$'\n'}" | fzf \
        --ansi --layout=reverse --height=45% --border=rounded \
        --prompt="Novo valor para $caminho > " \
        --header="Selecione com ENTER ou ESC para cancelar")" || return 0
      [ -n "$escolha" ] && rodar_cfg_write set "$CONFIG_FILE" "$caminho=$escolha"
    }

    digitar_valor() {
      local caminho="$1" atual novo
      atual="$(ler_cfg "$caminho")"
      clear
      printf '\033[1;36m==> Editar %s\033[0m\n' "$caminho"
      printf '    Valor atual: \033[1;33m%s\033[0m\n\n' "$atual"
      read -r -p "Digite o novo valor (ou ENTER vazio para cancelar): " novo
      if [ -n "$novo" ]; then
        rodar_cfg_write set "$CONFIG_FILE" "$caminho=$novo"
      fi
    }

    wizard_ssd() {
      local lista linha dev uuid fstype mnt
      lista="$(lsblk -rnpo NAME,SIZE,FSTYPE,UUID,MOUNTPOINT,LABEL 2>/dev/null | awk '$3 != "" && $4 != "" {printf "%-18s | %-7s | %-7s | UUID: %-36s | Montado: %s %s\n", $1, $2, $3, $4, ($5==""?"(não)":$5), $6}')"
      if [ -z "$lista" ]; then
        printf '\033[1;31mNenhuma partição com UUID encontrada via lsblk.\033[0m\n'
        read -r -p "Pressione ENTER para voltar..." _
        return 0
      fi
      linha="$(printf '%s\n' "$lista" | fzf \
        --ansi --layout=reverse --height=70% --border=rounded \
        --prompt="Escolha a partição do 2º SSD/NVMe > " \
        --header="Atenção: não escolha a partição raiz (/) nem a /boot! | ENTER seleciona | ESC cancela")" || return 0

      dev="$(awk '{print $1}' <<<"$linha")"
      fstype="$(lsblk -no FSTYPE "$dev" | head -n1 | tr -d '[:space:]')"
      uuid="$(lsblk -no UUID "$dev" | head -n1 | tr -d '[:space:]')"
      [ "$fstype" = "ntfs" ] && fstype="ntfs3"

      clear
      printf '\033[1;36m==> Configurando Partição %s\033[0m\n' "$dev"
      printf '    UUID detectado  : \033[1;32m%s\033[0m\n' "$uuid"
      printf '    Tipo detectado  : \033[1;32m%s\033[0m\n\n' "$fstype"
      read -r -p "Ponto de montagem [/mnt/ssd]: " mnt
      mnt="''${mnt:-/mnt/ssd}"

      rodar_cfg_write set "$CONFIG_FILE" \
        "discoSecundario.enable=true" \
        "discoSecundario.uuid=$uuid" \
        "discoSecundario.fsType=$fstype" \
        "discoSecundario.pontoMontagem=$mnt"
    }

    wizard_add_srv() {
      local preset nome appid bin args porta
      preset="$(cat <<'PRESETS' | fzf --ansi --layout=reverse --height=65% --border=rounded --prompt="Qual jogo deseja adicionar? > " --delimiter=$'\t' --with-nth=1
Team Fortress 2 (AppID 232250)	232250	srcds_run	-game tf -console +sv_pure 1 +map cp_badlands +maxplayers 24
Counter-Strike: Source (AppID 232330)	232330	srcds_run	-game cstrike -console +map de_dust2 +maxplayers 16
Left 4 Dead 2 (AppID 222860)	222860	srcds_run	-game left4dead2 -console +map c1m1_hotel
Half-Life 2: Deathmatch (AppID 232370)	232370	srcds_run	-game hl2mp -console +map dm_lockdown +maxplayers 16
Garry's Mod Extra (AppID 4020)	4020	srcds_run	-game garrysmod -console +gamemode sandbox +map gm_construct +maxplayers 16
Counter-Strike 2 Extra (AppID 730)	730	game/bin/linuxsteamrt64/cs2	-dedicated +map de_dust2 +game_type 0 +game_mode 1 -maxplayers 10
Personalizado (Digitar AppID manualmente)	CUSTOM	srcds_run	-console
PRESETS
)" || return 0

      IFS=$'\t' read -r _ appid bin args <<<"$preset"
      clear
      printf '\033[1;36m==> Novo Servidor Dedicado Source (Multi-SRCDS)\033[0m\n\n'
      read -r -p "Nome curto do servidor (sem espaços, ex: tf2, css, l4d2): " nome
      nome="''${nome//[^a-zA-Z0-9_]/}"
      [ -z "$nome" ] && return 0

      if [ "$appid" = "CUSTOM" ]; then
        read -r -p "AppID do Dedicated Server na Steam (ex: 232250): " appid
        read -r -p "Binário executável [srcds_run]: " bin
        bin="''${bin:-srcds_run}"
        read -r -p "Argumentos (execArgs): " args
      fi

      read -r -p "Porta UDP/TCP do servidor [27017]: " porta
      porta="''${porta:-27017}"
      args="$args -port $porta"

      rodar_cfg_write add-server "$CONFIG_FILE" "$nome" "$appid" "$bin" "$args" "$porta"
    }

    executar_acao_srv() {
      local acao="$1" nome="$2" appid="''${3:-}" base_modo base_dir srv_dir
      base_modo="$(ler_cfg srcds.localArmazenamento)"
      if [ "$base_modo" = "home" ]; then
        base_dir="/home/$(ler_cfg usuario)/srcds"
      else
        base_dir="$(ler_cfg srcds.caminhoCustom)"
      fi
      srv_dir="$base_dir/$nome"

      clear
      case "$acao" in
        update)
          printf '\033[1;36m==> Atualizando servidor %s (AppID %s) em %s...\033[0m\n\n' "$nome" "$appid" "$srv_dir"
          mkdir -p "$srv_dir"
          HOME="$base_dir" steamcmd +force_install_dir "$srv_dir" +login anonymous +app_update "$appid" validate +quit
          read -r -p $'\nConcluído! Pressione ENTER para voltar...' _
          ;;
        start|stop|restart)
          printf '\033[1;36m==> Executando: sudo systemctl %s srcds-%s\033[0m\n\n' "$acao" "$nome"
          sudo systemctl "$acao" "srcds-$nome" || true
          systemctl status "srcds-$nome" --no-pager || true
          read -r -p $'\nPressione ENTER para voltar...' _
          ;;
        logs)
          printf '\033[1;36m==> Logs de srcds-%s (Pressione Ctrl+C para sair dos logs)\033[0m\n\n' "$nome"
          journalctl -u "srcds-$nome" -f || true
          ;;
      esac
    }

    submenu() {
      local secao="$1" titulo="$2" selecionados linha tag resto caminho opcoes
      while true; do
        selecionados="$(python3 "$CFG_TOOL" menu "$CONFIG_FILE" "$secao" | fzf \
          --ansi \
          --multi \
          --layout=reverse \
          --height=95% \
          --border=rounded \
          --prompt="$titulo > " \
          --header="ENTER altera/abre | TAB marca vários [ON]/[OFF] de uma vez | ESC volta" \
          --delimiter=$'\t' \
          --with-nth=2 \
          --preview="python3 '$CFG_TOOL' summary '$CONFIG_FILE' '$BACKUP_FILE'" \
          --preview-window="right:58%:wrap")" || break

        # Se marcou múltiplos itens com TAB, aplica todos os TOGGLE de uma vez
        local toggles=()
        while IFS= read -r linha; do
          tag="''${linha%%$'\t'*}"
          if [[ "$tag" == TOGGLE:* ]]; then
            toggles+=("''${tag#TOGGLE:}")
          fi
        done <<<"$selecionados"

        if [ "''${#toggles[@]}" -gt 1 ]; then
          rodar_cfg_write toggle "$CONFIG_FILE" "''${toggles[@]}"
          continue
        fi

        linha="$(head -n1 <<<"$selecionados")"
        tag="''${linha%%$'\t'*}"
        case "$tag" in
          VOLTAR|"") break ;;
          TOGGLE:*)
            rodar_cfg_write toggle "$CONFIG_FILE" "''${tag#TOGGLE:}"
            ;;
          CHOICE:*)
            resto="''${tag#CHOICE:}"
            caminho="''${resto%%:*}"
            opcoes="''${resto#*:}"
            escolher_valor "$caminho" "$opcoes"
            ;;
          INPUT:*)
            digitar_valor "''${tag#INPUT:}"
            ;;
          WIZARD:ssd)
            wizard_ssd
            ;;
          ADD_SRV)
            wizard_add_srv
            ;;
          SRV:*)
            submenu "srv:''${tag#SRV:}" "Servidor ''${tag#SRV:}"
            ;;
          SRV_ACT:*)
            IFS=: read -r _ acao snome sappid <<<"$tag"
            executar_acao_srv "$acao" "$snome" "''${sappid:-}"
            ;;
          ACTION:st-setup)
            clear; source-tools setup || true; read -r -p $'\nPressione ENTER para voltar...' _ ;;
          ACTION:st-baixar)
            clear; source-tools baixar || true; read -r -p $'\nPressione ENTER para voltar...' _ ;;
          ACTION:st-hammerpp)
            clear; source-tools hammerpp || true; read -r -p $'\nPressione ENTER para voltar...' _ ;;
        esac
      done
    }

    MENU_PRINCIPAL="$(cat <<'EOF'
MODULOS	01. [Módulos do Sistema]     Gaming, Dev, Docker, VMware, Flatpak, AppImage, I2P, SSH...
SOURCE	02. [Estúdio Source Engine]  Crowbar, Blender, MareTF, Hammer++, Garry's Mod, Source 2...
HARDWARE	03. [Hardware & Kernel]      Kernel (stable/zen/latest), Nvidia Open, CPU, ZRAM, TRIM...
DESKTOP	04. [Ambientes Gráficos]     KDE Plasma 6, Hyprland, i3wm e AutoLogin
DISCO	05. [2º SSD / NVMe]          Assistente automático (lsblk) e montagem no boot
SRCDS	06. [Servidores Multi-SRCDS] Ligar/desligar, atualizar, criar novo servidor (GMod, CS2, TF2...)
SEGURANCA	07. [Segurança & Rede]       Docker Local-Only/Rootless, DNS Criptografado, Sudo
IDENTIDADE	08. [Identidade & Manutenção] Shell (fish/zsh/bash), Git, Idioma, Teclado e Garbage Collector
DIFF	09. [Ver Alterações (Diff)]  Inspecionar todas as mudanças feitas antes de aplicar
TESTAR	10. [Testar Config (nrt)]    Testar alterações agora sem gravar na lista de boot
APLICAR	11. [Aplicar Agora (nrs)]    Rodar sudo nixos-rebuild switch e ativar tudo!
DESFAZER	12. [Desfazer Alterações]    Restaurar configuration.nix para o estado inicial da sessão
EDITOR	13. [Editor Manual (nconf)]  Abrir /etc/nixos/configuration.nix completo no Neovim
GUIA	14. [Guia Interativo (guia)] Abrir o manual completo do sistema
SAIR	00. Sair do Painel
EOF
)"

    while true; do
      escolha="$(printf '%s\n' "$MENU_PRINCIPAL" | fzf \
        --ansi \
        --layout=reverse \
        --height=95% \
        --border=rounded \
        --prompt="Painel NixOS > " \
        --header="↑/↓ navega | ENTER abre categoria | Ao lado: Estado ao vivo do configuration.nix | ESC sai" \
        --delimiter=$'\t' \
        --with-nth=2 \
        --preview="python3 '$CFG_TOOL' summary '$CONFIG_FILE' '$BACKUP_FILE'" \
        --preview-window="right:58%:wrap")" || break

      id="''${escolha%%$'\t'*}"
      case "$id" in
        SAIR|"")    break ;;
        MODULOS)    submenu "modulos"    "01. Módulos do Sistema" ;;
        SOURCE)     submenu "source"     "02. Estúdio Source Engine" ;;
        HARDWARE)   submenu "hardware"   "03. Hardware, Kernel & Nvidia" ;;
        DESKTOP)    submenu "desktop"    "04. Ambientes Gráficos" ;;
        DISCO)      submenu "disco"      "05. Segundo SSD / NVMe" ;;
        SRCDS)      submenu "srcds"      "06. Servidores Dedicados Multi-SRCDS" ;;
        SEGURANCA)  submenu "seguranca"  "07. Segurança & Privacidade" ;;
        IDENTIDADE) submenu "identidade" "08. Identidade, Shell & Manutenção" ;;
        DIFF)
          if diff -u --color=always "$BACKUP_FILE" "$CONFIG_FILE" | less -R; then
            printf '\nNenhuma alteração pendente.\n'
            sleep 1
          fi
          ;;
        TESTAR)
          clear
          host_atual="$(ler_cfg hostname)"
          printf '\033[1;36m==> Testando configuração (sudo nixos-rebuild test --flake /etc/nixos#%s)...\033[0m\n\n' "$host_atual"
          sudo nixos-rebuild test --flake "/etc/nixos#$host_atual" || true
          read -r -p $'\nPressione ENTER para voltar ao painel...' _
          ;;
        APLICAR)
          clear
          host_atual="$(ler_cfg hostname)"
          printf '\033[1;32m==> Aplicando configuração (sudo nixos-rebuild switch --flake /etc/nixos#%s)...\033[0m\n\n' "$host_atual"
          if sudo nixos-rebuild switch --flake "/etc/nixos#$host_atual"; then
            cp -f "$CONFIG_FILE" "$BACKUP_FILE"
            printf '\n\033[1;32m[✓] Sistema atualizado com sucesso!\033[0m\n'
          fi
          read -r -p $'\nPressione ENTER para voltar ao painel...' _
          ;;
        DESFAZER)
          if [ -w "$CONFIG_FILE" ]; then
            cp -f "$BACKUP_FILE" "$CONFIG_FILE"
          else
            sudo cp -f "$BACKUP_FILE" "$CONFIG_FILE"
          fi
          ;;
        EDITOR)
          if [ -w "$CONFIG_FILE" ]; then nvim "$CONFIG_FILE"; else sudo nvim "$CONFIG_FILE"; fi
          ;;
        GUIA)
          nixos-guia || true
          ;;
      esac
    done
  '';

  moduloHomeManager = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      users.${cfg.usuario} = { pkgs, ... }: {
        home.stateVersion = cfg.stateVersion;

        # Pacotes exclusivos do usuário
        home.packages = with pkgs; [
          # Exemplo de pacote via Flake externo:
          # inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        # Git configurado declarativamente (sintaxe atual do Home Manager)
        programs.git = {
          enable = true;
          settings = {
            user.name = cfg.gitUser;
            user.email = cfg.gitEmail;
            init.defaultBranch = "main";
            pull.rebase = false;
          };
        };

        # Fish gerenciado pelo HM (necessário para a integração do Starship)
        programs.fish.enable = true;

        # Prompt moderno Starship no Fish
        programs.starship = {
          enable = true;
          enableFishIntegration = true;
        };

        xdg.userDirs = {
          enable = true;
          createDirectories = true;
        };
      };
    };
  };
in

{
  imports = [
    ./hardware-configuration.nix
  ] ++ lib.optional hmDisponivel moduloHomeManager;

  # ==========================================================================
  # 1. SISTEMA BASE, KERNEL, PERFORMANCE E SEGURANÇA DE KERNEL
  # ==========================================================================
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 15;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = kernelMap.${cfg.kernel};

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "kernel.split_lock_mitigate" = 0;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
  };

  powerManagement.cpuFreqGovernor = cfg.cpuGovernor;
  services.fstrim.enable = cfg.ssdTrim;

  zramSwap = {
    enable = cfg.zramEnable;
    memoryPercent = cfg.zramPercent;
    algorithm = "zstd";
  };

  services.earlyoom.enable = cfg.modulos.earlyOom;

  hardware.bluetooth = lib.mkIf cfg.bluetooth {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = cfg.bluetooth;

  networking.hostName = cfg.hostname;
  time.timeZone = cfg.timezone;
  i18n.defaultLocale = cfg.locale;

  i18n.extraLocaleSettings = lib.mkIf cfg.localeExtraPt {
    LC_ADDRESS        = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT    = "pt_BR.UTF-8";
    LC_MONETARY       = "pt_BR.UTF-8";
    LC_NAME           = "pt_BR.UTF-8";
    LC_NUMERIC        = "pt_BR.UTF-8";
    LC_PAPER          = "pt_BR.UTF-8";
    LC_TELEPHONE      = "pt_BR.UTF-8";
    LC_TIME           = "pt_BR.UTF-8";
  };

  console.keyMap = cfg.tecladoConsole;
  nixpkgs.config.allowUnfree = true;

  # Faz o módulo services.i2p puxar o pacote i2p direto do canal unstable
  nixpkgs.overlays = [
    (final: prev: {
      i2p = pkgsUnstable.i2p;
    })
  ];

  fileSystems.${cfg.discoSecundario.pontoMontagem} = lib.mkIf cfg.discoSecundario.enable {
    device = "/dev/disk/by-uuid/${cfg.discoSecundario.uuid}";
    fsType = cfg.discoSecundario.fsType;
    options = [
      "defaults"
      "nofail"
    ] ++ lib.optionals (cfg.discoSecundario.fsType == "ntfs3") [
      "uid=1000"
      "gid=100"
      "rw"
      "umask=000"
    ];
  };

  # ==========================================================================
  # 2. REDE, FIREWALL, DNS E SSH BLINDADO
  # ==========================================================================
  networking.networkmanager = {
    enable = true;
    dns = if cfg.seguranca.dnsCriptografado then "systemd-resolved" else "default";
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = lib.concatLists (lib.mapAttrsToList (_: srv: srv.portasUDP) servidoresAtivos);
    allowedTCPPorts = lib.concatLists (lib.mapAttrsToList (_: srv: srv.portasTCP) servidoresAtivos);
  };

  services.resolved = lib.mkIf cfg.seguranca.dnsCriptografado {
    enable = true;
    settings.Resolve = {
      DNSSEC      = "true";
      DNSOverTLS  = "true";
      Domains     = [ "~." ];
      FallbackDNS = [ "9.9.9.9#dns.quad9.net" "1.1.1.1#cloudflare-dns.com" ];
    };
  };

  services.i2p.enable = cfg.modulos.i2p;

  services.printing.enable = cfg.modulos.impressora;

  services.openssh = lib.mkIf cfg.modulos.ssh {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };

  # ==========================================================================
  # 3. NVIDIA E GRÁFICOS
  # ==========================================================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open = cfg.nvidiaOpen;
    nvidiaSettings = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };

  # ==========================================================================
  # 4. AMBIENTES GRÁFICOS E PORTALS (Wayland / X11)
  # ==========================================================================
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = cfg.seguranca.sudoPedeSenha;

  # Bloco único do X11 (driver Nvidia, teclado e i3)
  services.xserver = {
    enable = lib.mkIf cfg.desktop.i3 true;
    videoDrivers = [ "nvidia" ];
    xkb.layout = cfg.tecladoGrafico;
    windowManager.i3.enable = cfg.desktop.i3;
  };

  # No NixOS 25.11/26.05+, todos os Display Managers ficam em services.displayManager
  services.displayManager.lightdm.enable =
    lib.mkIf (cfg.desktop.i3 && !cfg.desktop.plasma && !cfg.desktop.hyprland) true;

  services.displayManager.sddm = lib.mkIf (cfg.desktop.plasma || cfg.desktop.hyprland) {
    enable = true;
    wayland.enable = true;
  };

  services.displayManager.autoLogin = lib.mkIf cfg.desktop.autoLogin {
    enable = true;
    user = cfg.usuario;
  };

  services.desktopManager.plasma6.enable = cfg.desktop.plasma;

  programs.hyprland = lib.mkIf cfg.desktop.hyprland {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = lib.mkMerge [
    (lib.mkIf cfg.desktop.hyprland {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
    })
    (lib.mkIf cs.enable {
      SOURCE_TOOLS_DIR  = ferramentasDir;
      SOURCE_WINEPREFIX = prefixoWine;
    })
  ];

  # Os módulos do Plasma e do Hyprland já registram seus próprios portals.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ==========================================================================
  # 5. ÁUDIO (PipeWire)
  # ==========================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ==========================================================================
  # 6. USUÁRIO, SHELL E SUPER ALIASES (Flake + Multi-SRCDS + Source Tools)
  # ==========================================================================
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting ""
    '';
  };

  programs.zsh.enable = cfg.shellPadrao == "zsh";

  programs.bash.interactiveShellInit = lib.mkIf (cfg.shellPadrao == "fish") ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';

  users.users.${cfg.usuario} = {
    isNormalUser = true;
    description = cfg.usuario;
    shell = if cfg.shellPadrao == "zsh" then pkgs.zsh else pkgs.bashInteractive;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ]
    ++ lib.optional cfg.modulos.gaming "gamemode"
    ++ lib.optional (cfg.modulos.docker && !cfg.seguranca.dockerRootless) "docker";
  };

  environment.shellAliases = {
    # >> Painel de Controle TUI & Guia Interativo <<
    painel     = "nixos-painel";
    configurar = "nixos-painel";
    ntui       = "nixos-painel";
    guia       = "nixos-guia";
    ajuda      = "nixos-guia";
    manual     = "nixos-guia";

    # >> Gerenciamento do NixOS e Flakes <<
    nrs    = "sudo nixos-rebuild switch --flake /etc/nixos#${cfg.hostname}";
    nrt    = "sudo nixos-rebuild test --flake /etc/nixos#${cfg.hostname}";
    nroll  = "sudo nixos-rebuild switch --rollback";
    nconf  = "sudo nvim /etc/nixos/configuration.nix";
    nflake = "sudo nvim /etc/nixos/flake.nix";
    nup    = "sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#${cfg.hostname}";
    ngc    = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
    nopt   = "sudo nix-store --optimise";
    ngen   = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";

    # >> Monitoramento, Segurança e Rede <<
    top        = "btop";
    gpu        = "nvtop";
    ports      = "sudo ss -tulanp";
    myip       = "curl -s ifconfig.me && echo";
    espaco     = "df -h -x tmpfs -x devtmpfs";
    limpar-ram = "sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'";
    erros-boot = "journalctl -p 3 -xb";

    # >> Git & Docker <<
    lg    = "lazygit";
    gs    = "git status -sb";
    ga    = "git add .";
    gc    = "git commit -m";
    gp    = "git push";
    dps   = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'";
    dcu   = "docker compose up -d";
    dcd   = "docker compose down";
    dlogs = "docker compose logs -f";
  }
  // aliasesSrcds
  // lib.optionalAttrs cs.enable {
    # >> Estúdio Source <<
    st       = "source-tools";
    crowbar  = "source-tools crowbar";
    hammer   = "source-tools hammer";
    s2v      = "source-tools s2v";
    sp       = "cd '${projetosDir}'";
    sp-tools = "cd '${ferramentasDir}'";
  };

  # ==========================================================================
  # 7. HOME MANAGER EMBUTIDO (Gerencia Dotfiles e Apps do Usuário)
  # ==========================================================================
  #  Definido em "moduloHomeManager" (bloco let acima) e importado via imports
  #  quando usarHomeManager = true e o módulo home-manager está presente no flake.

  # ==========================================================================
  # 8. PACOTES DO SISTEMA (3 Canais: Stable, Unstable e Flakes)
  # ==========================================================================
  environment.systemPackages = (with pkgs; [
    wget
    curl
    git
    htop
    btop
    tree
    unzip
    p7zip
    file
    killall
    pciutils
    usbutils
    fastfetch
    kitty
    nvtopPackages.nvidia

    fishPlugins.done
    fishPlugins.fzf-fish
    fzf

    brave
    firefox-bin
    signal-desktop
    kdePackages.kleopatra
    tor-browser
    pkgsUnstable.proton-vpn
    filezilla
    qbittorrent-enhanced

    yt-dlp
    ffmpeg-full
    obs-studio

    steamcmd
    steam-run
    guiaInterativo
    painelInterativo
  ])
  ++ lib.optionals cfg.modulos.gaming (with pkgs; [
    mangohud
    protonup-qt
    lutris
    heroic
    wineWow64Packages.stable
    winetricks
    discord
    xonotic
    r2modman
  ])
  ++ lib.optionals cfg.modulos.dev (with pkgs; [
    vscode
    neovim
    python3
    nodejs_24
    go
    rustup
    gcc
    gnumake
    cmake
    pkg-config
    jq
    ripgrep
    fd
    lazygit
    postman
  ])
  ++ lib.optionals cfg.desktop.hyprland (with pkgs; [
    alsa-utils
    wofi
    waybar
    mako
    hyprpaper
    wl-clipboard
    brightnessctl
    nixos-artwork.wallpapers.nineish-dark-gray
    kdePackages.polkit-kde-agent-1
    grim
    slurp
  ])
  ++ pacotesCriacao;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ] ++ lib.optional cs.enable corefonts;   # Arial/Verdana etc. (fontes de HUD/VGUI e Hammer)

  # ==========================================================================
  # 9. GAMING E EXECUÇÃO DE BINÁRIOS EXTERNOS
  # ==========================================================================
  programs.steam = lib.mkIf cfg.modulos.gaming {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = (servidoresAtivos != {});
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamemode = lib.mkIf cfg.modulos.gaming {
    enable = true;
    settings.general.inhibit_screensaver = 0;
  };

  programs.appimage = lib.mkIf cfg.modulos.appimage {
    enable = true;
    binfmt = true;
  };

  # Bibliotecas para binários pré-compilados (MareTF, Lumper, Source2Viewer-CLI,
  # gmad/studiomdl nativos, SourceMod spcomp, etc.)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      zstd
      fuse3
      icu
      nss
      openssl
      curl
      expat
      SDL2
      libGL
      fontconfig
      freetype
      libxkbcommon
      glib
      dbus
    ];
  };

  # ==========================================================================
  # 10. VIRTUALIZAÇÃO (Docker Blindado & VMware)
  # ==========================================================================
  virtualisation.docker = lib.mkIf cfg.modulos.docker (
    if cfg.seguranca.dockerRootless then {
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    } else {
      enable = true;
      enableOnBoot = true;
      daemon.settings = {
        live-restore = true;
      } // lib.optionalAttrs cfg.seguranca.dockerLocalOnly {
        ip = "127.0.0.1";
      };
    }
  );

  virtualisation.vmware.host.enable = cfg.modulos.vmware;

  # ==========================================================================
  # 11. FLATPAK
  # ==========================================================================
  services.flatpak.enable = cfg.modulos.flatpak;

  # ==========================================================================
  # 12. GERADOR MULTI-SRCDS + PASTAS DO ESTÚDIO SOURCE
  # ==========================================================================
  systemd.tmpfiles.rules =
    [ "d ${srcdsBaseDir} 0755 ${cfg.usuario} users -" ]
    ++ (lib.mapAttrsToList (nome: srv:
      "d ${dirDoServidor nome srv} 0755 ${cfg.usuario} users -"
    ) cfg.srcds.servidores)
    ++ lib.optional cfg.discoSecundario.enable
      "d ${cfg.discoSecundario.pontoMontagem} 0755 ${cfg.usuario} users -"
    ++ lib.optionals cs.enable (map (d: "d ${d} 0755 ${cfg.usuario} users -") (
      [ ferramentasDir projetosDir ]
      ++ map (sub: "${projetosDir}/${sub}") [
        "modelos"        # .blend, .smd/.dmx, .qc
        "materiais"      # .vtf/.vmt e fontes PSD/PNG
        "mapas"          # .vmf e compilados .bsp
        "sons"           # .wav (PCM 16-bit 44.1kHz)
        "addons"         # addons GMod (estrutura lua/ materials/ models/ ...)
        "decompilados"   # saídas do Crowbar/BSPSource/Source2Viewer
      ]
    ));

  # Serviços: um srcds-<nome> por servidor + repositório Flathub
  systemd.services =
    (lib.mapAttrs' (nome: srv:
      let
        workDir = dirDoServidor nome srv;
      in
      lib.nameValuePair "srcds-${nome}" {
        description = "Servidor Dedicado Source (${nome})";
        enable = srv.enable;
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = lib.optional srv.autoStart "multi-user.target";

        unitConfig.RequiresMountsFor = [ workDir ];

        serviceConfig = {
          Type = "simple";
          User = cfg.usuario;
          Group = "users";
          WorkingDirectory = workDir;
          # GLIBC_TUNABLES permite que binários 32-bit/legados da Source 1 (ex: gmod/srcds_run)
          # carreguem .so com execstack no Glibc 2.42+ (NixOS 26.05) sem erro de permissão.
          Environment = [
            "HOME=${srcdsBaseDir}"
            "GLIBC_TUNABLES=glibc.rtld.execstack=2"
          ];
          ExecStart = "${pkgs.steam-run}/bin/steam-run ${workDir}/${srv.execBin} ${srv.execArgs}";
          Restart = "on-failure";
          RestartSec = "10s";

          # --- Sandboxing contra RCE ---
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = "tmpfs";
          BindPaths = [ srcdsBaseDir workDir ];
          InaccessiblePaths = [ "-/run/docker.sock" "-/var/run/docker.sock" ];
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictSUIDSGID = true;
        };
      }
    ) cfg.srcds.servidores)
    // lib.optionalAttrs cfg.modulos.flatpak {
      flatpak-add-flathub-repo = {
        description = "Garante o repositório Flathub configurado";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        '';
        serviceConfig.Type = "oneshot";
      };
    };

  # ==========================================================================
  # 13. MANUTENÇÃO E HARDENING DO NIX STORE
  # ==========================================================================
  nix.gc = {
    automatic = cfg.manutencao.gcAutomatico;
    dates = "weekly";
    options = "--delete-older-than ${cfg.manutencao.gcManterDias}";
  };

  nix.optimise.automatic = true;
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    allowed-users = [ "@wheel" ];
  };

  system.stateVersion = cfg.stateVersion;
}

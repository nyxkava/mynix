# ============================================================================
#  configuration.nix — Nvidia | Gaming + Dev | Flakes & HM Ready | Multi-SRCDS
# ============================================================================
#  COMO USAR (Modo Clássico ou Modo Flake):
#    - Com Flakes: sudo nixos-rebuild switch --flake /etc/nixos#nixos (alias: nrs)
#    - Sem Flakes: sudo nixos-rebuild switch
# ============================================================================

{ config, pkgs, lib, inputs ? {}, unstable ? null, ... }:

let
  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                      PAINEL DE CONTROLE RÁPIDO                         ║
  # ║         Altere todo o comportamento e segurança do sistema aqui        ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  cfg = {
    # --- 1. Identidade, Shell e Regionalização ---
    usuario        = "nap";
    gitUser        = "nap";                 # Usado pelo Home Manager para configurar o Git
    gitEmail       = "seu-email@exemplo.com";
    hostname       = "nixos";
    shellPadrao    = "fish";                # "fish" (via wrapper POSIX seguro), "zsh" ou "bash"
    timezone       = "America/Sao_Paulo";
    locale         = "en_US.UTF-8";
    localeExtraPt  = false;                 # true = datas, moeda e medidas em pt_BR
    tecladoConsole = "br-abnt2";            # "br-abnt2" ou "us"
    tecladoGrafico = "br";                  # "br" ou "us"
    stateVersion   = "26.05";               # NÃO mude após a instalação inicial

    # --- 2. Home Manager (Gerencia configs da sua $HOME declarativamente) ---
    # Se você estiver usando o flake.nix acima, deixe true!
    # Se estiver rodando sem flake e sem o canal do home-manager instalado, mude para false.
    usarHomeManager = true;

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
      uuid          = "COLE-O-UUID-AQUI";   # Veja com: lsblk -f
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
      dockerLocalOnly  = true;              # Impede que o Docker exponha portas na rede local sem aviso
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
      # Para cada um, o NixOS cria os comandos:
      #   srcds-<nome>-update | srcds-<nome>-start | srcds-<nome>-stop | srcds-<nome>-logs | srcds-<nome>-dir
      servidores = {
        # --- Servidor 1: Garry's Mod ---
        gmod = {
          enable    = false;                # Mude para true para ativar o serviço e abrir as portas
          autoStart = false;                # true = liga sozinho no boot do PC
          appId     = 4020;                 # AppID do Garry's Mod Dedicated Server
          execBin   = "srcds_run";
          execArgs  = "-game garrysmod -console -port 27015 +maxplayers 16 +gamemode sandbox +map gm_construct";
          portasUDP = [ 27015 ];
          portasTCP = [ 27015 ];
          # Se quiser forçar SÓ este servidor em um disco específico, descomente a linha abaixo:
          # customDir = "/mnt/ssd/meus_servidores/gmod";
        };

        # --- Servidor 2: Counter-Strike 2 ---
        cs2 = {
          enable    = false;
          autoStart = false;
          appId     = 730;
          execBin   = "game/bin/linuxsteamrt64/cs2";
          execArgs  = "-dedicated -port 27016 +map de_dust2 +game_type 0 +game_mode 1 -maxplayers 10";
          portasUDP = [ 27016 27020 ];      # Porta 27016 para não dar conflito se rodar junto com o GMod
          portasTCP = [ 27016 ];
        };
      };
    };

    # --- 9. Manutenção Automática do NixOS ---
    manutencao = {
      gcAutomatico = true;
      gcManterDias = "14d";
    };
  };

  # ──────────────────────────────────────────────────────────────────────────
  # Lógica Interna Híbrida (Funciona com Flake ou Sem Flake automaticamente)
  # ──────────────────────────────────────────────────────────────────────────
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

  # Resolve o diretório base do SRCDS ("home" vs "custom")
  srcdsBaseDir =
    if cfg.srcds.localArmazenamento == "home"
    then "/home/${cfg.usuario}/srcds"
    else cfg.srcds.caminhoCustom;

  # Função que descobre a pasta de cada servidor individual
  dirDoServidor = nome: srv:
    if (srv ? customDir && srv.customDir != null)
    then srv.customDir
    else "${srcdsBaseDir}/${nome}";

  # Filtra apenas os servidores que estão com enable = true
  servidoresAtivos = lib.filterAttrs (_: srv: srv.enable) cfg.srcds.servidores;

  # Gera automaticamente os 5 aliases de terminal para CADA servidor declarado
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

  # Verifica se o módulo do Home Manager está carregado na avaliação atual
  hmDisponivel = cfg.usarHomeManager && (options ? home-manager);
in

{
  imports = [
    ./hardware-configuration.nix
  ];

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
  services.xserver.xkb.layout = cfg.tecladoGrafico;
  nixpkgs.config.allowUnfree = true;

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

  networking.firewall.enable = true;

  services.resolved = lib.mkIf cfg.seguranca.dnsCriptografado {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "9.9.9.9#dns.quad9.net" "1.1.1.1#cloudflare-dns.com" ];
    dnsovertls = "true";
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

  services.xserver.videoDrivers = [ "nvidia" ];

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

  environment.sessionVariables = lib.mkIf cfg.desktop.hyprland {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = cfg.desktop.hyprland;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ] ++ lib.optional cfg.desktop.hyprland xdg-desktop-portal-hyprland;
  };

  services.xserver = lib.mkIf cfg.desktop.i3 {
    enable = true;
    windowManager.i3.enable = true;
  };
  services.displayManager.lightdm.enable = lib.mkIf (cfg.desktop.i3 && !cfg.desktop.plasma && !cfg.desktop.hyprland) true;

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
  # 6. USUÁRIO, SHELL E SUPER ALIASES (Flake + Multi-SRCDS)
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

  # --- Aliases Globais + Aliases Dinâmicos de Cada Servidor SRCDS ---
  environment.shellAliases = {
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
    myip       = "curl -s ifconfig.me && echo ''";
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
  } // aliasesSrcds;

  # ==========================================================================
  # 7. HOME MANAGER EMBUTIDO (Gerencia Dotfiles e Apps do Usuário)
  # ==========================================================================
  # Tudo dentro deste bloco configura a sua conta "nap" sem precisar de root
  # e sem criar arquivos separados!
  config = lib.mkIf hmDisponivel {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup"; # Evita erro se já existir um arquivo de config antigo

    home-manager.users.${cfg.usuario} = { pkgs, ... }: {
      home.stateVersion = cfg.stateVersion;

      # Pacotes exclusivos do seu usuário (ou pacotes vindos de Flakes externos)
      home.packages = with pkgs; [
        # Exemplo: se adicionou um flake externo no flake.nix, chame aqui:
        # inputs.zen-browser.packages.${pkgs.system}.default
      ];

      # Configuração declarativa do Git
      programs.git = {
        enable = true;
        userName = cfg.gitUser;
        userEmail = cfg.gitEmail;
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = false;
        };
      };

      # Prompt moderno Starship já integrado ao Fish
      programs.starship = {
        enable = true;
        enableFishIntegration = true;
      };

      # Diretórios padrão XDG (Downloads, Documents, Pictures, etc.)
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
      };
    };
  };

  # ==========================================================================
  # 8. PACOTES DO SISTEMA
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
    nodejs_22
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
  ]);

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

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

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
      SDL2
    ];
  };

  # ==========================================================================
  # 10. VIRTUALIZAÇÃO (Docker Blindado & VMware)
  # ==========================================================================
  virtualisation.docker = lib.mkIf (cfg.modulos.docker && !cfg.seguranca.dockerRootless) {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      live-restore = true;
    } // lib.optionalAttrs cfg.seguranca.dockerLocalOnly {
      ip = "127.0.0.1";
    };
  };

  virtualisation.docker.rootless = lib.mkIf (cfg.modulos.docker && cfg.seguranca.dockerRootless) {
    enable = true;
    setSocketVariable = true;
  };

  virtualisation.vmware.host.enable = cfg.modulos.vmware;

  # ==========================================================================
  # 11. FLATPAK
  # ==========================================================================
  services.flatpak.enable = cfg.modulos.flatpak;

  systemd.services.flatpak-add-flathub-repo = lib.mkIf cfg.modulos.flatpak {
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

  # ==========================================================================
  # 12. GERADOR MULTI-SRCDS (Pastas, Firewall Dinâmico e Serviços Isolados)
  # ==========================================================================
  # Cria a pasta base e as subpastas para TODOS os servidores declarados no Painel
  systemd.tmpfiles.rules =
    [ "d ${srcdsBaseDir} 0755 ${cfg.usuario} users -" ]
    ++ (lib.mapAttrsToList (nome: srv:
      "d ${dirDoServidor nome srv} 0755 ${cfg.usuario} users -"
    ) cfg.srcds.servidores)
    ++ lib.optional cfg.discoSecundario.enable
      "d ${cfg.discoSecundario.pontoMontagem} 0755 ${cfg.usuario} users -";

  # Abre no firewall APENAS as portas dos servidores que estão com enable = true
  networking.firewall = {
    allowedUDPPorts = lib.concatLists (lib.mapAttrsToList (_: srv: srv.portasUDP) servidoresAtivos);
    allowedTCPPorts = lib.concatLists (lib.mapAttrsToList (_: srv: srv.portasTCP) servidoresAtivos);
  };

  # Gera um serviço systemd isolado ("srcds-gmod", "srcds-cs2", etc.) para cada servidor
  systemd.services = lib.mapAttrs' (nome: srv:
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
        Environment = [ "HOME=${srcdsBaseDir}" ];
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
  ) cfg.srcds.servidores;

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

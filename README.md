# NixOS 26.05 ("Yarara") — Desktop Nvidia | Gaming + Dev | Estúdio Source Engine (1 & 2) | Multi-SRCDS

Uma configuração declarativa, modular e pronta para produção do **NixOS 26.05** com **Flakes**, **Home Manager embutido**, **3 canais de pacotes** (`Stable`, `Unstable` e `Flakes externos`), **Painel de Configuração TUI interativo no terminal** (`painel`) e **Guia Interativo embutido** (`guia`).

---

## 🎯 Para Quem é Esta Configuração?

Esta configuração foi desenhada especificamente para quem quer um sistema **imutável, blindado e impossível de quebrar em atualizações**, atendendo a 4 perfis simultâneos:

1. **Gamers em Hardware Nvidia (Wayland & X11):**
   * Drivers proprietários Nvidia pré-configurados (com suporte a `nvidiaOpen` para RTX série 20/30/40/50), **KDE Plasma 6 (Wayland)** e **Hyprland (UWSM)** prontos na tela de login (SDDM).
   * Steam com **Proton-GE**, Gamescope, Gamemode, MangoHud, Lutris, Heroic, ProtonUp-Qt, r2modman, ZRAM (`zstd`), EarlyOOM e ajustes de kernel (`vm.max_map_count` e `split_lock_mitigate=0`).
2. **Modders e Criadores de Conteúdo para Source Engine (Source 1 & Source 2):**
   * Inclui o gerenciador exclusivo **`source-tools` (`st`)**, que isola um prefixo Wine 64-bit dedicado com `.NET Framework 4.8`, `VC++ 2022`, `d3dx9`, `d3dcompiler_47` e `corefonts`, além de baixar e atualizar ferramentas nativas e de Windows direto das releases oficiais do GitHub:
     * **Modelos:** Crowbar, Half-Life Model Viewer (`hlmv`), F3D (e suporte a Blender via Steam).
     * **Texturas & Pacotes:** **MareTF** (nativo Linux), **VTFEdit**, **VPKEdit** (substituto nativo do GCFScape para `.vpk`, `.gma`, `.bsp`, `.gcf`, `.wad`), GIMP, Krita, Inkscape, Upscayl e ImageMagick.
     * **Mapas:** **Hammer / Hammer++**, **CompilePal**, **BSPSource** (decompilador `.bsp` -> `.vmf`) e **Lumper** (editor nativo de lumps/entidades/pakfile de `.bsp`).
     * **Áudio:** Audacity + SoX (conversão rápida para WAV PCM 16-bit 44.1 kHz exigido pela Source).
     * **Garry's Mod (GLua):** `fastgmad` (criador/extrator `.gma` ultra-rápido), `glualint` (GLuaFixer), `lua-language-server`, `stylua` e `luajit`.
     * **Source 2 (CS2, Deadlock, Dota 2, HL:Alyx):** **Source 2 Viewer** (`s2v` GUI e `s2v-cli` nativo).
3. **Administradores de Servidores Dedicados (Multi-SRCDS):**
   * Gerador automático de servidores dedicados (`gmod`, `cs2`, `tf2`, `css`, `l4d2`, etc.).
   * Cria pastas automaticamente, abre apenas as portas dos servidores ativos no firewall, gera 7 aliases por servidor (`srcds-<nome>-*`) e isola cada servidor em um serviço `systemd` com sandboxing contra exploits RCE (`ProtectHome = "tmpfs"`, bloqueio de `docker.sock`, `NoNewPrivileges`) e compatibilidade Glibc 2.42+ (`GLIBC_TUNABLES=glibc.rtld.execstack=2`).
4. **Desenvolvedores & Usuários Avançados:**
   * VSCode, Neovim, Python 3, Node.js 24, Go, Rust (`rustup`), GCC/CMake, Lazygit, Postman, Docker (com proteção `dockerLocalOnly` contra exposição acidental de portas na LAN), VMware Workstation Pro, Flatpak (Flathub automático), AppImage (`binfmt` com 2 cliques) e Roteador I2P (sempre na última versão via overlay do canal Unstable).

---

## 📁 Estrutura de Arquivos na Pasta do Projeto

| Arquivo | Onde deve ficar no NixOS | Função |
| :--- | :--- | :--- |
| **`configuration.nix`** | `/etc/nixos/configuration.nix` | Configuração principal do sistema, Painel de Controle (`cfg`), Estúdio Source (`source-tools`), Painel TUI (`nixos-painel`), Guia (`nixos-guia`) e Home Manager. |
| **`flake.nix`** | `/etc/nixos/flake.nix` | Declara os 3 canais (`nixos-26.05`, `nixos-unstable`, `home-manager` e Flakes externos) e trava as versões no `flake.lock`. |
| **`PROMPT-IA.md`** | *(Arquivo de referência)* | Prompt pronto para copiar e colar em qualquer IA caso você precise de ajuda futura, explicando toda a arquitetura do seu sistema. |
| **`README.md`** | *(Este guia)* | Documentação completa de instalação, primeiros passos, uso diário e FAQs. |

> [!CAUTION]
> **REGRA DE OURO DO NIXOS:**
> Quando você instala o NixOS pelo instalador oficial (Calamares), ele cria dois arquivos em `/etc/nixos/`:
> 1. `/etc/nixos/configuration.nix` -> **SUBSTITUA** pelo `configuration.nix` deste projeto.
> 2. `/etc/nixos/hardware-configuration.nix` -> **JAMAIS APAGUE OU SUBSTITUA!** Ele contém os UUIDs reais das partições do seu SSD/NVMe onde o sistema foi instalado.

---

## 🚀 Passo a Passo: Instalação Limpa (Fresh Install)

### Passo 1: Instalar o NixOS normalmente
1. Baixe a ISO oficial do **NixOS 26.05 (KDE Plasma)** no site oficial e crie o pendrive com Ventoy ou BalenaEtcher.
2. No instalador gráfico:
   * Crie seu usuário com o nome **`nap`** (ou, se escolher outro nome, altere `usuario = "seu_nome";` na linha 27 do `configuration.nix` antes de aplicar).
   * Na tela de Bootloader, mantenha o padrão **systemd-boot** (UEFI).
   * Conclua a instalação e reinicie no seu novo NixOS.

### Passo 2: Verificar o `stateVersion` original
Antes de substituir o arquivo original, abra o terminal e veja qual `stateVersion` o instalador gerou:
```bash
grep stateVersion /etc/nixos/configuration.nix
```
*(No NixOS 26.05 será `"26.05"`, que já é o valor padrão da linha 37 do nosso `configuration.nix`. Se você instalou a partir de uma ISO 25.11, mantenha o número original na linha 37).*

### Passo 3: Fazer backup e copiar os arquivos para `/etc/nixos/`
No terminal, dentro da pasta onde estão os arquivos deste projeto:
```bash
# 1. Faz backup do configuration.nix original gerado pelo instalador
sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.instalador.bak

# 2. Copia o novo configuration.nix e o flake.nix para /etc/nixos/
sudo cp ./configuration.nix /etc/nixos/configuration.nix
sudo cp ./flake.nix /etc/nixos/flake.nix
```

> **Atenção:** Confira se o seu `/etc/nixos/hardware-configuration.nix` continua intacto lá dentro com `ls -la /etc/nixos/`.

### Passo 4: Rodar o 1º Rebuild (Ativando Flakes)
Na **primeira vez** após instalar o sistema, os Flakes ainda não estão ativos. Rode este comando único no terminal:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos --extra-experimental-features "nix-command flakes"
```
*O NixOS vai baixar os canais, criar o arquivo `/etc/nixos/flake.lock`, instalar seus drivers Nvidia, KDE Plasma 6, Hyprland, Steam, ferramentas de criação Source, configurar o Home Manager e ativar os super aliases.*

Quando terminar, **reinicie o computador** (`reboot`) e abra um novo terminal. A partir de agora, você já estará no shell **Fish** com o prompt **Starship** e todos os comandos ativos!

---

## 🛠️ Primeiros Passos Após o 1º Boot

### 1. Conheça os 2 Utilitários Interativos de Terminal
Você não precisa decorar comandos nem editar código manualmente para o dia a dia:

* **Painel de Configuração TUI (`painel` / `configurar` / `ntui`):**
  ```bash
  painel
  ```
  Abre um painel interativo no terminal com **preview ao vivo** do seu `configuration.nix`. Nele você pode:
  * Ligar/desligar módulos (`[ON]` / `[OFF]`) com `ENTER` (ou marcar vários com `TAB`).
  * Trocar o Kernel (`stable`, `zen`, `latest`), governador de CPU (`schedutil`, `performance`), variante do Wine ou shell padrão.
  * Configurar seu **2º SSD/NVMe automaticamente** escolhendo a partição na lista (`lsblk`).
  * Gerenciar servidores dedicados **Multi-SRCDS** e criar novos servidores com templates prontos.
  * Ver o `diff` do que mudou, testar (`nrt`), aplicar (`nrs`) ou desfazer alterações da sessão.

* **Guia e Manual Interativo (`guia` / `ajuda` / `manual`):**
  ```bash
  guia
  ```
  Abre a documentação completa do sistema dividida em 12 capítulos com busca global em tempo real (`guia <termo>` pesquisa direto da linha de comando, ex: `guia crowbar` ou `guia ssd`).

---

### 2. Inicializar o Estúdio Source Engine (`source-tools` / `st`)
Para deixar todas as ferramentas de criação da Source 1 e Source 2 prontas:

```bash
# 1. Cria e prepara o prefixo Wine exclusivo de modding (.NET 4.8, VC++ 2022, d3dx9, fontes)
#    Nota: a instalação do dotnet48 leva de 10 a 20 minutos; é normal parecer parada!
st setup

# 2. Baixa automaticamente das releases oficiais do GitHub:
#    Crowbar, CompilePal, BSPSource, Lumper, MareTF, Source2Viewer (GUI/CLI), fastgmad e glualint
st baixar

# 3. (Opcional) Escolhe e baixa a build do Hammer++ para o seu jogo
st hammerpp

# 4. (Opcional) Instala o Blender, Garry's Mod ou Source SDK Base 2013 direto na Steam
st steam

# 5. Verifica se está tudo instalado e pronto
st status
```

---

### 3. Configurar um 2º SSD / NVMe (Opcional)
* **Se for apenas um disco de arquivos gerais:** Você não precisa fazer nada! Ele aparece automaticamente na barra lateral do gerenciador de arquivos (Dolphin) para montar com 1 clique.
* **Se for usar para Biblioteca da Steam ou Servidores SRCDS (montagem fixa no boot em `/mnt/ssd`):**
  1. Digite `painel` no terminal.
  2. Entre em **`05. [2º SSD / NVMe]`** -> **`[Assistente Automático]`**.
  3. Selecione a partição desejada na lista e pressione `ENTER`. O painel preenche o `UUID`, detecta o `fsType` (`ext4`, `btrfs` ou `ntfs3`) e ativa `enable = true` sozinho.
  4. No menu principal do painel, selecione **`11. [Aplicar Agora (nrs)]`**.

---

## ⌨️ Uso Diário: Tabela Completa de Aliases

### Painel TUI, Guia & Gerenciamento do NixOS
| Comando | O que faz |
| :--- | :--- |
| **`painel`** / **`configurar`** / **`ntui`** | Abre o **Painel de Controle TUI** que edita o `configuration.nix` visualmente |
| **`guia`** / **`ajuda`** / **`manual`** | Abre o **Manual Interativo** completo no terminal |
| **`guia <palavra>`** | Pesquisa qualquer termo em todo o manual (ex: `guia hammer`) |
| **`nrs`** | **Aplica alterações** (`sudo nixos-rebuild switch --flake /etc/nixos#nixos`) |
| **`nrt`** | **Testa alterações** na sessão atual sem criar entrada no menu de boot |
| **`nroll`** | **Rollback imediato** para a geração anterior caso algo dê errado |
| **`nconf`** | Abre o `/etc/nixos/configuration.nix` no Neovim com `sudo` |
| **`nflake`** | Abre o `/etc/nixos/flake.nix` no Neovim com `sudo` |
| **`nup`** | **Atualiza todo o sistema** (atualiza o `flake.lock` de todos os canais e roda `nrs`) |
| **`ngc`** | **Limpa o lixo** (apaga gerações antigas do sistema e do usuário para liberar SSD) |
| **`nopt`** | **Otimiza a `/nix/store`** deduplicando arquivos idênticos via hardlinks |
| **`ngen`** | Lista todas as gerações instaladas do sistema com datas |

### Estúdio de Criação Source Engine
| Comando | O que faz |
| :--- | :--- |
| **`st`** | Gerenciador principal `source-tools` (rode `st ajuda` para ver todas as opções) |
| **`crowbar`** | Abre o **Crowbar** (compilar/decompilar `.mdl` <-> `.qc`/`.smd`) |
| **`hammer`** | Procura nas bibliotecas Steam e abre o **Hammer / Hammer++** via Wine |
| **`s2v`** | Abre o **Source 2 Viewer (GUI)** para CS2, Deadlock, Dota 2 e HL:Alyx |
| **`st maretf`** | Abre o **MareTF** (editor/conversor nativo de texturas `.vtf` 7.0–7.6) |
| **`vtfedit`** | Abre o **VTFEdit** clássico |
| **`vpkedit`** | Abre o **VPKEdit** (substituto nativo do GCFScape para `.vpk`, `.gma`, `.bsp`) |
| **`st compilepal`** | Abre o **CompilePal** (compilação avançada de mapas + pack de assets) |
| **`st bspsrc`** | Abre o **BSPSource** (decompilador de mapas `.bsp` -> `.vmf`) |
| **`st lumper`** | Abre o **Lumper** (editor nativo de lumps/entidades/pakfile de `.bsp`) |
| **`st hlmv`** | Procura nas bibliotecas Steam e abre o **Half-Life Model Viewer** (`hlmv.exe`) |
| **`st fastgmad`** | Executa o **fastgmad** (cria/extrai `.gma` de Garry's Mod) |
| **`st glualint`** | Executa o linter/formatador **GLuaFixer** |
| **`st exe <arq.exe>`** | Roda qualquer outro `.exe` dentro do prefixo Wine preparado para modding |
| **`sp`** | Entra na pasta dos seus projetos (`~/SourceProjects`) |
| **`sp-tools`** | Entra na pasta das ferramentas baixadas (`~/SourceTools`) |

### Multi-SRCDS (Gerados Automaticamente por Servidor)
Para cada servidor em `cfg.srcds.servidores` (ex: `gmod`, `cs2`, `tf2`), existem:
* `srcds-<nome>-update` — Baixa/atualiza os arquivos do servidor via `steamcmd`
* `srcds-<nome>-start` — Inicia o servidor em background via `systemd`
* `srcds-<nome>-stop` — Para o servidor
* `srcds-<nome>-restart` — Reinicia o servidor
* `srcds-<nome>-status` — Mostra o status do serviço
* `srcds-<nome>-logs` — Mostra o console do servidor ao vivo (`Ctrl+C` sai da visualização)
* `srcds-<nome>-dir` — Entra na pasta onde o servidor está instalado

### Monitoramento, Rede, Git & Docker
* **`top`** (`btop`), **`gpu`** (`nvtop`), **`ports`** (`sudo ss -tulanp`), **`myip`**, **`espaco`**, **`limpar-ram`**, **`erros-boot`**
* **`lg`** (`lazygit`), **`gs`**, **`ga`**, **`gc`**, **`gp`**, **`dps`**, **`dcu`**, **`dcd`**, **`dlogs`**

---

## 📦 Como Instalar Novos Programas (Os 3 Canais)

Consulte o nome exato do pacote em **[search.nixos.org/packages](https://search.nixos.org/packages)**.

1. **1º Canal: STABLE (`pkgs` — Padrão para 95% dos programas):**
   Abra o `nconf`, procure por `environment.systemPackages = (with pkgs; [` e adicione o nome do pacote (ex: `vlc`). Salve e rode `nrs`.
2. **2º Canal: UNSTABLE (`pkgsUnstable` — Última versão lançada hoje):**
   Na mesma lista `environment.systemPackages`, basta colocar `pkgsUnstable.` antes do nome do pacote (ex: `pkgsUnstable.obsidian`).
3. **3º Canal: FLAKES EXTERNOS (`inputs` — Repositórios de terceiros no GitHub):**
   Adicione a URL do flake em `inputs` no `flake.nix` (`nflake`) e referencie o pacote em `home.packages` ou `systemPackages` no `configuration.nix`.
4. **Uso Temporário (Sem instalar no sistema):**
   * `nix-shell -p nome-do-pacote` (abre um terminal com o programa disponível; ao fechar, ele some).
   * `nix run nixpkgs#nome-do-pacote` (executa diretamente).
5. **Flatpak & AppImage:**
   * Flatpak: `flatpak install flathub org.gimp.GIMP` (ou pela loja Discover do KDE Plasma).
   * AppImage: dê `chmod +x arquivo.AppImage` e abra com 2 cliques.

---

## ❓ FAQ & Resolução de Problemas (Troubleshooting)

### 1. Criei um arquivo `.nix` novo em `/etc/nixos/` e o `nrs` diz que o arquivo não existe!
Quando a pasta `/etc/nixos` é um repositório Git, o Nix Flakes ignora arquivos que ainda não foram adicionados ao índice do Git. Basta rodar:
```bash
cd /etc/nixos && sudo git add .
```
*(Não precisa fazer commit, apenas `git add .`).*

### 2. Como aponto o `studiomdl.exe` no Crowbar?
Dentro do Wine, a raiz `/` do Linux fica na letra **`Z:\`**.
1. Na Steam, clique com o botão direito no jogo/SDK (ex: *Garry's Mod* ou *Source SDK Base 2013*), vá em **Propriedades > Compatibilidade** e marque **Forçar o uso de ferramenta Steam Play (Proton)** para a Steam baixar a pasta `bin/` com os `.exe` de Windows.
2. No Crowbar (`Set Up Games`), aponte para:
   `Z:\home\nap\.local\share\Steam\steamapps\common\GarrysMod\bin\studiomdl.exe`

### 3. O `st setup` deu erro ao instalar o `dotnet48` no Wine. O que fazer?
Se alguma atualização do Wine `wow64` conflitar com o instalador do `.NET 4.8`:
1. Abra o `painel` -> `02. [Estúdio Source Engine]` -> troque **Variante do Wine** de `wow64` para **`classico`**.
2. Aplique com `nrs`.
3. Apague o prefixo incompleto (`rm -rf ~/.local/share/source-modding/wine`) e rode `st setup` novamente.

### 4. As janelas pequenas do Hammer++ somem atrás da janela principal no Wayland!
Rode `st winecfg`, vá na aba **Graphics** e marque **Emulate a virtual desktop** (ex: `1920x1080`). Isso mantém todas as janelas flutuantes de texturas e propriedades do Hammer++ dentro de uma única janela principal perfeitamente estável no KDE Plasma e no Hyprland.

### 5. Uma atualização quebrou algo ou não entra na interface gráfica. Como volto atrás?
* Se tiver acesso ao terminal: digite **`nroll`**.
* Se for ao ligar o PC: na tela preta do **systemd-boot**, basta selecionar a geração anterior com as setas do teclado e pressionar `ENTER`!

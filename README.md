# dotfiles

このリポジトリはNix/Home-Managerを使用して、宣言的にdotfilesを管理しています。

## prerequisite

### Nix

Install Nix package manager (required):

```bash
# Install Nix with flakes support
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (if not already enabled)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Terminal

Install Wezterm

https://wezfurlong.org/wezterm/

**TODO: 暫定対応なのでコマンドで実行できるように改善したい**

Windowsの場合は以下のようにweztermの設定ファイルをホストOSのWindows側にファイルをコピーする

```bash
cp ~/ghq/github.com/mikinovation/dotfiles/config/wezterm/.wezterm.lua /mnt/c/Users/[UserName]/
```

### 

```bash
suso apt install fdclone
```

### node2nix

To update npm packages managed by node2nix:

```bash
# Navigate to the node2nix directory
cd ~/ghq/github.com/mikinovation/dotfiles/config/node2nix

# Edit node-packages.json to add/update packages

# Run node2nix to generate Nix expressions
nix-shell -p nodePackages.node2nix --command "node2nix -i ./node-packages.json -o node-packages.nix"
```


## install

### Automatic Installation (Recommended)

Run the setup script, which will automatically install Home Manager and deploy all configurations:

```bash
ghq get git@github.com:mikinovation/dotfiles.git
cd ~/ghq/github.com/mikinovation/dotfiles
./setup.sh
```

### Manual Installation

If you prefer to deploy manually using Home Manager:

```bash
# Clone the repository
ghq get git@github.com:mikinovation/dotfiles.git

# Setup nix.conf first
mkdir -p ~/.config/nix
ln -s ~/ghq/github.com/mikinovation/dotfiles/config/nix/nix.conf ~/.config/nix/nix.conf

# Deploy using Home Manager
nix run home-manager/master -- switch --flake ~/ghq/github.com/mikinovation/dotfiles/config/nix#mikinovation
```

### Update Configuration

After making changes to your configuration files:

```bash
# Using Home Manager directly
home-manager switch --flake ~/ghq/github.com/mikinovation/dotfiles/config/nix#mikinovation

# Or re-run the setup script
cd ~/ghq/github.com/mikinovation/dotfiles
./setup.sh
```

## Secrets management (password-store)

シークレットや環境ごとの変数は `password-store` (`pass`) で管理します。
暗号化されたストア本体 (`~/.password-store`) は **この public dotfiles には含めず**、
別のプライベートリポジトリとして管理してください。

### 初期セットアップ

```bash
# 1. GPG 鍵を作成（既にあればスキップ）
gpg --full-generate-key

# 2. password-store を初期化
pass init <YOUR_GPG_KEY_ID>

# 3. 既存のストアを private リポジトリから復元する場合
git clone git@github.com:<you>/password-store.git ~/.password-store
```

### ディレクトリ規約

グローバル用と案件別の 2 階層を併存運用します。
環境名は **`local` / `dev` / `staging` / `prod` をそれぞれ独立した環境として扱います**
（`local` は自分の手元マシン、`dev` は共有の開発環境、という別物の位置付け）。
デフォルトは `local`（=自分のマシン）です。

**ロードポリシー**: カレントシェルや direnv で**常駐できるのは `local` のみ**です。
`dev` / `staging` / `prod` は **`passrun` による単発（サブシェル）実行専用**で、
誤って prod の認証情報が対話シェルに残り続ける事故を避ける設計にしています。

```
~/.password-store/
├── env/                      # グローバル（案件に紐づかない共通環境変数）
│   ├── local/                # 自分のマシン用（Docker, モック DB 等）
│   ├── dev/                  # 共有の開発環境
│   ├── staging/
│   └── prod/
├── project-a/                # 案件別（<project> は git repo の basename 推奨）
│   ├── local/
│   │   ├── API_KEY.gpg
│   │   └── DATABASE_URL.gpg
│   ├── dev/
│   │   ├── API_KEY.gpg
│   │   └── DATABASE_URL.gpg
│   ├── staging/
│   └── prod/
└── project-b/
    └── local/
```

投入例:

```bash
# グローバル（環境ごとに独立）
pass insert env/local/DATABASE_URL
pass insert env/dev/DATABASE_URL

# 案件別（local と dev は別物の値）
pass insert project-a/local/API_KEY
pass insert project-a/dev/API_KEY
pass insert -m project-a/prod/DATABASE_URL
```

### シェル関数（`local` 常駐）

`passenv` はカレントシェルへロードしますが、**`local` 以外は拒否**されます。
非 local 環境を使いたい場合は `passrun`（サブシェル）を使ってください。

```bash
# OK: local はカレントシェルに常駐可能
passenv local                 # env/local/*
passenv project-a local       # project-a/local/*
passenv project-a/local       # スラッシュ形

# NG: dev/staging/prod は passenv で拒否される
passenv dev
# => passenv: 'dev' is restricted to single-command execution.
#             Only 'local' can be loaded into the current shell.
#             Run instead:  passrun env/dev <command>

# クリア
passenv-unset
```

### 単発実行（`dev` / `staging` / `prod` 専用）

非 local 環境は `passrun` で**サブシェル内の単発コマンドとしてのみ**実行します。
コマンド終了と同時に認証情報は破棄され、対話シェルには残りません。

```bash
# グローバル dev/prod の単発実行
passrun env/dev  aws s3 ls
passrun env/prod aws s3 ls

# 案件別
passrun project-a dev     npm run start
passrun project-a staging npm run deploy
passrun project-a prod    aws s3 ls

# 対話的に作業したい場合はシェルそのものを単発で起動
passrun project-a prod zsh
# => prod の値が入った一時シェル。exit すると元のシェルに戻る。
#    プロンプトは赤色の <project>:prod 表示で誤操作防止。
```

### direnv による自動ロード（`local` のみ）

各プロジェクト repo の `.envrc` に 1 行書けば、`cd` で自動的に `local` がロードされます。

```sh
# ~/ghq/github.com/mikinovation/project-a/.envrc
use pass                      # project = git repo 名、env = local
```

初回のみ許可:

```bash
direnv allow .
```

direnv が読み込めるのも **`local` のみ**です。`.envrc` 側で `use pass project-a prod`
のように非 local を指定した場合はロード拒否され、エラーメッセージに `passrun` の
使い方が案内されます。

### プロンプト表示

Powerlevel10k の右プロンプトに `<project>:<env>` が表示されます
（prod は赤、staging は黄、dev は緑、local はシアン）。どの案件のどの環境で
作業しているかが常に視認できるので、prod への誤操作を防げます。

## lint and format

```bash
sh ./scripts/lint.sh
sh ./scripts/format.sh
```

## testing

Run Lua tests using busted:

```bash
# Run all tests
busted .

# Run specific test file
busted config/nvim/plugins/claude-code_spec.lua

# Run tests with verbose output
busted -v
```

### Setup Copilot

```bash
:Copilot auth
```

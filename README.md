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

```
~/.password-store/
├── env/                      # グローバル（案件に紐づかない共通環境変数）
│   ├── dev/
│   │   ├── AWS_ACCESS_KEY_ID.gpg
│   │   └── DATABASE_URL.gpg
│   └── prod/
├── project-a/                # 案件別（<project> は git repo の basename 推奨）
│   ├── dev/
│   │   ├── API_KEY.gpg
│   │   └── DATABASE_URL.gpg
│   ├── staging/
│   └── prod/
└── project-b/
    └── dev/
```

投入例:

```bash
# グローバル
pass insert env/dev/AWS_ACCESS_KEY_ID

# 案件別
pass insert project-a/dev/API_KEY
pass insert -m project-a/prod/DATABASE_URL
```

### シェル関数による切り替え

zsh に以下が定義されます。

```bash
# グローバル env/dev/* をカレントシェルに export
passenv dev

# 案件別 project-a/prod/* をカレントシェルに export
passenv project-a prod
passenv project-a/prod        # スラッシュ形でも可

# サブシェルだけに注入して 1 コマンド実行（推奨）
passrun env/prod aws s3 ls
passrun project-a prod npm run start

# クリア
passenv-unset
```

### direnv による案件ごとの自動切替

案件 (`<project>/<env>`) は direnv と組み合わせると `cd` だけで自動ロードされます。
各プロジェクトの `.envrc` は 1 行で済みます。

```sh
# ~/ghq/github.com/mikinovation/project-a/.envrc
use pass                      # project = git repo 名、env = $APP_ENV か dev
```

初回のみ許可:

```bash
direnv allow .
```

dev/prod の切替は `projenv` で:

```bash
cd ~/ghq/.../project-a        # APP_ENV=dev が自動ロード
projenv prod                  # direnv reload で prod に切替
projenv dev                   # dev に戻す
projenv-reset                 # APP_ENV を unset してデフォルト挙動に
```

`.envrc` を `use pass project-a prod` のように引数で固定化することもできます。

### プロンプト表示

Powerlevel10k の右プロンプトに `<project>:<env>` が表示されます
（prod は赤、staging は黄、dev は緑）。どの案件のどの環境で作業しているかが
常に視認できるので、prod への誤操作を防げます。

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

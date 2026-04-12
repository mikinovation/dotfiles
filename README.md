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

環境切替用の変数は `env/<env-name>/<VAR_NAME>` に格納します。

```
~/.password-store/
├── env/
│   ├── dev/
│   │   ├── AWS_ACCESS_KEY_ID.gpg
│   │   └── DATABASE_URL.gpg
│   └── prod/
│       └── ...
```

投入例:

```bash
pass insert env/dev/AWS_ACCESS_KEY_ID
pass insert -m env/dev/DATABASE_URL
```

### 環境の切り替え

zsh に `passenv` / `passrun` / `passenv-unset` が定義されます。

```bash
# カレントシェルに env/dev/* を export
passenv dev

# サブシェルだけに env/prod/* を注入して 1 コマンド実行（推奨）
passrun prod aws s3 ls

# passenv でロードした変数をクリア
passenv-unset
```

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

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
cp ~/dotfiles/config/wezterm/.wezterm.lua /mnt/c/Users/[UserName]/
```

### 

```bash
suso apt install fdclone
```

### Sheldon

Sheldon will be automatically installed via Home Manager (no manual installation needed).

### LuaRocks

package manager for Lua modules

```
sudo apt install luarocks
```

### luacheck

linter for lua

```
sudo luarocks install luacheck
```

### node2nix

To update npm packages managed by node2nix:

```bash
# Navigate to the node2nix directory
cd ~/dotfiles/config/node2nix

# Edit node-packages.json to add/update packages

# Run node2nix to generate Nix expressions
nix-shell -p nodePackages.node2nix --command "node2nix -i ./node-packages.json -o node-packages.nix"
```

### win32yank (for WSL)

For clipboard integration between WSL and Windows, install win32yank:

```bash
# Create bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Download win32yank
curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip

# Extract executable
unzip -p /tmp/win32yank.zip win32yank.exe > ~/.local/bin/win32yank.exe

# Make executable
chmod +x ~/.local/bin/win32yank.exe

# Add to PATH if not already included
echo 'export PATH=$PATH:~/.local/bin' >> ~/.zshrc

# Clean up
rm /tmp/win32yank.zip
```

Make sure `~/.local/bin` is in your PATH to use clipboard features in Neovim and ZSH.

### luaformatter

formatter for lua

```
brew install stylua
```

### busted

Testing framework for Lua

```
luarocks install --local busted
```

## install

### Automatic Installation (Recommended)

Run the setup script, which will automatically install Home Manager and deploy all configurations:

```bash
git clone git@github.com:mikinovation/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

### Manual Installation

If you prefer to deploy manually using Home Manager:

```bash
# Clone the repository
git clone git@github.com:mikinovation/dotfiles.git ~/dotfiles

# Setup nix.conf first
mkdir -p ~/.config/nix
ln -s ~/dotfiles/config/nix/nix.conf ~/.config/nix/nix.conf

# Deploy using Home Manager
nix run home-manager/master -- switch --flake ~/dotfiles/config/nix#mikinovation
```

### Update Configuration

After making changes to your configuration files:

```bash
# Using Home Manager directly
home-manager switch --flake ~/dotfiles/config/nix#mikinovation

# Or re-run the setup script
cd ~/dotfiles
./setup.sh
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

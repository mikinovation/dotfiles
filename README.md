# dotfiles

## prerequisite

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

### Shelldon

Install Shelldon

https://github.com/rossmacarthur/sheldon

```bash
brew install sheldon
```

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

### npm packages

```
npm install -g typescript typescript-language-server @tailwindcss/language-server 
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

Run this:

```bash
git clone git@github.com:mikinovation/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
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

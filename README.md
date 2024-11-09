# dotfiles

## prerequisite

### Terminal

Install Wezterm

https://wezfurlong.org/wezterm/

** TODO: 暫定対応なのでコマンドで実行できるように改善したい**

Windowsの場合は以下のようにweztermの設定ファイルをホストOSのWindows側にファイルをコピーする

```bash
cp ~/dotfiles/config/wezterm/wezterm.lua /mnt/c/Users/[UserName]/
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

### luaformatter

formatter for lua

```
brew install stylua
```

## install

Run this:

```bash
git clone git@github.com:mikinovation/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

## lint and fomat

```bash
sh ./scripts/lint.sh
sh ./scripts/format.sh
```

### Setup Copilot

```bash
:Copilot setup
```

Input Authentication Code on Browser. And enable Copilot

```bash
:Copilot enable
```

## delete cache

```bash
:call dein#recache_runtimepath()
```

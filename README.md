# dotfiles

## prerequisite

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
npm install -g @vue/language-server @tailwindcss/language-server 
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

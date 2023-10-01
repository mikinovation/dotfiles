# dotfiles

## install

Run this:

```bash
git clone git@github.com:mikinovation/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./deploy.sh
```

### Copilotの設定

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

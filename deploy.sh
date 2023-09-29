#!/bin/bash
dotfiles=(.zshrc .tmux.conf)

# .zshrc等設定ファイルのシンボリックリンクをホームディレクトリ直下に作成する
for file in "${dotfiles[@]}"; do
        ln -svf ~/dotfiles/${file} ~/${file}
done

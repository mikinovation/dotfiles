# コンセプトから理解するRust

## 前提

.env.exampleをコピーして.envを作成し、環境変数を設定。

```bash
cp .env.example .env
```

## Setup

```bash
# dockerの起動
docker compose up -d
# アプリケーションの起動
cargo run
```

## コマンド

ビルド

```bash
cargo build
```

リリースビルド

```bash
cargo build --release
```

フォーマット

```bash
cargo fmt
```

lint

```bash
cargo clippy
```

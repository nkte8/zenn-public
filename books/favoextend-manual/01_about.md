---
title: 'この本について'
---

# この本について

この本は`favoExtend`を使ってみたい方に向けて作成した、日本語の利用マニュアルです。

# 前提条件

- プログラミングの基礎を理解していること
- Githubを用いた簡単な操作ができること

# 推奨条件

- Zodライブラリを使ったことがあること
- 正規表現を扱えること
- APIを使ったことがあること

# favoExtend とは？

`favoExtend`は、クラウドサービスを用いたREST-APIバックエンドのスーパーセットです。  
以下の特徴があります。

- データベース(Redis)を絡めた API を宣言的に作成することができます。
- AWSのようなハイコストなバックエンドではなく、`Cloudflare`と`Upstash`を用いており、小中規模開発にあたってローコストです。
- デフォルトの機能が足りない場合は、簡単にシステムの拡張ができます（要Typescript知識）

`favoExtend`は以下のクラウドサービスを使っています。

- Cloudflare Worker
  - Cloudflareによるサーバーレスプラットフォームです

https://www.cloudflare.com/ja-jp/developer-platform/workers/

- Upstash/Redis
  - Upstashはサーバーレスデータベースプラットフォームです
  - 利用可能なDBの一つとしての`Redis`を利用します

https://upstash.com

# 開発環境

| 環境          | バージョン                |
| ------------- | ------------------------- |
| macOS         | Sonoma 14.4.1             |
| Windows       | Windows11 Pro             |
| Linux(hyperV) | Ubuntu 22.04.4 LTS        |
| Editor        | VSCode 1.88.1 (Universal) |
| node          | v20.12.2                  |

VSCode拡張機能情報

| 拡張機能名                | バージョン |
| ------------------------- | ---------- |
| Remote Development        | v0.25.0    |
| ESLint                    | v2.4.4     |
| HashiCorp Terraform       | v2.30.1    |
| Prettier - Code formatter | v10.4.0    |

# 著者情報

*ねこの*と名乗っております。昔`猫の手なら貸せる`というブログを書いていたところから来ています。(Zennに移行済み)

Skyshareというやつを作りました！Blueskyで生きていこう。絶賛稼働中です。

https://skyshare.uk

その他リンクです。

Bluesky:  
https://bsky.app/profile/nekono.dev

Github:  
https://github.com/nkte8

ホームページ(Comming Soon...まだ準備中です):  
https://nekono.dev

本職ではコードはほとんど書いていないです。ゆえ、プログラミングは趣味です。

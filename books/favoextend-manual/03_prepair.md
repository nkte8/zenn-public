---
title: '初期設定 - favoExtendの利用準備'
---

# favoExtendの利用準備

favoExtendを利用するにあたっての準備を行います。
リポジトリのcloneおよび、クラウドサービスへ各種登録を行ってください。

以下のサービスへの登録が必要です。

- **Cloudflare**
  - APIの受け口に必要です
- **Upstash**
  - データの登録に必要です

::: message

本情報は執筆時点(`2024-05-01`)での登録方法です。
:::

## リポジトリのfork

[favoExtendをfork](https://github.com/nkte8/favoExtend/fork)します。ご自身の環境へ`git clone`を行ってください。

cloneする際は`v1`ブランチを使ってください。`main`および`v2`は開発中です  
```sh
git clone -b v1 https://github.com/<yourRepository>/favoExtend
```

cloneすると以下のようなファイルがカレントディレクトリに作成されます。
![Cloneしたファイル](/images/books/favoextend-manual/03_cloned.png)

今回は最低限のセットアップ[^1]をします。以下の操作をしてください。

- `provider.tf`を削除
- `terraform.tfvars.template`をコピーし`terraform.tfvars`を作成してください。
- 作成した`terraform.tfvars`をエディタで開き、編集可能な状態にしておきます。
  [^1]: クラウドの構築情報をローカルで管理する構成です。デフォルトでは`Cloudflare R2`を使うための設定(`provider.tf`および`terraform.tfbackend`のテンプレート)が入っているため、こちらを設定したい場合は[Githubに設定方法を簡易的に記載している](https://github.com/nkte8/favoExtend?tab=readme-ov-file#if-you-use-r2-backend-setup-terraformtfbackend)ので、参考に設定してください。

## Cloudflareの利用準備/設定

[Cloudflareへアカウントを登録](https://dash.cloudflare.com/sign-up)し、アカウントIDを確認します。すでにアカウントをお持ちの場合は、利用中のアカウントを使用可能です。

アカウントIDはURLに記載されています。ダッシュボードのURLは

```
https://dash.cloudflare.com/<アカウントID(32文字の英数字)>
```

...となっています。この文字列をメモします。

次にトークンを作成します。マイプロフィール->[APIトークン](https://dash.cloudflare.com/profile/api-tokens)->トークンを作成する(ボタン)から、以下のような権限のトークンを作成します。

![トークン権限のスクリーンショット1](/images/books/favoextend-manual/03_token1.png)
![トークン権限のスクリーンショット2](/images/books/favoextend-manual/03_token2.png)

- トークン名
  - 任意の設定を作成（画像では`Terraform`としています）
- アクセス許可
  - `アカウント`-`Workers スクリプト`-`編集`
  - (Cloudflare でドメインを管理している場合) `ゾーン`-`Workers ルート`-`編集`
- その他はデフォルトで OK

以上の操作によりトークン（`L9fKMC97MY1Xjy96BUkfDnTYOCr-PyOxmD4b3cGL`といった文字列）が発行されます。

先ほど開いた`terraform.tfvars`で、以下のように編集します。

- `cloudflare_api_token`の値を取得したトークンに置き換え
- `cloudflare_account_id`の値を先にメモしたアカウントIDに置き換え
- `cloudflare_worker_name`に識別名をつけます。小文字半角英数字とハイフンのみ使用可能です。

以下は設定の例です。

```tf:terraform.tfvars
# function vars
cloudflare_api_token    = "L9fKMC97MY1Xjy96BUkfDnTYOCr-PyOxmD4b3cGL"
cloudflare_account_id   = "27e2iio33pxebmkbb8ka2yu6s0h6yphy"
cloudflare_workers_name = "favoextend-api"
```

## Upstashの利用準備/設定

[Upstashのログイン](https://console.upstash.com/login)の`Create an account`から、メールアドレスでアカウントを作成します。
`Github`などの各種サービス連携からのログインでアカウント作成も可能ですが、本文章ではメールアドレスで作成された前提で記載します。

アカウントを作成したら、[アカウントメニュー](https://console.upstash.com/account/)->[Management API](https://console.upstash.com/account/api)を開き、`Create API Key`からキーの名前を設定します。

以上の操作によりトークン（`ujbzbppS-azym-7zpe-65r6-jjgvu4jlffyh`といった文字列）が発行されます。

`terraform.tfvars`で、以下のように編集します。

- `upstash_email`の値に登録したアカウントのメールアドレスを入力
- `upstash_api_key`の値を取得したトークンに置き換え
- `upstash_db_name`に識別名をつけます。
- `upstash_db_region`に`ap-northeast-1`を設定します

以下は設定の例です。

```tf:terraform.tfvars
# database vars
upstash_email   = "hoge@mail.com"
upstash_api_key = "ujbzbppS-azym-7zpe-65r6-jjgvu4jlffyh"

upstash_db_name   = "favoExtend-Database"
upstash_db_region = "ap-northeast-1"
```

# その他の設定

Cloudflareで自身のドメインを管理している場合は、APIのURLに自身のドメインを利用することが可能です。

## ドメインを持っていない場合

ドメインを持っていない場合は、`terraform.tfvars`に以下の設定を行います。

- `cloudflare_workers_route_type`の値を`disable`に変更
- 以下の3つの行をコメントアウト(コメントアウト記号は`#`です)
  - `cloudflare_workers_route_domain`
  - `cloudflare_workers_route_custom_domain`
  - `cloudflare_workers_route_pattern`

以下は設定例です。

```tf:terraform.tfvars
## if you enable workers route (exclude subdomain.workers.dev)
## set "domain" or "route". if not, comment-out or set "disable"
cloudflare_workers_route_type   = "disable"
# cloudflare_workers_route_domain = "domain_for_route_workers_script(ex: example.com)"
## set value when cloudflare_workers_route_type == "domain"
# cloudflare_workers_route_custom_domain = "subdomain_to_workers_script(ex: api.example.com)"
## set value when cloudflare_workers_route_type == "route"
# cloudflare_workers_route_pattern = "workers_route_pattern(ex: api.example.com/workers/*)"
```

## ドメインを持っている場合

ドメインを持っていて、自身のドメインにAPIを設定したい場合は、2つの選択肢[^2]があります。

- `api.your.domain.com`のように、サブドメインとして設定する方法
- `your.domain.com/worker/api/`のように、同じオリジンからAPIを伸ばす方法

[^2]: 両方を併用する(`api.example.com/v1/api`など...)はできません。

### サブドメインとしてAPIを設定する場合

`terraform.tfvars`に以下の設定を行います。

- `cloudflare_workers_route_type`の値を`domain`に変更
- `cloudflare_workers_route_domain`にドメイン名を入力
- `cloudflare_workers_route_custom_domain`に、APIにしたいサブドメインを入力
- `cloudflare_workers_route_pattern`をコメントアウト

以下は設定例です。

```tf:terraform.tfvars
## if you enable workers route (exclude subdomain.workers.dev)
## set "domain" or "route". if not, comment-out or set "disable"
cloudflare_workers_route_type   = "domain"
cloudflare_workers_route_domain = "example.com"
## set value when cloudflare_workers_route_type == "domain"
cloudflare_workers_route_custom_domain = "api.example.com"
## set value when cloudflare_workers_route_type == "route"
# cloudflare_workers_route_pattern = "workers_route_pattern(ex: api.example.com/workers/*)"
```

### 同オリジンからAPIを設定する場合

`terraform.tfvars`に以下の設定を行います。

- `cloudflare_workers_route_type`の値を`route`に変更
- `cloudflare_workers_route_domain`にドメイン名を入力
- `cloudflare_workers_route_custom_domain`をコメントアウト
- `cloudflare_workers_route_pattern`にAPIのパスを設定
  - 必ず末尾は`*`で終わらせて、エンドポイントをすべて受け付けるようにしてください。

以下は設定例です。

```tf:terraform.tfvars
## if you enable workers route (exclude subdomain.workers.dev)
## set "domain" or "route". if not, comment-out or set "disable"
cloudflare_workers_route_type   = "route"
cloudflare_workers_route_domain = "example.com"
## set value when cloudflare_workers_route_type == "domain"
# cloudflare_workers_route_custom_domain = "subdomain_to_workers_script(ex: api.example.com)"
## set value when cloudflare_workers_route_type == "route"
cloudflare_workers_route_pattern = "example.com/api/*"
```

---

設定が完了したら`terraform.tfvars`を保存し、次へ進んでください。

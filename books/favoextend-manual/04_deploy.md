---
title: 'とりあえず動かしてみる - デプロイ方法'
---

# デプロイ方法

favoExtendでは、デフォルト状態でも利用可能なように例が設定されています。
これは無設定で動かすことができるので、試しにどういったものか見てみましょう。

`terraform`や`node`を実行できる、シェルやターミナル、コマンドプロンプトなどを開いて...
以下を実行します。

```sh
terraform init
terraform apply
```

`terraform apply`の後、本当に実行するかを尋ねられるため、`yes`+Enterでデプロイします。

以上で、デプロイが完了します。

# 試しにAPIを使ってみる

エンドポイントに対してリクエストを投げると、DBに保存されている情報を整形して出力します。

以下に有効なAPIの一部を示しておきます。

| URL   | メソッド | パラメータ                | 返却値                                                           |
| ----- | -------- | ------------------------- | ---------------------------------------------------------------- |
| /favo | GET      | クエリ: `id=<文字列>`     | `{"count":<数値,データがない場合は"0">}`                         |
| /favo | POST     | Body: `{"id":"<文字列>"}` | `{"count":<数値,前の値に+1>}`                                    |
| /user | GET      | クエリ: `handle=<文字列>` | ユーザが存在する場合は以下<br>`{"name":<文字列>,"count":<数値>}` |

これらの定義はソースコードで言う[apidefs.ts](https://github.com/nkte8/favoExtend/blob/main/api/src/apidefs.ts)に宣言的に記載されています。

`apidefs.ts`については次章でするとして、とりあえずここでは`/favo`へ`GET`を投げてみましょう。

## 前手順でドメインを設定している場合

前手順にてドメインを持っている設定を行った場合は、しばらくしたら有効になります。
`https://your.site.com/favo`へURLクエリー`id`を設定してリクエストを送ってみてください[^1]。
[^1]: `id`の値は初期設定では、半角英数とハイフン・アンダーバーを含む5文字以上のみ受け付けるようになっています。これは[ソースコードのapi/src/apidefs.ts](https://github.com/nkte8/favoExtend/blob/main/api/src/apidefs.ts#L15)で定義されています。

```log: ubuntu/macOSの場合
ubuntu@devsv:~/git/nkte8/favoExtend
>> curl -X GET -H "Content-type: application/json" "https://your.site.com/favo?id=hogefuga"
{"count":0}
```

```log: windowsの場合
PS C:\Users\*****>　curl.exe -X GET -H "Content-type: application/json" "https://your.site.com/favo?id=hogefuga"
{"count":0}
```

## ドメインを設定していない場合

ドメインの設定を行っていない場合は、デプロイしたAPIにエンドポイントへのルートを設定します。

Cloudflareのダッシュボード -> Workers & Pages -> 表示される一覧から`cloudflare_worker_name`で指定した名前の項目を選択します。

メトリクスダッシュボードが開かれるので、設定 -> トリガー -> ルートから`workers.dev`が払い出されているはずなので、これを有効化します。

![Cloneしたファイル](/images/books/favoextend-manual/04_workerroute.png)

初期ではゾーンは`登録時のメールアドレスの名前部.workers.dev`に設定されています。
workers.devの前の文字列は、Workers & Pagesページの右カラムの`サブドメイン`から変更可能です。

以上により記載されているルートへリクエストが可能になります。

```log: ubuntu/macOSの場合
ubuntu@devsv:~/git/nkte8/favoExtend
>> curl -X GET -H "Content-type: application/json" "https://workername.yourprefix.workers.dev/favo?id=hogefuga"
{"count":0}
```

```log: windowsの場合
PS C:\Users\*****>　curl.exe -X GET -H "Content-type: application/json" "https://workername.yourprefix.workers.dev/favo?id=hogefuga"
{"count":0}
```

# 利用を終了したい場合

APIやデータベースを削除する場合は以下のコマンドを実行します。

::: message alert

※**データベースも削除します**。サービス運用を開始した場合は必要に応じてデータベースをUpstash上でマイグレーションをしたり、お手元のRedisクライアントへデータを移管してください。
:::

```sh
terraform destroy
```

`terraform apply`の後、本当に実行するかを尋ねられるため、`yes`+Enterでデストロイします。

以上で削除が完了します。CloudflareやUpstashから情報が消えているはずです。

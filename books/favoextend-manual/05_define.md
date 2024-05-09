---
title: "概要 - APIの定義方法"
---

# APIの定義方法

APIの定義方法は、3つのプロセスを踏んで実装します。

1. API受け口の定義(`Definition`インスタンスの作成)
2. APIサーバの定義(`Extender`拡張クラスの作成)
3. CloudflareWorkerへの読み込み追加(`index.ts`の編集)

## API受け口の定義について

APIは次のように定義します。ご自身のAPI名を`YourExtend`とします。

::: message alert

`api/src/example/favoExtend/apidefs.ts`は参考にはなりますが、直接編集しないでください！
プロジェクトのアップデートにより、リポジトリがコンフリクトする可能性があります。
**かならずご自身のAPI用にディレクトリを切って作業してください**。

:::

```ts: api/src/YourExtend/apidefs.ts
import { Definition } from '@/base/Definition'
import { z } from 'zod'

export const GetIine = new Definition( // <---- わかりやすい名前を設定
    {
        path: '/iine', // <----- エンドポイント、リソース名をつけるのが一般的
        method: 'GET', // <---  httpメソッド
        query: z.object({  // <---- URLクエリ
            id: z.string().regex(idRule),
        }),
        output: { count: '${#0}' },
    },
    [
        {
            keyRef: 'iine/${#.id}', // <---- DBへ書き込むキーの指定
            functionName: 'get', // <---- 実行する関数
            output: z.number().default(0), // <-- アウトプットの定義
        },
    ],
)
```

Definitionクラスは次のように定義されます。

| 引数   | 説明                                         |
| ------ | -------------------------------------------- |
| apiDef | APIの受け口になる定義を記載します            |
| dbDefs | Redis Action(内部で実行する処理)を定義します |

更に、各引数は次のように定義されます。

- `apiDef`のパラメータ

  | 引数   | 必須 | 説明                                                                                                                                                      |
  | ------ | ---- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | path   | o    | APIの受け口となるパスを定義します                                                                                                                         |
  | method | o    | HTTPメソッド(`GET`や`POST`など)を定義します                                                                                                               |
  | query  | x    | Zodオブジェクトで、HTTPリクエストのURLクエリを定義します<br>zodの内部はz.string()のみ定義できます<br>inputが指定された場合はqueryの設定値は無効になります |
  | input  | x    | Zodオブジェクトで、HTTPリクエストのBodyを定義します。<br>queryが同時に設定された場合はinputで入力を上書きします                                           |
  | output | x    | **RelatinType**の形(後述)で、出力を定義します                                                                                                             |

- `dbDefs`のパラメータ

  | 引数         | 必須 | 説明                                                                                                             |
  | ------------ | ---- | ---------------------------------------------------------------------------------------------------------------- |
  | keyRef       | x    | DBに対して操作を行うキーの名前を指定します                                                                       |
  | multiKeysRef | x    | DBに対して操作を行うキーの配列への**RefMarker**(後述)を指定します                                                |
  | functionName | o    | DBに対して操作を行う**関数名**(後述)を指定します                                                                 |
  | input        | x    | RelatinTypeの形で、入力を定義します                                                                              |
  | output       | x    | Zodオブジェクトで、出力を定義します                                                                              |
  | ignoreFail   | x    | 本操作がFailした場合も処理を終了せず、次の処理へ進みます                                                         |
  | ignoreOutput | x    | 本操作の`output`は型が検証されません(outputが保証されません)                                                     |
  | dependFunc   | x    | numberの配列で、依存する処理番号を記載します<br>この値が指定された処理は、依存する処理が失敗した場合はFailします |
  | ifRef        | x    | boolean型を指すRefMarkerを設定します。<br>Falseの場合は処理をスキップします。                                    |
  | opts         | x    | DBに対して操作を行う処理に、追加の入力を指定します                                                               |

### RelationTypeについて

`RelatinType`は次のような形です。

```ts
type RelationType =
  | { [key: string]: RelationType }
  | string
  | number
  | boolean
  | RelationType[];
/* 以下は設定可能な内容
- output: "string"
- output: {
        hoge: "string"
    }
- output: {
        hoge: {
            fuga: "string"
        },
        key: "value"
    }
- output: {
        number: 1000,
        boolean: true
    }
- output: ["value1", "value2", "value3"]
- output: ["value1", { key: "value" }]
*/
```

### RefMarkerについて

`RefMarker`は、入力と出力を接続するためのマーカーです。

| RefMarkerの例       | 説明                                                                 |
| ------------------- | -------------------------------------------------------------------- |
| `"${#}"`            | APIからのinputをそのまま返します                                     |
| `"${#.hoge}"`       | APIからのinputがObjectの場合に、`{hoge: <...>}`から`<...>`を返します |
| `"${#1}"`           | 処理#1のアウトプットをそのまま返します                               |
| `"${#1.hoge.fuga}"` | 処理#1のアウトプットで、`{hoge: {fuga: <...>}}`から`<...>`を返します |

これにより各処理の入力と出力が接続されます。以下はAPI処理の例です。

```ts
export const TestAddRanking = new Definition(
  {
    path: "/addRank",
    method: "POST",
    input: z.object({
      handle: z.string(),
    }),
    output: { rank: "${#2}" }, // <-- 処理#2 の結果を { rank: <...>}の<...>へ代入
  },
  [
    {
      keyRef: "user/${#.handle}/*", // <-- inputの handle 値を keyRef に代入
      functionName: "incrSum",
      output: z.number().default(0),
    },
    {
      keyRef: "rank/favo",
      functionName: "zaddSingle",
      input: {
        score: "${#0}", // <-- 処理#0(incrSum)の結果を score の値に代入
        member: "${#.handle}", // <-- inputのhandle値を member に代入
      },
    },
    {
      keyRef: "rank/favo",
      functionName: "zrevrank",
      input: "${#.handle}", // <-- inputのhandle値を member に代入
      output: z.number(),
    },
  ]
);
```

### 関数名について

実行できる処理(Redis Action)は以下から選択して使います。

- `Redis`のラッパー(Redisが扱っている関数の一部を利用可能です)

  | 関数名   | 説明                                                                                                                                                                    |
  | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | del      | [UpstashRedis DELのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/generic/del)<br>DBからキーを削除します                                             |
  | incr     | [UpstashRedis INCRのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/string/incr)<br>対象のデータ値を1増やします                                       |
  | mget     | [UpstashRedis MGETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/string/mget)<br>複数のキーのString値を取得します                                  |
  | get      | [UpstashRedis GETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/string/get)<br>String値を取得します                                                |
  | set      | [UpstashRedis SETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/string/set)<br>String値を設定します                                                |
  | jsonGet  | [UpstashRedis JSON.GETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/json/get)<br>JSON値を取得します                                               |
  | jsonMget | [UpstashRedis JSON.MGETのラッパーです](https://upstash.com/docs/oss/sdks/py/redis/commands/json/mget)<br>複数のキーのJSON値を取得します                                 |
  | jsonSet  | [UpstashRedis JSON.SETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/json/set)<br>JSON値を設定します                                               |
  | jsonDel  | [UpstashRedis JSON.DELのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/json/del)<br>JSON値を削除します                                               |
  | scan     | [UpstashRedis SCANのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/generic/scan)<br>条件に一致するキーをワイルドカードで取得します                   |
  | zadd     | [UpstashRedis ZADDのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zadd)<br>SortedSetへ値を追加します                                           |
  | zrem     | [UpstashRedis ZREMのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zrem)<br>SortedSetの値を削除します                                           |
  | zrank    | [UpstashRedis ZRANKのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zrank)<br>SortedSetが昇順でランキングのどの位置にいるのかを取得します       |
  | zrevrank | [UpstashRedis ZREVRANKのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zrevrank)<br>SortedSetが降順でランキングのどの位置にいるのかを取得します |
  | zrange   | [UpstashRedis ZRANGEのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zrange)<br>SortedSetを範囲指定、昇順(または降順)で配列を取得します         |

- `Redis`のラッパーの拡張

  | 関数名        | 説明                                                       |
  | ------------- | ---------------------------------------------------------- |
  | getThrowError | String値を取得します。値がない場合はエラーを返します       |
  | incrSum       | キーパターンを指定し、マッチするキーの値の総計を取得します |
  | scanRegex     | 条件に一致するキーを正規表現で取得します                   |
  | typeGrep      | 複数のキーから、指定したタイプの値を持つキーを抽出します   |
  | zaddSingle    | SortedSetへ単一の値を追加します                            |
  | zremSingle    | SortedSetの単一の値を削除します                            |

- その他、処理を接続するための処理
  | 関数名 | 説明 |
  | ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | objectExtract | Object in Arrayを展開し、Array in Objectにして出力します。以下は例です<br>`{hoge: ["a","b","c"],fuga: [100,300,500]}`<br> → `[{hoge: "a", fuga: 100},{hoge: "b", fuga: 300},{hoge: "c", fuga: 500}]` |
  | arrayReplace | Arrayの中の値を正規表現で置き換え処理を行い、その結果を出力します |
  | defineRef | Inputをパススルーします。<br>固定値を定義したり、RefMarkerをObjectに変換し、後続処理へ渡すために使います |
  | numSum | 数値の配列から合計を出力します。 |
  | numAvg | 数値の配列から平均を出力します。 |

関数はある程度決まった入力と出力を要求しますので、それに沿った形で関数を接続していきます。  
詳しい関数仕様については後述します。上記に必要な処理がない場合は、拡張を行う必要があります。

## APIサーバの定義について

定義したAPIはクラスを作成して追加処理をおこないます。

`api/src/example/favoExtend`を参考に、クラスを定義します。  
例えば`api/src/YourExtend/index.ts`を作成し、以下のように作成します。

`Definitions`では前手順で`Definition`を使って定義したAPI定義を入力します。

```ts: api/src/YourExtend/index.ts
import { Extender } from '@/base/Extender'
import * as defs from './apidefs' // <--- 作成したDefinitionをimport

export default class YourExtend extends Extender {
  constructor(env: {
    UPSTASH_REDIS_REST_URL: string
    UPSTASH_REDIS_REST_TOKEN: string
  }) {
    const Definitions = [
      defs.GetIine,
    ]
    super(env, Definitions) // <---- GetIine APIを読み込ませる
  }
}
```

## CloudflareWorkerへの読み込み追加

定義したクラスを`api/src/index.ts`に読み込ませる処理を記載します。

```ts
import { HeadersInit } from '@cloudflare/workers-types/experimental'
import YourExtend from './example/YourExtend' //<--- YourExtend の Importを追加

export interface Env {
    UPSTASH_REDIS_REST_URL: string
    UPSTASH_REDIS_REST_TOKEN: string
    CORS_ALLOW_ORIGIN: string
}

export default {
    async fetch(request: Request, env: Env): Promise<Response> {

...(中略)

        // create client example
        const Client = new YourExtend({ // <------ 作成したクラスをClientとして定義
            UPSTASH_REDIS_REST_URL: env.UPSTASH_REDIS_REST_URL,
            UPSTASH_REDIS_REST_TOKEN: env.UPSTASH_REDIS_REST_TOKEN,
        })

        const response: Response = await Client.createResponse(request, header)
        return response
    },
}
```

---

以上のようにファイルを設定したあと、前章の`デプロイ方法`を実施すれば、`YourExtend`で定義したAPIが構築されます。お疲れ様でした！

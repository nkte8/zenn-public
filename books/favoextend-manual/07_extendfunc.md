---
title: '拡張方法 - 独自関数の定義方法'
---

# 独自関数の定義方法

関数を独自で定義する方法を記載します。

## 拡張クラスの定義

前章で作成されたご自身で定義されたクラス`YourExtend.ts`を例に記載します。

```ts: api/src/YourExtend/index.ts
import { Extender } from '@/base/Extender'
import * as defs from './apidefs'

export default class YourExtend extends Extender {
  constructor(env: {
    UPSTASH_REDIS_REST_URL: string
    UPSTASH_REDIS_REST_TOKEN: string
  }) {
    const Definitions = [
      defs.GetIine,
    ]
    super(env, Definitions)
  }
}
```

## 関数タイプを指定

定義する関数は以下のタイプのいずれかに所属する必要があります。

```ts
type methodType = {
  [x: string]:
    | {
        kind: 'method'
        function: (opts?: JsonObj) => Promise<JsonType>
      }
    | {
        kind: 'keyOnly'
        function: (key: string, opts?: JsonObj) => Promise<JsonType>
      }
    | {
        kind: 'literal'
        function: (
          key: string,
          str: JsonLiteral,
          opts?: JsonObj,
        ) => Promise<JsonType>
      }
    | {
        kind: 'multiKey'
        function: (key: string[], opts?: JsonObj) => Promise<JsonType>
      }
    | {
        kind: 'object'
        function: <T extends JsonObj>(
          key: string,
          data: T,
          opts?: JsonObj,
        ) => Promise<JsonType>
      }
    | {
        kind: 'array'
        function: <T extends JsonType[]>(
          key: string,
          data: T,
          opts?: JsonObj,
        ) => Promise<JsonType>
      }
    | {
        kind: 'any'
        function: <T extends JsonType>(
          key: string,
          data: T,
          opts?: JsonObj,
        ) => Promise<JsonType>
      }
    | {
        kind: 'anyNokey'
        function: <T extends JsonType>(
          data: T,
          opts?: JsonObj,
        ) => Promise<JsonType>
      }
    | {
        kind: 'literalNokey'
        function: (data: JsonLiteral, opts?: JsonObj) => Promise<JsonType>
      }
    | {
        kind: 'arrayNokey'
        function: <T extends JsonType[]>(
          data: T,
          opts?: JsonObj,
        ) => Promise<JsonType>
      }
    | {
        kind: 'objectNokey'
        function: <T extends JsonObj>(
          data: T,
          opts?: JsonObj,
        ) => Promise<JsonType>
      }
}
```

使用する引数は、以下のような基準で選定します。

| 引数名              | 説明                                                                                     |
| ------------------- | ---------------------------------------------------------------------------------------- |
| key: `string`       | Redisから情報を取得したり登録したりする際のキー入力として利用します。                    |
| data: `T(JsonType)` | Redisに限らず、処理に情報を入力する必要がある場合に利用します。                          |
| opts: `JsonObj`     | 処理のオプションとしての入力として設定します。<br>この値は省略可能である必要があります。 |

選定例を記載します

- DBへ情報を登録する必要がある

  - データは文字列である → stringはJsonLiteralに所属する: `kind: literal`を選択
  - データは配列である → ArrayはJsonType[]に所属する: `kind: array`を選択
  - データはKey-Valueである → ObjectはLiteralに所属する: `kind: object`を選択

- 入力を受けて何かしらを判定する → DBを操作しない

  - 判定するデータは文字列 → stringはJsonLiteralに所属する: `kind: literalNokey`を選択
  - 判定するデータは配列 → ArrayはJsonType[]に所属する: `kind: arrayNokey`を選択
  - 判定するデータはKey-Value → ObjectはLiteralに所属する: `kind: objectNokey`を選択

- 入力を受けず何かしらの処理をトリガーする → DBを操作しない
  - 入力がない → `kind: method`を選択

記載の通り、`opts`を入力に扱うことは基本的にはせず、入力は`input`を用います。
処理に幅を効かせたい場合などに`opts`を関数内で呼び出して使用してください。

## 関数を作成

以下は`favoExtend`の`generateToken`関数の例です。

```ts
/**
 * Extend example: Generate token
 * @param key db key
 * @param input info for auth
 */
generateToken = async (key: string): Promise<string> => {
  try {
    // when you define function, recommend validation
    this.verifyKey(key)
    const token = crypto.randomUUID()
    const result: string | null = await this.Redis.set(key, token, {
      ex: 3600 * 24 * 7,
    })
    if (result !== 'OK') {
      throw new ExtendError({
        message: `Failed to SET value by redis client`,
        status: 500,
        name: 'Generate Token Failed',
      })
    }
    return token
  } catch (e: unknown) {
    if (e instanceof ExtendError) {
      throw e
    } else if (e instanceof Error) {
      throw new ExtendError({
        message: e.message,
        status: 500,
        name: e.name,
      })
    }
    throw new Error('Unexpected Error')
  }
}
```

- キーを用いる場合、`this.verifyKey(key)`を利用することをおすすめします。
  - キー名にスラッシュが重複する場合(`hogehoge//fuga`)を除外します。
- `this.Redis`からUpstash Redisクライアントを呼び出すことができます。
  - クライアントの利用方法については[こちらに記載されています](https://upstash.com/docs/oss/sdks/ts/redis/overview)（英語です）
- `try {} catch {}`でエラーハンドリングをすることをおすすめします。
  - `ExtendError`の`status`が`500~599`の場合、ユーザ向けには一貫して`Server Error`として出力します。
    - 内部ログでは`<name>: <message>`の内容が出力されます。
    - `500~599`ではない場合は、ユーザに対してエラーを表示します
  - `ExtendError`ではないエラーについては、statusが自動的に`500`が設定されます。
- 関数の戻り値については、ReactActionで定義された`output`のZodオブジェクトを用いて検証されるため、関数で厳密に絞る必要はありません
  - ただしコードのみやすさとして、きちんと記載することをおすすめします。

## 関数の追加処理を追加

関数を定義したら、作成したクラスで追加処理を行います。

以下は`generateToken`を追加する例です。

```ts: api/src/YourExtend/index.ts
import { Extender } from '@/base/Extender'
import * as defs from './apidefs'

export default class YourExtend extends Extender {
  constructor(env: {
    UPSTASH_REDIS_REST_URL: string
    UPSTASH_REDIS_REST_TOKEN: string
  }) {
    const Definitions = [
      defs.GetIine,
    ]
    super(env, Definitions)
    // ----- ここから追記
    this.addMethod({
        generateToken: {
            kind: 'keyOnly',
            function: this.generateToken,
        },
    })
    // ----- ここまで追記
  }
}
```

以上でメソッドが認識されるようになり、`Definition`から利用することが出来ます。

# 関数のテスト方法

apiResult関数を用いた疑似テストとCloudflare:testを用いた実証テストがあります。

いずれの場合も、開発用に`Upstash Redis`のデータベースを別途作成してください。データベースのMockは執筆現在は提供していません。

## 疑似テスト

疑似テストは本番コードにAPI定義を追加する必要がないことから、開発中のAPIや、本番環境に含めないAPIなどのテストに適しています。

`Extender`により提供される`apiResult`関数は、Cloudflare workerにラップされる前の処理結果を提供します。そのため、500系エラーについても本文通り出力されます。

```ts
import { env } from 'cloudflare:test'
import { describe, it, expect } from 'vitest'
import { FavoExtend } from '@/YourExtend'
import * as defs from '@/YourExtend/apidefs'
import { Redis } from '@upstash/redis/cloudflare'

const MockClient = new YourExtend(env, [ // <---- Mock用クライアントを容易
    defs.GetIine,
])

const RedisClient = new Redis({  // <----- Redis本体のクライアントを（検証値用に用意）
    url: env.UPSTASH_REDIS_REST_URL,
    token: env.UPSTASH_REDIS_REST_TOKEN,
})

describe('API test', () => {
    it('[Positive] POST create mock-user test', async () => {
        const apiResult = await MockClient.apiResult({
            httpMethod: 'GET',
            requestUrl: new URL('https://example.com/iine?id=pageid'),
            // input: {  // <--- bodyを追加する場合は、このように追加
            //     your1: 'parameter1',
            //     your2: 'parameter2',
            // },
        })
        const dbResult = await RedisClient.get("iine/pageid")
        expect(apiResult).toMatchObject({
            count: dbResult,
        })
    })
    ...
})
```

## 実証テスト

本番環境向けに展開する予定のある関数では`cloudflare:test`を用いた実証テストを行ってください。

```ts
// test/index.spec.ts
// integration styleで記載する際は SELF をimport
import { env, SELF } from 'cloudflare:test'
import { describe, it, expect } from 'vitest'

// unit styleで記載する場合は worker をimport
import worker from '../src/index'
import { Redis } from '@upstash/redis/cloudflare'

const RedisClient = new Redis({
    url: env.UPSTASH_REDIS_REST_URL,
    token: env.UPSTASH_REDIS_REST_TOKEN,
})
describe('API test', () => {
    // unit style
    it('[Negative] Access direct test', async () => {
        const request = new Request('https://example.com', { method: 'GET' })
        const response = await worker.fetch(request, env)
        expect(await response.json()).toMatchObject({
            error: 'Invalid Request',
            message: 'Invalid Content-type Request received',
        })
    })
    // integration style
    it('[Positive] GET iine test', async () => {
        const response = await SELF.fetch(
            'https://example.com/iine?id=pageid',
            {
                method: 'GET',
                headers: {
                    'Content-type': 'application/json',
                },
            },
        )
        const apiResult = await response.json()
        const dbResult = await RedisClient.get("iine/pageid")
        expect(apiResult).toMatchObject({
            count: dbResult,
        })
    })
    ...
})
```

テストは`unit stype`と`integration style`のいずれかから選択できます。お好きな方を採用してください。`index.spec.ts`については初めの例示以外はすべて`integration style`で記載しています。

実証テストの場合はCloudflareに結果がラップされるため、500系のエラーはすべて`ServerError`として出力されます。例外は以下のように定義されます。

```ts
if (ex.status >= 500 && ex.status < 600) {
  // <--- statusが500~599の場合は
  ex.name = 'Server Error' //  name と message を上書きする
  ex.message = 'Unexpected Server Error'
}
response = new Response(
  JSON.stringify({
    error: ex.name,
    message: ex.message,
  }),
  { status: ex.status, headers }, // <--- statusの値は上書きしない
)
```

Objectとしては以下のように返却されます

```json
// 500~599の場合（固定）
{
  "error": "Server Error",
  "message": "Unexpected Server Error"
}
// 500~599ではない場合
{
  "error": "関数内で定義されたエラーの名称",
  "message": "関数内で定義されたエラーの詳細"
}
```

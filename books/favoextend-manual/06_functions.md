---
title: '関数仕様 - 処理に設定するオプション'
---

# 処理に設定するオプション

デフォルトで利用できる関数に指定する仕様になります。3つのカテゴリに大分類しています。

- `Redis`のラッパー: Redisの関数をそのまま起こしたような処理です
- `Redis`ラッパーの拡張: Redisの関数をより便利なように拡張した関数です
- その他、処理を接続するための処理: 処理フローを簡単にするために定義された関数です

## `Redis`のラッパー

RedisコマンドをほぼそのままAPIに落とし込んだ内容です。

### del

[UpstashRedis DELのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/generic/del)。DBからキーを削除します

| 必要パラメータ | 説明                     |
| -------------- | ------------------------ |
| functionName   | `del`                    |
| keyRef         | 削除するキーを指定します |

設定例:

```ts
[
  {
    keyRef: 'favo/${#.id}',
    functionName: 'del',
  },
],
```

### incr

[UpstashRedis INCRのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/string/incr)。対象のデータ値を1増やします

| 必要パラメータ | 説明                             |
| -------------- | -------------------------------- |
| functionName   | `incr`                           |
| keyRef         | データ値を増やすキーを指定します |

設定例:

```ts
[
  {
    keyRef: 'favo/${#.id}',
    functionName: 'incr',
  },
],
```

### mget

[UpstashRedis MGETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/string/mget)。複数のキーのString値を取得します

| 必要パラメータ | 説明                                                                 |
| -------------- | -------------------------------------------------------------------- |
| functionName   | `mget`                                                               |
| multiKeysRef   | データ値を追加するキーのArrayを指す`RefMarker`を指定します           |
| output         | DBに格納されたデータ内容を定義します(基本的には`z.string().array()`) |

設定例:

```ts
[
  {
    functionName: 'defineRef',
    input: ["key1","key2","key3"],
    output: z.string().array()
  },
  {
    multiKeysRef: '${#0}',
    functionName: 'mget',
    output: z.string().array()
  },
],
```

### get

[UpstashRedis GETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/string/get)。string値を取得します

| 必要パラメータ | 説明                                                         |
| -------------- | ------------------------------------------------------------ |
| functionName   | `get`                                                        |
| keyRef         | データ値を取得するキーを設定します                           |
| output         | DBに格納されたデータ内容を定義します(基本的には`z.string()`) |

設定例:

```ts
[
  {
    keyRef: "keyname",
    functionName: 'get',
    output: z.string()
  },
],
```

### set

[UpstashRedis SETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/string/set)。String値を設定します

| 必要パラメータ | 説明                                                     |
| -------------- | -------------------------------------------------------- |
| functionName   | `set`                                                    |
| keyRef         | データ値を増やすキーのArrayを指す`RefMarker`を指定します |
| input          | DBに格納するデータ内容を定義します                       |
| opts           | RedisのSETコマンドオプションを指定します。               |

設定例:

```ts
[
  {
    keyRef: "keyname",
    functionName: 'set',
    input: "hogefuga"
  },
],
// RefMarkerを利用する場合
[
  {
    functionName: 'defineRef',
    input: "test",
    output: z.string()
  },
  {
    keyRef: "keyname",
    functionName: 'set',
    input: "${#0}"
  },
],
```

### jsonGet

[UpstashRedis JSON.GETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/json/get)。JSON値を取得します

| 必要パラメータ | 説明                                                                                |
| -------------- | ----------------------------------------------------------------------------------- |
| functionName   | `jsonGet`                                                                           |
| keyRef         | データ値を取得するキーを設定します                                                  |
| opts.path      | Jsonで取得する値までのパスを指定します。<br>デフォルトではルート(`$`)が設定されます |
| output         | DBに格納されたデータ内容を定義します。                                              |

設定例:

```ts
[
  {
    keyRef: "keyname",
    functionName: 'jsonGet',
    opts: {
      path: "$"
    },
    output: z.object({
      value: z.object({
        hoge: z.string()
      })
    })
  },
],
// { value: { hoge: "fuga"}} から"fuga"を取得する場合
[
  {
    keyRef: "keyname",
    functionName: 'jsonGet',
    opts: {
      path: "$.value.hoge"
    },
    output: z.string()
  },
],
```

### jsonMget

[UpstashRedis JSON.MGETのラッパーです](https://upstash.com/docs/oss/sdks/py/redis/commands/json/mget)。複数のキーのJSON値を取得します

| 必要パラメータ | 説明                                                                                |
| -------------- | ----------------------------------------------------------------------------------- |
| functionName   | `jsonMget`                                                                          |
| multiKeysRef   | データ値を追加するキーのArrayを指す`RefMarker`を指定します                          |
| opts.path      | Jsonで取得する値までのパスを指定します。<br>デフォルトではルート(`$`)が設定されます |
| output         | DBに格納されたデータ内容を定義します。                                              |

設定例:

```ts
[
  {
    functionName: 'defineRef',
    input: ["key1","key2","key3"],
    output: z.string().array()
  },
  {
    multiKeysRef: "${#0}",
    functionName: 'jsonMget',
    opts: {
      path: "$"
    },
    output: z.object({
      value: z.object({
        hoge: z.string()
      })
    })
  },
],
```

### jsonSet

[UpstashRedis JSON.SETのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/json/set)。JSON値を設定します

| 必要パラメータ | 説明                                                                                |
| -------------- | ----------------------------------------------------------------------------------- |
| functionName   | `jsonSet`                                                                           |
| keyRef         | データ値で置き換えるキーを設定します                                                |
| opts.path      | Jsonで設定する値までのパスを指定します。<br>デフォルトではルート(`$`)が設定されます |
| input          | DBに格納するデータ内容を定義します。                                                |

設定例:

```ts
// DBの { huga: <...> }の<...>値を "置き換える"
// <...>内に{ data2: <...>, data3: <...> } が存在した場合
// { data1: "value1", data2: "value2"}のような状態になる （opts.pathをinputで置き換える)
[
  {
    keyRef: "keyname",
    functionName: 'jsonSet',
    input: {
      data1: "value1",
      data2: "value2"
    },
    opts: {
      path: "$.huga"
    },
  },
],
// RefMarkerを利用する場合
[
  {
    functionName: 'defineRef',
    input: {
      data1: "value1",
      data2: "value2"
    },
    output: z.object({
      data1: z.string(),
      data2: z.string(),
    })
  },
  {
    keyRef: "keyname",
    functionName: 'jsonSet',
    input: "${#0}"
  },
],
```

### jsonDel

[UpstashRedis JSON.DELのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/json/del)。JSON値を削除します

| 必要パラメータ | 説明                                                                                |
| -------------- | ----------------------------------------------------------------------------------- |
| functionName   | `jsonSet`                                                                           |
| keyRef         | データ値を削除するキーを設定します                                                  |
| opts.path      | Jsonで設定する値までのパスを指定します。<br>デフォルトではルート(`$`)が設定されます |

設定例:

```ts
// DBの { huga: <...> }の<...>値を削除する
[
  {
    keyRef: "keyname",
    functionName: 'jsonDel',
    opts: {
      path: "$.huga"
    },
  },
],
```

### zadd

[UpstashRedis ZADDのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zadd)。SortedSetへ値を追加します

| 必要パラメータ | 説明                                                                                         |
| -------------- | -------------------------------------------------------------------------------------------- |
| functionName   | `zadd`                                                                                       |
| keyRef         | データ値を設定するキーを設定します。                                                         |
| input          | SortedSetへ登録する型`{score: <number>,member: <string>}`の配列またはRefMarkerを指定します。 |
| opts           | RedisのZADDコマンドオプションを指定します。                                                  |

設定例:

```ts
// ranking キーに2つのユーザを登録する
[
  {
    keyRef: "ranking",
    functionName: 'zadd',
    input: [
      {
        score: 100,
        member: "test1"
      },
      {
        score: 200,
        member: "test2"
      },
    ]
  },
],
```

### zrem

[UpstashRedis ZREMのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zrem)。SortedSetの値を削除します

| 必要パラメータ | 説明                                                                                   |
| -------------- | -------------------------------------------------------------------------------------- |
| functionName   | `zrem`                                                                                 |
| keyRef         | データ値を削除するキーを設定します。                                                   |
| input          | SortedSetで削除するメンバの配列`["member1","member2"...]`またはRefMarkerを指定します。 |

設定例:

```ts
// ranking キーから２つのメンバ "test1","test2" を削除する
[
  {
    keyRef: "ranking",
    functionName: 'zrem',
    input: ["test1","test2"]
  },
],
```

### zrank

[UpstashRedis ZRANKのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zrank)。SortedSetが昇順でランキングのどの位置にいるのかを取得します

| 必要パラメータ | 説明                                                      |
| -------------- | --------------------------------------------------------- |
| functionName   | `zrank`                                                   |
| keyRef         | データ値を取得するキーを設定します。                      |
| input          | SortedSetでランキング位置を取得したいメンバを設定します。 |
| output         | `z.number()`を指定します。                                |

設定例:

```ts
// ranking キーの"test1"の位置を取得する
[
  {
    keyRef: "ranking",
    functionName: 'zrank',
    input: "test1",
    output: z.number()
  },
],
```

### zrevrank

[UpstashRedis ZREVRANKのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zrevrank)。SortedSetが降順でランキングのどの位置にいるのかを取得します。

| 必要パラメータ | 説明                                                      |
| -------------- | --------------------------------------------------------- |
| functionName   | `zrevrank`                                                |
| keyRef         | データ値を取得するキーを設定します。                      |
| input          | SortedSetでランキング位置を取得したいメンバを設定します。 |
| output         | `z.number()`を指定します。                                |

設定例:

```ts
// ranking キーの"test1"の位置を取得する
[
  {
    keyRef: "ranking",
    functionName: 'zrevrank',
    input: "test1",
    output: z.number()
  },
],
```

### zrange

[UpstashRedis ZRANGEのラッパーです](https://upstash.com/docs/oss/sdks/ts/redis/commands/zset/zrange)。SortedSetを範囲指定、昇順(または降順)で配列を取得します

| 必要パラメータ | 説明                                                                                         |
| -------------- | -------------------------------------------------------------------------------------------- |
| functionName   | `zrange`                                                                                     |
| keyRef         | データ値を取得するキーを設定します。                                                         |
| input          | SortedSetから取得する範囲を次の形で示します<br>`{min: <取得開始位置>, max: <取得終了位置> }` |
| output         | `z.string().array()`を指定します。                                                           |
| opts           | RedisのZRANGEコマンドオプションを指定します。                                                |

設定例:

```ts
// ranking キーのデータを昇順にすべて取得する
[
  {
    keyRef: "ranking",
    functionName: 'zrange',
    input: {
      min: 0,
      max: -1
    },
    output: z.number()
  },
],
// ranking キーのデータを降順ですべて取得する
[
  {
    keyRef: "ranking",
    functionName: 'zrange',
    input: {
      min: 0,
      max: -1
    },
    opts: {
      rev: true
    },
    output: z.number()
  },
],
```

## `Redis`ラッパーの拡張

Redisのコマンドをより扱いやすくしたり、機能を拡張した関数です。

### getThrowError

String値を取得します。値がない場合はエラーを返します。  
ただし、通常の`get`についても`output`の型が一致しない場合は停止します。本関数はエラーとして`404 Not Found`を返すため、これをユーザに見せる必要がある場合に利用します。

| 必要パラメータ | 説明                                                         |
| -------------- | ------------------------------------------------------------ |
| functionName   | `getThrowError`                                              |
| keyRef         | データ値を取得するキーを設定します                           |
| output         | DBに格納されたデータ内容を定義します(基本的には`z.string()`) |

設定例:

```ts
[
  {
    keyRef: 'keyname',
    functionName: 'getThrowError',
    output: z.string(),
  },
],
  // 上記が存在しない場合、以下のエラーをスローし、処理が止まる
  // ExtendError({
  //   message: `Data not found.`,
  //   status: 404,
  //   name: 'Not Found',
  // })
```

### jsonSetSafe

JSON値を設定します。設定したパスに他の値があっても、jsonSetのように置き換えを行わず、追加または更新の処理を行います。

| 必要パラメータ | 説明                                                                                |
| -------------- | ----------------------------------------------------------------------------------- |
| functionName   | `jsonSet`                                                                           |
| keyRef         | データ値を追加・更新するキーを設定します                                            |
| opts.path      | Jsonで設定する値までのパスを指定します。<br>デフォルトではルート(`$`)が設定されます |
| input          | DBに格納するデータ内容を定義します。                                                |

設定例:

```ts
// DBの { huga: <...> }の<...>値を "追加または更新" する。
// <...>内に{ data2: <...>, data3: <...> } が存在した場合
// { data1: "value1", data2: "value2", data3: <...> }のような状態になる（opts.pathへ値を追加する）
[
  {
    keyRef: "keyname",
    functionName: 'jsonSetSafe',
    input: {
      data1: "value1",
      data2: "value2"
    },
    opts: {
      path: "$.huga"
    },
  },
],
```

### incrSum

キーパターンを指定し、マッチするキーの値の総計を取得します。
複数のキーで`incr`の値を管理している場合に利用すると、複数のキーの`incr`値の合計を取得できます。

| 必要パラメータ | 説明                                                                 |
| -------------- | -------------------------------------------------------------------- |
| functionName   | `incrSum`                                                            |
| keyRef         | キー検索するパターンを、ワイルドカードで指定した文字列を入力します。 |
| output         | `z.number()`を設定します                                             |

設定例:

```ts
[
  {
    keyRef: 'keyname',
    functionName: 'getThrowError',
    output: z.string(),
  },
],
  // 上記が存在しない場合、以下のエラーをスローし、処理が止まる
  // ExtendError({
  //   message: `Data not found.`,
  //   status: 404,
  //   name: 'Not Found',
  // })
```

### incrSumMultiKeys

キーパターンの配列を指定し、マッチするキーの値の総計の配列を取得します。
incrSumのラッパーで、複数のキーパターンを一気に検証します。

| 必要パラメータ | 説明                                                                       |
| -------------- | -------------------------------------------------------------------------- |
| functionName   | `incrSumMultiKeys`                                                         |
| multiKeysRef   | キー検索するパターンを、ワイルドカードで指定した文字列の配列を入力します。 |
| output         | `z.number().array()`を設定します                                           |

設定例:

```ts
[
    {
        keyRef: '^user/[^\\/]+$',
        functionName: 'scanRegex',
        output: z.string().array(),
    },
    {
        functionName: 'arrayReplace',
        opts: {
            array: '${#0}', // <---- scanRegexで指定された配列
            regex: '.*',
            replace: '$&/*', // <--- 文末に /* を付与し、ワイルドカードパターンに変換
        },
        output: z.string().array(),
    },
    {
        functionName: 'incrSumMultiKeys',
        multiKeysRef: '${#1}', // <---- パターンの配列を利用
        output: z.number().array(),
    },
],
```

### scanAll

条件に一致するキーをワイルドカードで取得します。[UpstashRedis SCAN](https://upstash.com/docs/oss/sdks/ts/redis/commands/generic/scan)で、カーソルの位置が0になるまで（=条件に一致するすべてのキーを取得するまで）処理を行います。

| 必要パラメータ | 説明                                                             |
| -------------- | ---------------------------------------------------------------- |
| functionName   | `scan`                                                           |
| keyRef         | キー検索するパターンを、ワイルドカードで指定します。             |
| output         | DBに格納されたデータ内容を定義します(`z.string().array()`を指定) |

設定例:

```ts
// keyname/* を検索する、 keyname/hoge keyname/hoge/fuga　 などがArrayで取得できる
[
  {
    keyRef: "keyname/*",
    functionName: 'scan',
    output: z.string().array(),
  },
],
```

### scanRegex

キーパターンを正規表現で指定し、条件に一致するキーを正規表現で取得します。カーソルの位置が0になるまで（=条件に一致するすべてのキーを取得するまで）処理を行います。  
動作効率のため、内部で正規表現を一度ワイルドカードに置き換えて絞り込みを行い、そこから更に正規表現でキーの絞り込みを行っています。

| 必要パラメータ | 説明                                           |
| -------------- | ---------------------------------------------- |
| functionName   | `scanRegex`                                    |
| keyRef         | キー検索するパターンを、正規表現で指定します。 |
| output         | `z.string().array()`を設定します               |

設定例:

```ts
// keyRefへ正規表現で指定できる
[
  {
    keyRef: '^user/[^\\/]+$',
    functionName: 'scanRegex',
    output: z.string().array(),
  },
],
```

### typeGrep

キー配列から指定の型を持つキーを抽出します。`scan`や`scanRegex`ではキーのパターンが一致していれば、命名規則や取得方法によっては型が混同してしまいます。
`mget`や`jsonGet`、`zrange`など、一定の型を使う必要がある関数において、意図しないキーを処理に送らないようにフィルタリングするために使用します。

| 必要パラメータ | 説明                                                             |
| -------------- | ---------------------------------------------------------------- |
| functionName   | `typeGrep`                                                       |
| input          | `{key: <Array>, type: <Type>}`の形で指定する必要があります       |
| input.key      | 抽出を行うキーの配列、またはRefMarkerを指定します                |
| input.type     | `string`,`list`,`set`,`zset`,`hash`,`json`,`none` から選択します |
| output         | `z.string().array()`を設定します                                 |

設定例:

```ts
// 以下は処理#0(token/*でキーのリストを取得)の結果から、string型を抽出します。
[
  {
    keyRef: 'token/*',
    functionName: 'scan',
    output: z.string().array(),
  },
  {
    functionName: 'typeGrep',
    output: z.string().array(),
    opts: {
        keys: '${#0}',
        type: 'string',
    },
  },
],
```

### zaddSingle

SortedSetへ単一の値を追加します。

| 必要パラメータ | 説明                                                                                   |
| -------------- | -------------------------------------------------------------------------------------- |
| functionName   | `zaddSingle`                                                                           |
| keyRef         | データ値を設定するキーを設定します。                                                   |
| input          | SortedSetへ登録する型`{score: <number>,member: <string>}`またはRefMarkerを指定します。 |
| opts           | RedisのZADDコマンドオプションを指定します。                                            |

設定例:

```ts
// 処理#0(user/${#.handle}/*の数値の合計)を`rank/favo`へ単一登録する
[
  {
      keyRef: 'user/${#.handle}/*',
      functionName: 'incrSum',
      output: z.number().default(0),
  },
  {
      keyRef: 'rank/favo',
      functionName: 'zaddSingle',
      input: {
          score: '${#0}',
          member: '${#.handle}',
      },
  },
],
```

### zremSingle

SortedSetの単一の値を削除します。

| 必要パラメータ | 説明                                                     |
| -------------- | -------------------------------------------------------- |
| functionName   | `zrem`                                                   |
| keyRef         | データ値を削除するキーを設定します。                     |
| input          | SortedSetで削除するメンバ名またはRefMarkerを指定します。 |

設定例:

```ts
// rank/favoからqueryまたはinput(object)のhandle値の内容を削除
[
  {
      keyRef: 'rank/favo',
      functionName: 'zremSingle',
      input: '${#.handle}',
  },
],
```

## その他、処理を接続するための処理

処理を接続する際、データを追加処理する中間処理を提供します。

### objectExtract

Object in Arrayを展開し、Array in Objectにして出力します。
例えば以下の値は...

```json
{ "hoge": ["a", "b", "c"], "fuga": [100, 300, 500] }
```

以下のように変換されます。

```json
[
  { "hoge": "a", "fuga": 100 },
  { "hoge": "b", "fuga": 300 },
  { "hoge": "c", "fuga": 500 }
]
```

| 必要パラメータ | 説明                                                   |
| -------------- | ------------------------------------------------------ |
| functionName   | `objectExtract`                                        |
| input          | 任意の個数の `{key: <Array>}`を入力します。            |
| output         | `z.object({key: <Arrayの単一型>}).array()`を指定します |

設定例:

以下では `[100,200,300,400]`といった配列と`["a","b","c","d"]`といった配列に`score`,`member`の**名前をつけて**合成、`{score:100,member:"a"}`といったObjectにマージして配列として出力しています。

```ts
// 処理#1と処理#2において配列が出力となっている内容を、zaddに入力できる形に変換する
[
  {
      functionName: 'objectExtract',
      input: {
          score: '${#1}', // <--- ${#1}は配列となる処理
          member: '${#2}', // <--- ${#2}は配列となる処理
      },
      output: z
          .object({
              score: z.number(),
              member: z.string(),
          })
          .array(),
  },
  {
      keyRef: 'rank/favo',
      functionName: 'zadd',
      input: '${#3}',
  },
],
```

### arrayReplace

Arrayの中の値を正規表現で置き換え処理を行い、その結果を出力します。

| 必要パラメータ | 説明                                                                                                                                                                    |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| functionName   | `arrayReplace`                                                                                                                                                          |
| input          | `{array: <Array>, regex: <string>, replace: <string>}`の形で指定する必要があります                                                                                      |
| input.array    | Replaceを行う対象の配列を指定します                                                                                                                                     |
| input.regex    | 正規表現を指定します                                                                                                                                                    |
| input.replace  | 置き換え内容を定義します。[`$1`といった置き換えパターンを利用可能です](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace) |
| output         | `z.string().array()`を指定します                                                                                                                                        |

設定例:

```ts
// 処理#0の配列を`^user\\/([^${}]*)`のサブマッチパターン($1、`[^${}]*`)で置き換えます。
[
  {
      functionName: 'arrayReplace',
      input: {
          array: '${#0}',
          regex: '^user\\/([^${}]*)',
          replace: '$1',
      },
      output: z.string().array(),
  },
],
```

### nowUnixTime

取得時点のUnixTime(UTC)を取得し、後続処理へ渡します。

| 必要パラメータ | 説明                                      |
| -------------- | ----------------------------------------- |
| functionName   | `nowUnixTime`                             |
| opts.tdiff     | UTCに加算する時間を、hour単位で入力します |
| output         | `z.number()`を指定します。                |

設定例:

```ts
// UTCで取得する場合
[
    {
        functionName: 'nowUnixTime',
        output: z.number()
    },
],
// 日本時間で取得する場合
[
    {
        functionName: 'nowUnixTime',
        otps: {
          tdiff: 9
        },
        output: z.number()
    },
],
```

### defineRef

Inputをパススルーします。固定値を定義したり、RefMarkerをObjectに変換し、後続処理へ渡すために使います。

| 必要パラメータ | 説明                                                    |
| -------------- | ------------------------------------------------------- |
| functionName   | `defineRef`                                             |
| input          | パススルーする値を指定します。                          |
| output         | optsと同じ出力となるようにZodオブジェクトを定義します。 |

設定例:

```ts
// 固定値をそのまま次の出力に渡す
[
    {
        functionName: 'defineRef',
        input: {
            key1: 'value1',
            key2: 'value2',
        },
        output: z.object({
            key1: z.string(),
            key2: z.string(),
        }),
    },
],
// RefMarkerの形を変形する
[
    {
        functionName: 'defineRef',
        input: {
            value: '${#.value1}',
            array: ['${#.value2}', '${#.value3}'],
        },
        output: z.object({
            value: z.string(),
            array: z.string().array(),
        }),
    },
],
```

### numSum/numAvg

- numSum: 数値の配列から合計を出力します。
- numAvg: 数値の配列から平均を出力します。

| 必要パラメータ | 説明                                      |
| -------------- | ----------------------------------------- |
| functionName   | `numSum`                                  |
| input          | 配列、または配列のRefMarkerを指定します。 |
| output         | `z.number()`を定義します。                |

設定例:

```ts
[
    {
        functionName: 'numSum',
        input: "${#}", // <--- inputで配列を入力
        output: z.number(), // <--- 合計値が出力になる
    },
    {
        functionName: 'numAvg',
        input: ['${#0}', 0], // <---- 処理#0(合計値)と0を入力
        output: z.number(), // <--- 2値の平均を出力
    },
],
```

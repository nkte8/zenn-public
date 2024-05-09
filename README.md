# documents について

技術文書の蓄積を目的としたプロジェクトです。  
zennと連携されており、 https://zenn.dev/nkte8 に記事の形で整形され投稿されています。  

## 運用者用メモ  

前提：docker-composeが利用できること

### 初期化
pull直後は`init.sh`を実行すること  

### 新規記事作成
`new_article.sh`を実行  
日付-r0X.mdおよびimagesディレクトリに画像ディレクトリが生成される。  

### preview  

`docker run --rm -p 80:8000 -v $PWD:/src -w /src -it node:lts npx zenn preview`でプレビュー  
ポート番号は80番でアクセスOK  
```sh
docker run --rm -p 80:8000 -v $PWD:/src -w /src -it node:lts npx zenn preview
👀 Preview: http://localhost:8000
```

### 記法:ローカルリンク  

下記の要領でzenn内記事を参照させることが可能。  
```
[表示内容](/USERNAME/articles/20XX-XX-XX-rXX)
```

## 参考  

CNIインストール： https://zenn.dev/zenn/articles/install-zenn-cli  
Gitlab連携方法： https://zenn.dev/zenn/articles/connect-to-github  
CLI使用方法： https://zenn.dev/zenn/articles/zenn-cli-guide  
公式リポジトリ： https://github.com/zenn-dev/zenn-docs  
# zenn document について

技術文書の蓄積を目的としたプロジェクトです。  
zennと連携されており、 https://zenn.dev/nkte8 に記事の形で整形され投稿されています。  

## 運用者用メモ  

前提：npmコマンドが使えること

### 初期化
pull直後は`init.sh`を実行すること  

### 新規記事作成
`new_article.sh`を実行  
日付-r0X.mdのarticleテンプレートおよびimagesディレクトリが生成される。

### 新規本作成

`new_book.sh hoge-fuga-book`を実行
`hoge-fuga-book`のbookテンプレートおよびimagesディレクトリが生成される。

### preview  

`npm run dev`でプレビュー

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
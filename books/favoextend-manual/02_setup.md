---
title: '環境準備 - アプリケーションのインストール'
---

# アプリケーションのインストール

`favoExtend`を動作させるためのアプリケーションのインストールを行います。
必要なアプリケーションは以下です。

- **Terraform** (`v1.X..`)
  - クラウドサービスへfavoExtendをデプロイするために必要です
- **node** (`v20.X..`)
  - favoExtendをデプロイするために必要です

::: message

導入済みの場合はスキップしてください。
こちらではリンクのみを添付し、細かなインストール方法については割愛します。
:::

## 【推奨】Ubuntu実行環境の用意

::: message

本プログラムは`Ubuntu`上で動作検証がされているため、`Ubuntu`のみ動確しています。
他環境においても理論上は問題ないため、必ずUbuntu環境が必要というわけではありません。
:::

インターネットに疎通可能なUbuntuの実行環境を用意します。`hyperV`や`WSL2`、`VirtualBox`などの仮想環境で問題ありません。もっと言えば`Docker`の`Ubuntu`イメージ上での実行も可能です。

## Terraformのインストール

利用環境に`Terraform`をインストールします。

https://developer.hashicorp.com/terraform/install

動画付きのインストール手順もあります。  
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

コマンドプロンプト(PowerShell)やターミナルで、`terraform`が使えるようになっていたらインストール完了です。

```log
PS C:\Users\****> terraform -v
Terraform v1.8.2
on windows_amd64
```

### Ubuntuの場合のインストール方法

`apt`パッケージマネージャに`gpg`キーの設定と`sources.list.d`への設定を行い、通常通りインストールを行います。以下は[Terraform公式インストール手順](https://developer.hashicorp.com/terraform/install)からの引用です。

```sh
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

:::details バイナリを直接ダウンロードする方法【非推奨】

パッケージマネージャを使う他にバイナリ一本ダウンロードするという手もあります（アップデートへの追従が大変なので、基本的にはリポジトリ追加をおすすめします。）

Intel製のCPUで動作している場合（v1.8.2）
```sh
curl -L https://releases.hashicorp.com/terraform/1.8.2/terraform_1.8.2_linux_386.zip -o terraform.zip
unzip terraform.zip
sudo mv terraform /usr/local/bin/
```
その他CPU種についてはダウンロードリンクを公式インストール手順からコピーして、`curl`の引数に渡してください。

:::

## nodeのインストール

利用環境に`node`をインストールします。

こちらからダウンロードを行ってください。
https://nodejs.org/en/download

コマンドプロンプト(PowerShell)やターミナルで、`node`が使えるようになっていたらインストール完了です。
```log
PS C:\Users\****> node -v
v20.11.0
```

### Ubuntuの場合のインストール方法

Linuxの場合、`apt`でインストールすることが可能です。

```sh
sudo apt install nodejs npm
```

しかしバージョンが高くない(執筆時点で`v18.19.1`)ため、ここではパッケージマネージャの`n`を使ってインストールします。
`node`をインストールためには`n`が、`n`をインストールするためには`node`が必要と、鶏卵です。

ここでは`n`が提供している[bootstrap用スクリプト](https://github.com/tj/n/blob/master/bin/n)を使ってインストールします。
内部では`https://nodejs.org/download`からインストールしているので、安全性も大丈夫だと思われます。

```sh
sudo su - # rootで実行すること 
mkdir .n
curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | N_PREFIX=${HOME}/.n bash -s lts
echo 'PATH=${PATH}:${HOME}/.n/bin' > ${HOME}/.bashrc
. .bashrc 
npm install -g n
n install lts
exit
```

上記により、`node`の最新版が通常ユーザでも使えるようになります。  

```log
ubuntu@devsv:~
>> which node
/usr/local/bin/node
ubuntu@devsv:~
>> node -v
v20.12.2
```

`n`は、前手順では`/root/.n/bin`にインストールしたbootstrap上の`node`にのみ存在するため、必要であれば`sudo npm install -g n`で、本体側にもインストールして利用が可能です。

```log
ubuntu@devsv:~
>> sudo npm install -g n
[sudo] ubuntu のパスワード: 

added 1 package in 286ms
ubuntu@devsv:~
>> n --version
v9.2.3
```

---

以上で必要なプログラムのインストールは完了です。
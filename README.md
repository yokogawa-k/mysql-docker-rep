# MySQL Replication in Docker

## これは何

docker で MySQL のレプリケーション環境を作れるものです。

## 必要なもの

- docker
- docker-compose
- make

## 使い方

make を実行すると help が表示されるのでそちらをご覧ください

## 特徴

このレポジトリに用意してる設定では以下の二つの特徴があります。

- MySQL のバージョンを指定できる
- binlog_format を指定できる

## その他

gitd は ON になっています。外したい場合は `docker-compose-rep-no-gtid.yml` を利用指定ください

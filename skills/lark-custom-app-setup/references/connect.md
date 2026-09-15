# Lark接続と研修用権限

## 3つの条件を分ける

1. PCでCLIが起動する。
2. アプリが会社で承認され、本人がそのアプリを利用・認可できる。
3. 本人が目的のBaseに必要な権限を持つ。

ポータルへのメールログインは、この3つを代行しません。外部テナントからのログインも自動的に許可されません。参加者が所属する会社と、アプリの利用可能範囲・Baseの共有先を確認します。

## 会社側の準備

[Developer Console](https://open.larksuite.com/app)で、会社が管理する既存アプリを利用できるか確認します。新規の場合は名前・用途を決めてCustom Appを作成します。受講者全員が毎回アプリを作る前提にせず、会社の管理方針を決めてください。App Secretを全員のチャットへ配布してはいけません。

### Base中心の権限候補

このスキルの `scopes-training-base.json` は **user操作の候補** です。tenantは空です。Baseの読取・レコード作成/更新・表/フィールド作成等を含み、削除・共同編集者追加・管理者操作・メール・チャット送信は含めません。ビュー構成、自動化、共有設定はこの初期セットの対象外です。利用するコマンドにより要求scopeが異なる可能性があり、実テナントで検証が必要です。

原作の `scopes-larkapps-create.json` は変更せず残しています。これは広い用途向けであり、研修の初期設定として丸ごと適用しません。候補のimportに失敗するscopeがあればConsoleの表示・公式仕様で確認し、全権限追加で回避しません。

ConsoleのPermissions & Scopesで候補を確認し、必要なものを申請します。バージョン公開と管理者承認、アプリの利用可能範囲の設定まで完了してください。Base自体の共有権限は別途、会社の管理者が設定します。

## 既存設定を守って登録

既存CLIを使っている人は既存プロフィールを再利用するか、会社ごとに名前を分けます。以下の `training` は例で、既存名と衝突しない名前に置き換えます。

```bash
lark-cli config init --help
lark-cli config init --name training
```

本人が端末で対話入力します。Lark利用者は **Lark** を選び、Feishuと取り違えないでください。App Secretは対話入力だけに使い、チャットやGitHubへ貼りません。非対話入力が必要ならCLIの `--app-secret-stdin` の公式手順を確認します。既存プロフィールを上書きする確認が出たら対象を確認します。

## user認証

最初は読み取りに必要なscopeに限定します。例：

```bash
lark-cli --profile training auth login --scope 'base:app:read base:table:read base:field:read base:record:read offline_access'
```

画面に出たURLを本人が開いて承認します。別の人が代わりに認証しません。必要なscopeがアプリで許可されていなければ、会社の管理者に対象scopeを確認してもらいます。

実際に書込演習へ進むときは、会社で承認済みの候補に合わせて追加認可します（既存の読取scopeも含めます）。

```bash
lark-cli --profile training auth login --scope 'base:app:read base:table:read base:field:read base:record:read offline_access base:app:create base:table:create base:field:create base:record:create base:record:update'
```

ブラウザの認証・会社の承認に要する時間は保証できません。AI側で待機が難しい場合は、そのバージョンの `auth login --help` にある `--no-wait` を使い、本人の完了後に再開します。

次に `lark-cli --profile training auth status` を本人の端末で確認し、[Base動作確認](verify.md)へ。statusの全出力を公開リポジトリへ保存しません。

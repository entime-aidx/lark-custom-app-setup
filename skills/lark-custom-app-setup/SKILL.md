---
name: lark-custom-app-setup
description: 笹原式で Lark カスタムアプリを新規作成し、lark-cli に登録して user 身分で認可するときに使う。 「Larkアプリを作りたい」「lark-cli をセットアップ」「カスタムアプリ作成」「App ID を取得して lark-cli に登録」「auth login したい」「Permission denied が出る」の場面で発火。mail 以外の12ドメインの権限付与と、Secret を画面に出さない登録手順を強制する。
argument-hint: <アプリ名> [説明]
allowed-tools: Bash(lark-cli:*), Bash(which:*), Read, Write
---

# 笹原式 Lark App 作成

引数: `$ARGUMENTS`（1語目＝アプリ名、残り＝説明）。
アプリ名が未指定ならユーザーに確認してから始める。説明が未指定なら STEP 1 の入力時に確認する。

前提: 権限セットは「mail 以外の12ドメイン」。Secret は絶対に画面・ログ・チャットに出さず、必ず stdin で渡す。
コンソール操作（STEP 1〜3）はユーザーが手で行う。**各 STEP 完了をユーザーに確認してから次へ進むこと。**

## STEP 0｜事前チェック
```bash
which lark-cli && lark-cli --version
```
未インストールならここで停止し、導入を案内する。

## STEP 1｜カスタムアプリを作成（ユーザー操作）
1. https://open.larksuite.com/app を開く（Feishu 版テナントなら open.feishu.cn。STEP 4 の `--brand` と必ず揃える）
2. 「Custom Apps」タブ →「Create Custom App」
3. Name にアプリ名、Description に説明、Icon を選択 →「Create」
4. 「Credentials & Basic Info」から **App ID** を控える
   - App ID（`cli_...`）はチャットに貼ってよい
   - **App Secret はチャットに貼らない**。STEP 4 で直接 stdin に入力する

## STEP 2｜権限を付与 ー mail 以外を全部（ユーザー操作）
`Permissions & Scopes`（`https://open.larksuite.com/app/<APP_ID>/auth`）で設定する。

推奨: **Batch Actions →「Batch import/export scopes」→ Import** に JSON を貼って一括投入。
形式は以下（tenant / user の両方に同じスコープを入れる）:
```json
{ "scopes": { "tenant": ["im:message:send_as_bot"], "user": ["docx:document:readonly"] } }
```
リポジトリに `.claude/lark/scopes-sasahara.json` がある場合はその中身を貼る。
貼ったら「Next, Review New Scopes」→ 内容確認 → 追加。

JSON が無い場合は UI で追加: **Add permission scopes to app** → 左のモジュールを選び、
ヘッダのチェックボックスで全選択 → Tenant token scopes / User token scopes の両タブで実施。

対象モジュール（12ドメイン相当）:
- Contacts / Messenger / Calendar / Docs（docs・docx・sheets・drive・wiki・bitable・board を含む）
- Base / Video Conferencing / Minutes / Tasks / Search / Event Subscription
- Authentication（offline_access）/ Profile

**除外**: Email（mail）。および Organization・Admin・Approval・Attendance・OKR・Lingo など12ドメイン外のモジュール。
mail は必要になった時点で追加すればよい（スコープは累積する）。

## STEP 3｜バージョンを作成して公開・承認（ユーザー操作）
`Version Management & Release` でバージョンを作成 → 公開申請 → 管理者承認まで完了させる。
チェックを入れただけでは権限は効かない。「設定したのに Permission denied」の大半がこれ。

## STEP 4｜lark-cli にアプリを登録
対話モード（推奨。Secret が画面に残らない）:
```bash
lark-cli config init
```
非対話の場合（Secret は stdin から。履歴に残さない）:
```bash
lark-cli config init --app-id <APP_ID> --app-secret-stdin --brand lark
```
`--brand` の既定値は `feishu`。Lark 版テナントなら必ず `--brand lark`。

## STEP 5｜user 身分で認可（笹原式の中核）
```bash
lark-cli auth login --domain base,calendar,contact,docs,drive,event,im,minutes,sheets,task,vc,wiki
```
- このコマンドは認可完了までブロックする。エージェントから実行する場合はバックグラウンド実行し、出力の認可 URL を拾う
- 表示された認可 URL をユーザーに開いてもらい、承認まで完了させる
- `--domain all` は使わない（mail が混ざる）
- 既定の身分は `--as user`。`--as bot` はアプリ名義で発信したい時だけ

## STEP 6｜動作確認
```bash
lark-cli auth status
lark-cli contact +get-user
lark-cli auth check --scope "base:record:read"
```
`"identity": "user"` と本人氏名が返れば完了。結果をユーザーに報告する。

## 完了チェックリスト
- [ ] カスタムアプリを作成し App ID を取得（Secret はどこにも貼っていない）
- [ ] mail 以外の12ドメインの権限を付与（tenant / user 両方）
- [ ] バージョン公開・管理者承認まで完了
- [ ] `lark-cli config init`（`--brand` 確認済み）
- [ ] `auth login --domain base,...,wiki` 実行済み
- [ ] `auth status` が identity: user
- [ ] `contact +get-user` が自分の情報を返す
- [ ] API で BASE を作る運用がある場合、作成直後に自分を full_access オーナーへ追加する手順を組み込んだ

## つまずいた時
| 症状 | 原因 | 対処 |
|---|---|---|
| 権限を付けたのに Permission denied | バージョン公開・承認が未完了 | STEP 3 に戻る。エラー内の console_url から該当画面へ |
| user では通るが bot で空が返る | bot は個人資源が見えない | `--as user` に切り替える |
| 認証情報は合っているのに全部失敗 | `--brand` の取り違え | `lark-cli config init --brand lark` で再登録 |
| API で作った BASE を画面から編集できない | bot 名義で作成され所有者が自分でない | 作成直後に自分を full_access オーナーへ追加 |
| しばらく使うと認証が切れる | トークン期限 | `offline_access` があれば自動更新。`auth status` で確認 |

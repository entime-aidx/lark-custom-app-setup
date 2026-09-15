# Baseでの完了確認

PCチェックのPASSとLarkの認可、Baseの編集成功は別です。以下を順番に確認してください。CLI例は1.0.92のhelpで確認した形式です。対象バージョンのhelpと異なる場合はそちらに合わせます。

## 準備

会社が用意した演習専用Baseをブラウザで開きます。本人が編集できることを確認。単一行テキストの「確認メモ」列を持つ演習表を用意し、講師からそのBase tokenとtable IDを受け取ります。資料に顧客の実URL/ID/名簿を埋め込みません。

以下の `BASE_TOKEN`、`TABLE_ID`、`RECORD_ID` は説明用です。実際に確認した値へ置き換えます。`training` も登録したプロフィール名へ合わせます。コマンドはGit Bash/macOSのターミナル用です。

## 1. 読取

```bash
lark-cli --profile training base +table-list --base-token BASE_TOKEN --as user
lark-cli --profile training base +record-list --base-token BASE_TOKEN --table-id TABLE_ID --limit 1 --as user
```

目的の会社・Base・表かを画面と照合します。空の表は0件で正常です。エラーのない空結果だけでは書込権限を証明できません。

## 2. テスト1行を作成

講師が指定した演習表と「確認メモ」列であることを確認し、書込演習が許可されてから実行します。まずプレビュー：

```bash
lark-cli --profile training base +record-upsert --base-token BASE_TOKEN --table-id TABLE_ID --json '{"確認メモ":"CLI共同編集テスト"}' --as user --dry-run
```

内容・宛先を確認してから実行：

```bash
lark-cli --profile training base +record-upsert --base-token BASE_TOKEN --table-id TABLE_ID --json '{"確認メモ":"CLI共同編集テスト"}' --as user
```

返されたrecord IDを控え、ブラウザにもその行があるか確認します。このコマンドは `--record-id` なしでは新規作成です。応答が途切れた場合は表を確認してから再試行し、同じ行を重複作成しません。

## 3. 別参加者と共同編集

別参加者が**自分のアカウント**で同じ行を開き、確認メモを「画面から更新確認」に変更します。最初の人がそのrecord IDを指定して読取：

```bash
lark-cli --profile training base +record-get --base-token BASE_TOKEN --table-id TABLE_ID --record-id RECORD_ID --as user
```

CLIでも「画面から更新確認」を確認します。続けてCLIから同じ行を更新する場合は、作成時のrecord IDを指定します。

```bash
lark-cli --profile training base +record-upsert --base-token BASE_TOKEN --table-id TABLE_ID --record-id RECORD_ID --json '{"確認メモ":"CLIから更新確認"}' --as user
```

別参加者の画面に反映されたら共同編集の確認は完了です。テスト行は演習記録として残し、勝手に削除しません。自分一人の画面だけの確認なら「共同編集は未確認」と記録します。

## 検収記録

| 段階 | 成功条件 |
|---|---|
| PC | preflightの不足が解消 |
| 認証 | 本人・会社・プロフィールが正しい |
| 読取 | 対象Baseの実データと一致 |
| 書込 | 指定した演習行の作成・更新が画面と一致 |
| 共同編集 | 別参加者の編集を相互に確認 |

社内記録には日時・OS・CLI版・確認した段階・エラー分類を残します。公開Issueにはメールアドレス、token、顧客のURL、業務データを貼りません。

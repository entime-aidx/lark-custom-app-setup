# Lark CLI 研修セットアップ — Entime fork

Windows・Macで必要ソフトの準備から、Lark認証、Base共同編集の確認まで進めるClaude Code用スキルです。
[OFFICE PLATAの原作](https://github.com/OfficePlata/lark-custom-app-setup)をMITライセンスでforkしています。原作者の著作権表示はLICENSEに保持しています。

**PCへの導入だけでは完了しません。会社のアプリ承認・本人の認証・対象Baseの編集権限も必要です。**

## 最初に選ぶ

| 利用環境 | 手順 |
|---|---|
| Windows 11 / Windows 10 1809以降、x64・ARM64 | [Windows導入](skills/lark-custom-app-setup/references/windows.md) |
| macOS 13以降、Intel・Apple Silicon | [Mac導入](skills/lark-custom-app-setup/references/macos.md) |
| Linux / WSL / Chromebook | [対応条件と検証状況](docs/compatibility.md) |
| 必要ソフトが導入済み | [Lark接続と権限](skills/lark-custom-app-setup/references/connect.md) |
| 接続済み | [Base読取・書込・共同編集の確認](skills/lark-custom-app-setup/references/verify.md) |
| 途中で止まった | [トラブル対応](skills/lark-custom-app-setup/references/troubleshooting.md) |
| 講師・運営 | [研修での進め方](docs/training.md) |

これはワンクリックで全権限を付けるインストーラーではありません。導入コマンドは人が実行し、事前チェックはソフトの有無を調べるだけです。
Claude Codeには対応する契約/API利用環境が必要です。CLIを直接使う場合、Claude Codeは不要ですが、このスキルによる案内は使いません。

## スキルを入れる（Claude Code導入後）

**Claude Codeの入力欄**で、1行ずつ実行します。PowerShellやGit Bashの通常プロンプトではありません。

```text
/plugin marketplace add entime-aidx/lark-custom-app-setup
/plugin install lark-custom-app-setup@entime-training
```

Claude Codeを再起動して、次を入力します。

```text
/lark-custom-app-setup 研修用Base操作 Windowsで事前チェックから案内して
```

更新は `/plugin marketplace update entime-training`。このforkのマーケットプレイス名は原作の `office-plata` と分けています。両方を入れて同名スキルが競合する場合は、Claude Codeの `/plugin` 画面で使用する版を選んでください。

## 読み取り専用のPCチェック

このリポジトリを取得したフォルダで実行します（Node.js 22以上を本研修の基準とします）。

```bash
node skills/lark-custom-app-setup/scripts/preflight.mjs
```

表示するのはOS/CPU/RAMとソフトのバージョン・不足項目です。認証状態・Secret・トークン・個人ファイルは読みません。通信・インストール・Larkへの書込も行いません。
`PASS` はPCの前提確認のみ。会社の承認やBaseアクセス成功を意味しません。終了コードは0=PC前提OK、1=不足/未確認、2=使い方不正です。
CLI直接操作のみの確認は `--cli-only`、機械可読出力は `--json`。

## 公開リポジトリに入れない情報

App Secret、認証コード、トークン、参加者名簿、顧客のBase URLや業務データは保存しません。演習URLは研修チャット等で個別に配布してください。`.gitignore`だけで秘密を防げるわけではありません。

## 検証と出典

[検証状況](docs/compatibility.md)に実機/自動テスト/未確認を分けて記載しています。Windows CIの成功はWindows実機でのLark認証成功ではありません。

- [Lark CLI公式](https://github.com/larksuite/cli)
- [Claude Code公式セットアップ](https://code.claude.com/docs/en/setup)
- [変更点](CHANGELOG.md)

# lark-custom-app-setup

笹原式で **Lark カスタムアプリを新規作成 → lark-cli に登録 → user 身分で認可** まで進める Claude Code 用 skill です。

- 権限は「mail 以外の12ドメイン」をまとめて付与
- App Secret を画面・ログ・チャットに出さない登録手順
- 「Permission denied」「bot だと空が返る」など、つまずきポイントの対処表つき

## 前提

- [Claude Code](https://claude.com/claude-code)
- [lark-cli](https://github.com/larksuite/cli)（`lark-cli --version` が通ること）
- Lark（または Feishu）テナントでカスタムアプリを作成・公開申請できる権限

## インストール

### A. プラグインとして入れる（推奨・更新が楽）

Claude Code 内で:

```
/plugin marketplace add OfficePlata/lark-custom-app-setup
/plugin install lark-custom-app-setup@office-plata
```

更新は `/plugin marketplace update office-plata`。

### B. skill フォルダを直接コピーする

```bash
git clone https://github.com/OfficePlata/lark-custom-app-setup.git
mkdir -p ~/.claude/skills
cp -R lark-custom-app-setup/skills/lark-custom-app-setup ~/.claude/skills/
```

特定のリポジトリだけで使う場合は `~/.claude/skills/` の代わりに `<repo>/.claude/skills/` に置きます。

## 使い方

Claude Code を再起動してから、どちらかで起動します。

```
/lark-custom-app-setup 営業管理Bot 営業チームのBASE操作用
```

または自然文で「Lark のカスタムアプリを作って lark-cli に登録したい」と伝えると自動で発火します。

コンソール操作（アプリ作成・権限付与・バージョン公開）は API が無いため手作業です。
Claude が STEP ごとに案内し、完了を確認してから次に進みます。

| STEP | 内容 | 実施者 |
|---|---|---|
| 0 | lark-cli の導入確認 | Claude |
| 1 | カスタムアプリ作成・App ID 取得 | あなた |
| 2 | 権限付与（mail 以外の12ドメイン） | あなた |
| 3 | バージョン作成・公開・管理者承認 | あなた |
| 4 | `lark-cli config init`（Secret は stdin） | Claude / あなた |
| 5 | `lark-cli auth login`（user 身分で認可） | Claude / あなた |
| 6 | 動作確認 | Claude |

## 注意

- **App Secret はチャットに貼らないでください。** STEP 4 の対話入力（stdin）でのみ渡します。
- Lark 版テナントは `--brand lark` が必須です（既定は `feishu`）。

## License

MIT © OFFICE PLATA

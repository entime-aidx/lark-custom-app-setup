# Mac導入

Claude Codeを使う場合はmacOS 13以降、Intel/Apple Silicon、RAM 4GB以上。会社が許可するサポート中のOSを使います。Node.jsは本研修の基準として22以上を使います。

1. [Node.js公式](https://nodejs.org/)から現在のLTSを導入します。既存環境はむやみに更新せず、先に `node --version` と `npm --version` を確認します。
2. 「ターミナル」を開きます。次は公式インストーラーを実行する操作です。

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

3. ターミナルを開き直し、`claude --version` → `claude` で本人のアカウントへログインします。対応する契約/API利用環境が必要です。
4. 別のターミナルでCLIを入れます。

```bash
npx @larksuite/cli@latest install
lark-cli --version
```

5. Claude Codeの入力欄で、1行ずつスキルを登録します。

```text
/plugin marketplace add entime-aidx/lark-custom-app-setup
/plugin install lark-custom-app-setup@entime-training
```

再起動後 `/lark-custom-app-setup 研修用Base操作 Macで接続まで案内して` と入力します。Gitがない場合はプラグイン追加時のエラーに従って会社承認済みのGitを導入してください。警告や会社の制限を無効化して進めません。

任意のPCチェックはREADMEの `node …/preflight.mjs` を、取得したリポジトリ内で実行します。Node/npm導入に `sudo` が必要と出た場合、まず利用者用の導入先と社内手順を確認し、既存の権限を一括変更しません。

次は [Lark接続](connect.md)、その後 [Base動作確認](verify.md)。
出典：[Claude Code公式](https://code.claude.com/docs/en/setup)、[Lark CLI公式](https://github.com/larksuite/cli)。

# Windows導入

Windows 11、またはWindows 10 1809以降のx64/ARM64が候補。32bitは対象外です。Claude Codeの要件はRAM 4GB以上。本研修のNode.js基準は22以上（CLI本体の最低要件とは別）。会社が許可するサポート中のOSを使用してください。

## 1. 先に確認

ソフト追加・外部AI利用が許可されているか、Claude Codeに使える契約/API利用環境があるか、Lark側でアプリを作成・承認できる担当者がいるかを確認します。PCの管理者権限がないことだけで不可とは判断しません。社内の配布方法を優先し、禁止設定を解除しません。

## 2. Node.jsとGit Bash

1. [Node.js公式](https://nodejs.org/)から現在のLTSのWindowsインストーラーを選びます。CPUに合う版を使います。
2. [Git for Windows公式](https://git-scm.com/downloads/win)から導入します。
3. スタートメニューから **Git Bash** を開きます。以下はすべてGit Bash用です。

```bash
node --version
npm --version
git --version
bash --version
```

見つからなければ端末を開き直します。本手順ではWSLは必須ではありません。Git Bashが使えない環境は公式のPowerShell手順へ切り替え、このページのBash構文をそのまま貼らないでください。

## 3. Claude Code

次は公式インストーラーをダウンロードして実行する操作です。内容と社内の導入方針を確認して実行します。

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Git Bashを開き直します。

```bash
claude --version
claude
```

ブラウザの案内で本人のClaude Codeアカウントにログインします。Claudeの無料アカウントだけではClaude Codeは使えません。

## 4. Lark CLI

Claude Code内ではなく、Git Bashの通常プロンプトで実行します。Claude Codeを開いている場合は別のGit Bashを開きます。

```bash
npx @larksuite/cli@latest install
lark-cli --version
```

インストーラーの案内に従い、必要なら端末を開き直します。`latest`は変わるため、研修の代表PCで確認した実際のバージョンを記録してください。npm経由ではGo/Pythonの追加は不要です。

## 5. このforkのスキル

`claude`でClaude Codeを開き、その入力欄で1行ずつ実行します。

```text
/plugin marketplace add entime-aidx/lark-custom-app-setup
/plugin install lark-custom-app-setup@entime-training
```

再起動後、`/lark-custom-app-setup 研修用Base操作 Windowsで接続まで案内して` と入力します。

## 6. PCチェック（任意の手動実行）

Git Bashでこのリポジトリを取得します。既に同名フォルダがある場合は上書きせず、既存フォルダを確認します。

```bash
git clone https://github.com/entime-aidx/lark-custom-app-setup.git
cd lark-custom-app-setup
node skills/lark-custom-app-setup/scripts/preflight.mjs
```

通常はスキルが自身の配置先からチェックを実行するので、診断のためだけに再cloneする必要はありません。

次は [Lark接続](connect.md)、その後 [Base動作確認](verify.md)です。

出典：[Claude CodeのWindows説明](https://code.claude.com/docs/en/setup#set-up-on-windows)、[Lark CLI公式](https://github.com/larksuite/cli)。

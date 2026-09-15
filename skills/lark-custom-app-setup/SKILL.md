---
name: lark-custom-app-setup
description: Windows・MacでLark CLIの導入前チェック、必要ソフトの準備、カスタムアプリ設定、本人認証、研修用Baseの共同編集確認を案内する。既存環境の再設定は必要な箇所だけ行う。
---
# Lark CLI 研修セットアップ

目的は、受講者本人の権限で指定した演習用Baseを読み書きし、他の参加者と共同編集できること。CLI起動やauth statusだけで完了にしない。

## 入口

OSと、ソフトの導入可否・Claude Code利用環境・Lark所属組織・演習対象を確認する。分かる事項は既存情報を使う。OS不明のままBashコマンドをWindows PowerShellに貼らせない。

- Windowsは [references/windows.md](references/windows.md)。本ガイドの標準はGit Bash。WindowsネイティブとWSLのインストール/認証は混ぜない。
- Macは [references/macos.md](references/macos.md)。
- Nodeがある場合 `scripts/preflight.mjs` をこのスキルの実際の配置先から実行。cwdに存在すると仮定しない。設定の変更は行わない。CLIだけ使う人には `--cli-only`。
- Linux等はリポジトリのdocs/compatibility.mdまたは公式OS条件を参照し、未実機検証と区別。

## 接続から検収

[references/connect.md](references/connect.md)に沿って、既存アプリ/プロフィールの再利用可否を確認。新規登録には名前付きプロフィールを使い既存の既定設定を上書きしない。

研修用権限候補は `scopes-training-base.json`。原作 `scopes-larkapps-create.json` は広い権限の参考として保持し、自動適用しない。権限候補は最小権限の実証済みセットではない。失敗した操作の要求scopeを公式仕様と照合し、必要分だけ調整する。

App Secretは人がローカル端末の対話入力へ入力する。AIチャット、コマンド引数、ファイル、環境変数例にSecretを記入しない。認証URLをログへ保存/公開しない。アプリ公開/利用者範囲/権限拡大は対象と必要性を示して会社の承認を得る。ユーザー本人の明示済み承認は引き継ぐ。

user認証を標準にする。対象にアクセスできないからとbotや管理者へ切り替えたり、Baseの高度権限を解除したりしない。会社間でアプリ資格情報を使い回さない。

[references/verify.md](references/verify.md)で読取→指定演習行の書込→別参加者の画面編集→CLI再読取を確認。作成の応答が不明な場合は再作成前に既存行を確認する。利用者名、業務情報を公開の検証記録へ出さない。

エラーは [references/troubleshooting.md](references/troubleshooting.md)。該当バージョンの `--help` を参照し、無効なコマンドがサービスのヘルプを返す場合も成功と誤認しない。

最後に「PC確認済み／認証済み／読取済み／書込済み／共同編集済み」を区別して報告し、未確認条件と次の操作を明示する。

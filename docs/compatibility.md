# 対応条件と検証状況

確認日：2026-09-15。最新条件は公式ドキュメントを優先してください。

| 対象 | 公開条件 / このforkの扱い |
|---|---|
| Windows | Claude CodeはWindows 10 1809+、x64/ARM64。標準ガイドはGit Bash。Windows 11を含む |
| macOS | Claude Codeは13+、Intel/Apple Silicon |
| Linux | Claude Codeの公式例はUbuntu20.04+/Debian10+/Alpine3.19+。このforkではOS要件を自動判定しないため要個別確認 |
| WSL | Claude Code/Node/CLIを同じLinux環境に入れる。Windows側との混在を未検収のまま進めない |
| Chromebook | ChromeOS単体を対応対象にしない。許可されたLinux環境の有無を個別確認 |
| 32bit | この研修の組合せは対象外 |
| RAM | Claude Codeの公表最低4GB。PCチェックは物理RAMを確認し、実際の空き容量/操作快適性は保証しない |
| Node | CLI package宣言は>=16。本研修のチェック基準は22以上。現在のLTSを使い、既存業務のNodeを無断更新しない |
| Claude Code契約 | 対応するPro/Max/Team/Enterprise/Console等が必要。無料Claude.aiだけでは不可 |
| PC制限 | ソフト導入可否・プロキシ・外部AI利用は社内ルール次第。管理者権限の有無だけで判定しない |

## 自動チェックが行うこと

`preflight.mjs` はOS/CPU/物理RAM/Nodeを確認し、固定されたコマンドの `--version` のみ実行します。出力はバージョン番号だけを抽出し、コマンドの生ログを転送しません。通信、設定ファイル読取、認証、インストール、Baseアクセスは実行しません。
WindowsでBashが見つかってもGit Bash/WSLの取り違えは人が最終確認します。Linuxのバージョンは自動で合格にせず要確認とします。macOSはDarwinカーネルのmajorが22以上を13以降の目安に使います。

## 検証の区別

- ローカル：macOSで既存CLI 1.0.92の起動とコマンドhelpを確認。新規インストール・権限変更は行っていない。
- 自動：Node組込テストで不足ソフト・不対応CPU・古いOS・タイムアウト等の誤合格を確認。GitHub ActionsのLinux/Windows/macOSで実行する。結果はリポジトリのActionsを参照。
- **未確認**：受講者のWindows/Macでの新規一気通貫導入、候補scopeセットの実テナント承認とBase書込、他テナントの認可、複数人の共同編集。

CI成功を実テナントの権限確認や研修全員の準備完了と同一視しません。`--cli-only` はClaude/Git/Bash/RAM4GBの研修条件を省略するだけで、Lark APIの成功を保証しません。

出典：
- https://github.com/larksuite/cli/blob/main/package.json
- https://github.com/larksuite/cli/blob/main/scripts/install.js
- https://code.claude.com/docs/en/setup
- https://github.com/OfficePlata/lark-custom-app-setup

# Windows：PowerShellに貼るだけで開始

初めての方は、[受講者向けWindows導入手順書](windows-manual.md)から順番に進めてください。

GitやNode.jsがないPCから始められます。ZIPの保存場所を探したり、手動で展開したりする必要はありません。

1. スタートメニューで **Windows PowerShell** を検索して開きます。通常の権限で始めてください。
2. 下の枠を **まとめてコピーして貼り付け、Enter** を押します。複数行の貼付確認が出た場合は内容を確認してください。
3. 導入予定が出たら **INSTALL** と入力します。途中のUACや利用規約は本人が確認してください。

```powershell
& {
param([switch]$PrepareOnly)
$ErrorActionPreference = 'Stop'
$revision = '9aecb709d5b3d16172749d10f39f9bea89ac4a67'
$expected = '5b0ef1e3a3b356b95c21915838b5070c50f05b0b1ff9670669ab90455986d989'
$work = Join-Path ([IO.Path]::GetTempPath()) ('lark-training-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$archive = Join-Path $work 'setup.zip'
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/entime-aidx/lark-custom-app-setup/archive/$revision.zip" -OutFile $archive
if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {
    throw 'Download verification failed. Setup was not started.'
}
Expand-Archive -LiteralPath $archive -DestinationPath $work
$setup = Join-Path $work "lark-custom-app-setup-$revision\scripts\setup-windows.ps1"
if (-not (Test-Path -LiteralPath $setup -PathType Leaf)) { throw 'Setup file is missing. Nothing installed.' }
Write-Host "Verified setup files: $work"
if ($PrepareOnly) {
    Write-Host 'Download and extraction verified. No installer started.'
} else {
    & powershell.exe -NoLogo -NoProfile -File $setup -Install
    if ($LASTEXITCODE -ne 0) { throw 'Setup stopped. Read the message above; do not disable company security settings.' }
}
}
```

Node.js LTS → Git → Claude Code → Lark CLIの順で、不足しているソフトを導入します。必要なファイルは一時フォルダに自動保存します。ダウンロードしたファイルのSHA-256を確認してから開始します。

この入口は検査済みのセットアップ実装 `9aecb70` を取得します。最新版へ無条件に追従せず、取得した内容が違うと停止します。Node等の配布パッケージは各公式配布元の最新版です。

**PC SETUP COMPLETE** が出たらソフトの準備完了です。その後、新しいGit Bashで `claude` を開き、[スキル登録と本人認証](../skills/lark-custom-app-setup/references/windows.md#5-このforkのスキル)へ進みます。ソフト導入だけでLarkログインやBase権限が付くことはありません。

## 止まった場合

- WinGetがない：会社で許可された方法でMicrosoftのアプリ インストーラーを導入/更新します。
- スクリプト実行が禁止：会社の管理者に[セットアップの内容](../scripts/setup-windows.ps1)を確認してもらいます。実行ポリシー変更・Bypass・Unblock-Fileは行いません。
- 古いNode.jsがある：他の業務に影響しない更新方法を確認してから進めます。
- 途中失敗：先に導入されたソフトは残ります。原因を解消して同じ手順をやり直すと、導入済みは再利用します。

インターネット接続とWinGet、会社のソフト導入許可が必要です。Windowsでのダウンロード・ハッシュ確認・展開はCIで検査しますが、実受講者PCへの新規インストールとLark認証はまだ未検収です。

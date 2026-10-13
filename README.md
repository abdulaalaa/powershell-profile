# PowerShell 7 Developer Profile

A portable PowerShell 7 setup for Windows with command predictions, fuzzy search, Git completion, convenient directory navigation, terminal icons, and a Starship prompt.

This repository stores the **configuration**, not the installed applications or PowerShell modules. Follow the instructions below on each new Windows device.

## Repository contents

```text
powershell-profile/
├── Microsoft.PowerShell_profile.ps1  # Complete, ready-to-copy profile
└── README.md                         # Installation and troubleshooting
```

The profile checks for optional tools before loading them. Missing optional tools should not prevent PowerShell from starting. It is a **reconstructed and improved profile**, not a byte-for-byte backup from the original device.

## Features

| Feature | Tool | Usage |
|---|---|---|
| History suggestions | PSReadLine | Suggestions while typing |
| Additional command predictions | CompletionPredictor (optional) | Plugin suggestions when compatible |
| Interactive tab completion | PSReadLine | Press `Tab` |
| Fuzzy command history | PSFzf + fzf | Press `Ctrl+R` |
| Fuzzy file search | PSFzf + fzf | Press `Ctrl+T` |
| Git completions | posh-git | Complete Git commands and branches |
| Directory jumping | zoxide | Use `z` or `zi` |
| Prompt information | Starship | Git, directory, and language context |
| File icons | Terminal-Icons | Run `Get-ChildItem` |
| Python tool completions | uv | Complete `uv` subcommands |

## First-time installation on Windows

All commands after Step 1 must be executed **inside PowerShell 7** (`pwsh`), not Windows PowerShell 5.1.

### Step 1 — Install and start PowerShell 7

Check the currently running shell:

```powershell
$PSVersionTable.PSVersion
Get-Command pwsh -ErrorAction SilentlyContinue
```

If the version begins with `5` and `pwsh` is not found, install the latest stable PowerShell 7:

```powershell
winget install --id Microsoft.PowerShell --exact --source winget
```

Close the old terminal, open a new one, and launch:

```powershell
pwsh
$PSVersionTable.PSVersion
```

Confirm that the major version is `7`. PowerShell 7 runs alongside Windows PowerShell 5.1; it does not uninstall 5.1.

To make it the default in **Windows Terminal**: open **Settings → Startup → Default profile**, select **PowerShell** (version 7), and save. Other terminals such as Alacritty have separate shell settings and should launch `pwsh.exe` if you want the same behavior there.

Official instructions: https://learn.microsoft.com/powershell/scripting/install/install-powershell-on-windows

### Step 2 — Confirm Git and WinGet

```powershell
git --version
winget --version
```

If Git is missing, install it and restart PowerShell:

```powershell
winget install --id Git.Git --exact --source winget
```

If `winget` is missing, install or repair **App Installer** using Microsoft's official instructions before continuing.

### Step 3 — Install the external command-line utilities

Run each command in PowerShell 7. If WinGet reports that a package is already installed, do not install a second copy.

```powershell
winget install --id Starship.Starship --exact --source winget
winget install --id ajeetdsouza.zoxide --exact --source winget
winget install --id junegunn.fzf --exact --source winget
winget install --id astral-sh.uv --exact --source winget
```

Close and reopen PowerShell 7 so the refreshed `PATH` is picked up. Check the binaries:

```powershell
starship --version
zoxide --version
fzf --version
uv --version
```

Installing these commands makes the executables available; the profile in this repository handles their shell initialization.

### Step 4 — Install PowerShell modules

Run in PowerShell 7. The PowerShell Gallery may prompt for permission or repository trust.

```powershell
Install-Module -Name PSReadLine -Scope CurrentUser -Repository PSGallery -Force
Install-Module -Name posh-git -Scope CurrentUser -Repository PSGallery
Install-Module -Name PSFzf -Scope CurrentUser -Repository PSGallery
Install-Module -Name Terminal-Icons -Scope CurrentUser -Repository PSGallery
```

Optional, experimental predictions:

```powershell
Install-Module -Name CompletionPredictor -Scope CurrentUser -Repository PSGallery
```

`CompletionPredictor` requires PowerShell 7.2+ and PSReadLine 2.2.2+. It is an older experimental project. The profile falls back to history-only predictions if it is absent or fails to load.

Check module availability:

```powershell
Get-Module -ListAvailable -Name PSReadLine,posh-git,PSFzf,Terminal-Icons,CompletionPredictor |
    Select-Object Name,Version
```

Restart PowerShell 7 after installing/upgrading PSReadLine.

### Step 5 — Obtain this repository

**For a new computer, after this repository has been published on GitHub:**

```powershell
New-Item -ItemType Directory -Path (Join-Path $HOME 'Code') -Force | Out-Null
$repo = Join-Path $HOME 'Code\powershell-profile'
git clone https://github.com/YOUR_USERNAME/powershell-profile.git $repo
```

Replace `YOUR_USERNAME` with the owner of the repository. The destination directory must not already exist. If you already have a Git clone there, use `Set-Location $repo` and `git pull --ff-only` rather than cloning over it.

**If you created the profile file locally on this computer already**, keep that existing directory and skip the clone. Continue to Step 6.

### Step 6 — Install the profile into the active PowerShell 7 location

Run this complete block **inside PowerShell 7**. It backs up any current profile first.

```powershell
if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw 'Open PowerShell 7 (pwsh) first.'
}

$repo = Join-Path $HOME 'Code\powershell-profile'
$source = Join-Path $repo 'Microsoft.PowerShell_profile.ps1'
$target = $PROFILE.CurrentUserCurrentHost

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Repository profile missing: $source"
}

New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null

if (Test-Path -LiteralPath $target -PathType Leaf) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    Copy-Item -LiteralPath $target -Destination "$target.backup-$stamp" -ErrorAction Stop
}

Copy-Item -LiteralPath $source -Destination $target -Force -ErrorAction Stop
Write-Host "Installed profile at: $target"
```

Close and reopen PowerShell 7. Its profile should load automatically. You can also run `. $PROFILE.CurrentUserCurrentHost` to load it in the current session; do that only once per session to avoid reinitializing integrations.

**Why use `$PROFILE`?** Documents may be redirected into OneDrive, and PowerShell has different profile paths for 5.1, 7, and different hosts. Never assume that every computer uses the same absolute path.

Official profile reference: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles

### Step 7 — Verify the installation

```powershell
$PSVersionTable.PSVersion
$PROFILE.CurrentUserCurrentHost
Get-Module PSReadLine,PSFzf,posh-git,Terminal-Icons,CompletionPredictor
Get-PSReadLineOption | Select-Object PredictionSource,PredictionViewStyle
Get-Command z,zi,starship,uv -ErrorAction SilentlyContinue
```

Try these interactive tests:

1. Type part of a previously used command: history suggestions should appear.
2. Press `Tab` while entering a command: menu completion should be available.
3. Press `Ctrl+R`: open fuzzy history search, if PSFzf loaded.
4. Press `Ctrl+T`: open fuzzy file search, if PSFzf loaded.
5. Change directories a few times; try `z <part-of-folder-name>` or `zi`.
6. Enter a Git repository to test the Starship prompt and Git completions.
7. Run `Get-ChildItem` to inspect terminal icons.

`PredictionSource` should show `HistoryAndPlugin` only when CompletionPredictor is installed and successfully imported. `History` is an acceptable fallback.

## Publishing from the first computer to GitHub

Do this **once**, if you created `Microsoft.PowerShell_profile.ps1` locally and have not yet published the repository.

1. Visit https://github.com/new and create a repository named `powershell-profile`.
2. Leave **Initialize with README**, **.gitignore**, and **license** unchecked; the remote should be empty.
3. Ensure the local folder contains `Microsoft.PowerShell_profile.ps1` and this `README.md`.
4. Open PowerShell 7 and run:

```powershell
$repo = Join-Path $HOME 'Code\powershell-profile'
Set-Location -LiteralPath $repo

if (-not (Test-Path -LiteralPath '.git')) {
    git init -b main
}

git add Microsoft.PowerShell_profile.ps1 README.md
git diff --cached --check
git diff --cached --name-only
git commit -m 'Add portable PowerShell 7 developer profile'
```

Review the staged file list: it should contain only the intended configuration/documentation, **not tokens, passwords, secrets, or private project files**.

If the repository has no `origin` remote yet:

```powershell
git remote add origin https://github.com/YOUR_USERNAME/powershell-profile.git
git push -u origin main
```

Replace `YOUR_USERNAME`. If `origin` already exists, run `git remote -v` to inspect it instead of adding another remote. GitHub may request sign-in.

## Keeping computers synchronized

The **repository copy** and the **active `$PROFILE` copy** are separate files. Editing one does not automatically update the other.

### Edit and publish changes

```powershell
$repo = Join-Path $HOME 'Code\powershell-profile'
Set-Location -LiteralPath $repo
nvim .\Microsoft.PowerShell_profile.ps1

git status
git add Microsoft.PowerShell_profile.ps1 README.md
git diff --cached --check
git commit -m 'Update PowerShell settings'
git push
```

If only one file has changed, Git stages only that file. If nothing is staged, skip the commit.

To apply the updated repository copy locally, repeat **Step 6** and restart PowerShell 7.

### Pull updates on another device

```powershell
$repo = Join-Path $HOME 'Code\powershell-profile'
Set-Location -LiteralPath $repo
git pull --ff-only
```

Repeat **Step 6** to copy the downloaded profile to `$PROFILE.CurrentUserCurrentHost`, then restart PowerShell 7.

### Update installed tools and modules (optional)

```powershell
winget upgrade --id Microsoft.PowerShell --exact
winget upgrade --id Starship.Starship --exact
winget upgrade --id ajeetdsouza.zoxide --exact
winget upgrade --id junegunn.fzf --exact
winget upgrade --id astral-sh.uv --exact

Update-Module -Name PSReadLine,posh-git,PSFzf,Terminal-Icons -ErrorAction Continue
```

Upgrade modules only if they were installed using `Install-Module`; otherwise follow their original installation method. Restart PowerShell after upgrades.

## Troubleshooting

### PowerShell launches version 5.1

```powershell
$PSVersionTable.PSVersion
Get-Command pwsh -ErrorAction SilentlyContinue
```

Windows PowerShell 5.1 (`powershell.exe`) and PowerShell 7 (`pwsh.exe`) are distinct programs. Launch `pwsh` and set the PowerShell 7 profile as default in Windows Terminal **Settings → Startup**. Another terminal may require its own shell setting.

### `pwsh`, `starship`, `zoxide`, `fzf`, or `uv` is not recognized

Restart the terminal after installing a tool; old processes may still have the old `PATH`.

```powershell
Get-Command pwsh,starship,zoxide,fzf,uv -ErrorAction SilentlyContinue
```

Check whether WinGet successfully installed the package before reinstalling. If `pwsh` itself is missing, repeat Step 1.

### Profile was copied, but enhancements do not load

```powershell
$PROFILE.CurrentUserCurrentHost
Test-Path -LiteralPath $PROFILE.CurrentUserCurrentHost
$PROFILE | Select-Object *
```

Make sure the copy was made from **PowerShell 7**, and that the correct host profile is being loaded. Profiles are skipped when starting `pwsh -NoProfile`.

Check for an execution-policy restriction:

```powershell
Get-ExecutionPolicy -List
```

On a personal computer with no overriding organization policy, `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` is an option. Do not bypass a policy imposed by an employer or administrator. Inspect unknown scripts before executing them.

### Profile startup shows an error

Start PowerShell 7 without running profiles:

```powershell
pwsh -NoProfile
```

Then inspect the configured file:

```powershell
Get-Content -LiteralPath $PROFILE.CurrentUserCurrentHost
```

Check recently changed lines and whether an optional tool's executable still exists. The repository copy and the timestamped backup can be used to recover a known working version.

### Only history predictions appear

```powershell
Get-Module PSReadLine,CompletionPredictor
Get-PSReadLineOption | Select-Object PredictionSource,PredictionViewStyle
```

If CompletionPredictor is absent or cannot import, the profile deliberately uses `History` predictions. `HistoryAndPlugin` is only available when its prerequisites are met. `F2` can switch between inline and list presentation when supported by PSReadLine.

### `Ctrl+R` or `Ctrl+T` doesn't work

```powershell
Get-Command fzf -ErrorAction SilentlyContinue
Get-Module PSFzf
Get-Module PSReadLine
```

Both the **fzf executable** and the **PSFzf module** are necessary for the configured keybindings. Restart and check whether the profile imported PSFzf successfully.

### zoxide shows a `System.Object[]` / `Invoke-Expression` error

The initialization command must be passed as a single string, not a collection of output lines. The provided profile uses `Out-String` to normalize it. Verify that the installed `$PROFILE` copy matches the repository copy and restart:

```powershell
zoxide --version
Get-Content -LiteralPath $PROFILE.CurrentUserCurrentHost
```

Do not add a second `zoxide init powershell` invocation elsewhere in your profiles.

### `z` isn't recognized although zoxide is installed

A successful `zoxide --version` verifies the executable, **not** the shell integration. Confirm that your profile loaded; then test `Get-Command z -ErrorAction SilentlyContinue`. Visit directories normally to build zoxide's directory history.

### The Starship prompt does not appear

```powershell
Get-Command starship -ErrorAction SilentlyContinue
$PROFILE.CurrentUserCurrentHost
```

Check that the profile loaded and its Starship initialization ran. A different theme/prompt module loading afterward may override Starship. A Nerd Font is optional but improves symbol rendering.

### Git completions or file icons do not appear

```powershell
Get-Module posh-git,Terminal-Icons
Get-Module -ListAvailable posh-git,Terminal-Icons
```

If installed but not imported, investigate profile startup errors. `Terminal-Icons` affects compatible directory listings; it is not a file manager.

### uv completion does not work

Check `uv --version` and that your profile executes `uv generate-shell-completion powershell`. Install the executable first; then restart PowerShell. The profile already includes initialization, so do not append duplicate commands.

### Two profile locations, OneDrive, or unexpected directories

Always use `$PROFILE.CurrentUserCurrentHost` as resolved by **the PowerShell 7 session you're configuring**. Do not type `%LOCALAPPDATA%` into PowerShell expecting it to expand; that's Command Prompt syntax. PowerShell uses `$env:LOCALAPPDATA`. Also, do not assume Documents is under a fixed path; OneDrive redirection may change it.

### Git push fails or `origin already exists`

```powershell
git status
git remote -v
```

If the remote is incorrect:

```powershell
git remote set-url origin https://github.com/YOUR_USERNAME/powershell-profile.git
```

If the remote repository was initialized independently, review both histories rather than forcing a push.

## Official references

- PowerShell installation: https://learn.microsoft.com/powershell/scripting/install/install-powershell-on-windows
- PowerShell profiles: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles
- PSReadLine: https://github.com/PowerShell/PSReadLine
- CompletionPredictor: https://github.com/PowerShell/CompletionPredictor
- PSFzf: https://github.com/kelleyma49/PSFzf
- Starship: https://starship.rs/
- zoxide: https://github.com/ajeetdsouza/zoxide
- fzf: https://github.com/junegunn/fzf
- uv: https://docs.astral.sh/uv/

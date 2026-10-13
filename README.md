

# PowerShell 7 Developer Profile

Portable PowerShell 7 configuration for Windows development.

Includes command predictions, fuzzy history, Git
completion, enhanced directory navigation, terminal
icons, a customizable prompt, and Python tooling.

## Requirements

- PowerShell 7+
- Git

Recommended tools:
- Starship
- zoxide
- fzf
- uv
- Nerd Font

PowerShell modules:
- PSReadLine
- CompletionPredictor (optional/experimental)
- PSFzf
- posh-git
- Terminal-Icons

The profile checks whether optional components are
installed before attempting to initialize them.

## Installation — Windows

Clone this repository using PowerShell 7:

```powershell
$repo = Join-Path $HOME "Code\powershell-profile"

git clone https://github.com/YOUR_USERNAME/powershell-profile.git $repo
```

Back up the existing profile and install the new one:

```powershell
$source = Join-Path $repo "Microsoft.PowerShell_profile.ps1"
$target = $PROFILE.CurrentUserCurrentHost

New-Item -ItemType Directory `
    -Path (Split-Path -Parent $target) `
    -Force | Out-Null

if (Test-Path -LiteralPath $target) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item $target "$target.backup-$stamp"
}

Copy-Item -LiteralPath $source -Destination $target -Force

. $target
```

Close and reopen PowerShell 7 afterward.

## Installing Optional Modules

Within PowerShell 7:

```powershell
Install-Module -Name posh-git, PSFzf, Terminal-Icons `
    -Scope CurrentUser -Repository PSGallery
```

CompletionPredictor can be installed separately:

```powershell
Install-Module CompletionPredictor `
    -Scope CurrentUser -Repository PSGallery
```

Check compatibility with your PSReadLine version.

Install external utilities such as Starship, zoxide,
fzf, and uv using their official installation
instructions or a package manager.

They must be available on PATH.

## Keybindings

| Shortcut | Function |
|---|---|
| Tab | Completion menu |
| Ctrl+R | Fuzzy history search |
| Ctrl+T | Fuzzy file search |
| Ctrl+F | Accept the next suggested word |
| F2 | Toggle PSReadLine prediction display |

## Commands

| Command | Purpose |
|---|---|
| `z project` | Jump to a frequently used directory |
| `zi` | Interactive directory selection |
| `Get-History` | Show session command history |
| `Get-PSReadLineOption` | Inspect prediction settings |
| `$PROFILE` | Show active host profile path |

## Troubleshooting

### PowerShell 5.1 loads instead of 7

Run:

```powershell
$PSVersionTable.PSVersion
```

Launch PowerShell 7 using `pwsh`.

Configure Windows Terminal's default profile
to PowerShell 7.

### The profile does not load

Check:

```powershell
Test-Path $PROFILE.CurrentUserCurrentHost
Get-ExecutionPolicy -List
```

Confirm that the file is in PowerShell 7's profile
directory rather than WindowsPowerShell's directory.

### Only history predictions appear

Check:

```powershell
Get-Module PSReadLine
Get-Module CompletionPredictor
Get-PSReadLineOption
```

CompletionPredictor must load successfully to enable
its plugin-based predictions.

History predictions work without CompletionPredictor.

### zoxide throws System.Object[] errors

Ensure its initialization text is converted to a
single string before Invoke-Expression.

### Starship does not appear

Verify:

```powershell
Get-Command starship
```

Restart PowerShell after installing Starship.

### Ctrl+R or Ctrl+T does not work

Confirm both fzf and PSFzf are installed.

## Updating

Edit the repository copy of the profile.

After changes:

```powershell
git add Microsoft.PowerShell_profile.ps1 README.md
git commit -m "Update PowerShell profile"
git push
```

Copy the updated repository profile to the active
PowerShell profile location and restart PowerShell.

Do not commit passwords, API keys or access tokens.

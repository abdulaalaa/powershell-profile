

# PowerShell 7 Developer Profile
# Portable across Windows devices.
# Optional modules and tools load only when available.

# 1. Interactive editing, command history and predictions
Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord

# 2. Optional intelligent completion predictor
if (Get-Module -ListAvailable -Name CompletionPredictor)
{
  Import-Module CompletionPredictor
  Set-PSReadLineOption -PredictionSource HistoryAndPlugin
}

# 3. Git completions
if (Get-Module -ListAvailable -Name posh-git)
{
  Import-Module posh-git
}

# 4. Fuzzy searching
# Ctrl+R: history
# Ctrl+T: files
if (
  (Get-Command fzf -ErrorAction SilentlyContinue) -and
  (Get-Module -ListAvailable -Name PSFzf)
)
{
  Import-Module PSFzf

  Set-PsFzfOption `
    -PSReadlineChordProvider 'Ctrl+t' `
    -PSReadlineChordReverseHistory 'Ctrl+r'
}

# 5. File and folder icons
if (Get-Module -ListAvailable -Name Terminal-Icons)
{
  Import-Module Terminal-Icons
}

# 6. Fast directory navigation
# z project
# zi (interactive selection)
if (Get-Command zoxide -ErrorAction SilentlyContinue)
{
  $zoxideInit = & zoxide init powershell | Out-String
  Invoke-Expression $zoxideInit
}

# 7. uv Python package manager completion
if (Get-Command uv -ErrorAction SilentlyContinue)
{
  $uvCompletion = & uv generate-shell-completion powershell |
    Out-String

  Invoke-Expression $uvCompletion
}

# 8. Starship prompt
# Initialize last to preserve prompt ownership
if (Get-Command starship -ErrorAction SilentlyContinue)
{
  $starshipInit = & starship init powershell | Out-String
  Invoke-Expression $starshipInit
}

param([switch]$Verify, [switch]$Editor, [int]$QuitAfter=0)
$ErrorActionPreference='Stop'
$project=Split-Path $PSScriptRoot -Parent
$engine=$env:GODOT_EXE
if (-not $engine) {
  $cmd=Get-Command godot.exe -ErrorAction SilentlyContinue
  if ($cmd) { $engine=$cmd.Source }
}
if (-not $engine) {
  $found=Get-ChildItem (Join-Path $env:USERPROFILE 'Godot') -Recurse -Filter '*win64.exe' -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike '*console*' } | Sort-Object FullName -Descending | Select-Object -First 1
  if ($found) { $engine=$found.FullName }
}
if (-not $engine -or -not (Test-Path $engine)) { throw 'Install Godot 4.7.2 or set GODOT_EXE to your Godot executable. Then run PLAY.cmd again.' }
$logs=Join-Path $project '.local'
New-Item -ItemType Directory -Force $logs | Out-Null
Set-Content (Join-Path $logs '.gdignore') ''
function Invoke-Godot([string[]]$Arguments,[string]$Stage) {
  $quoted=($Arguments | ForEach-Object { '"' + $_ + '"' }) -join ' '
  $out=Join-Path $logs ($Stage+'.log')
  $err=Join-Path $logs ($Stage+'.stderr.log')
  $p=Start-Process -FilePath $engine -ArgumentList $quoted -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
  if (Select-String -Path $out,$err -Pattern 'SCRIPT ERROR|ERROR:' -Quiet) { return 1 }
  return $p.ExitCode
}
$code=Invoke-Godot @('--headless','--path',$project,'--editor','--import') 'import'
if ($code -ne 0) { throw 'Godot import failed. See .local/import.log.' }
$argsList=@('--path',$project)
if ($Editor) { $argsList += '--editor' }
if ($QuitAfter -gt 0) { $argsList += @('--quit-after',"$QuitAfter") }
if ($Verify) { $argsList += @('--','--verify',"--evidence=$logs") }
$code=Invoke-Godot $argsList 'play'
exit $code

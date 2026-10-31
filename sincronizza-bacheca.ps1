<#
  Copia dei diari dal PC al server, per la bacheca online (sola lettura).
  Il PC resta l'originale: questo script legge soltanto, non modifica nulla nella cartella dei progetti.

  Cosa si copia: di ogni cartella con un SAL.md, i file .md e .txt (SAL, TODO, STORICO, documenti) piu' _STATO-PROGETTI.json.
  Cosa NON si copia mai: UTILS (anche cifrato), file con "passw" o "credenz" nel nome, file temporanei di Office, PDF.

  Uso:
    .\sincronizza-bacheca.ps1                     # verso il server
    .\sincronizza-bacheca.ps1 -SoloLocale C:\prova # prova: scrive in una cartella locale, senza toccare il server
#>
param(
  [string]$Cartella = (Join-Path $env:USERPROFILE "Documents\Progetti"),
  [string]$Server   = "mitchtheswimmerserver",
  [string]$Utente   = "michele",
  [string]$Remoto   = "/srv/docker/bacheca/progetti",
  [string]$SoloLocale = ""
)
$ErrorActionPreference = "Stop"
$escludi = '(?i)utils|passw|credenz|^~\$'
$max = 600000

function Ms($f) { [DateTimeOffset]::new($f.LastWriteTimeUtc).ToUnixTimeMilliseconds() }

$staging = Join-Path $env:TEMP ("bacheca-sync-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $staging | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
try {
  $tree = [ordered]@{}
  $stato = Join-Path $Cartella "_STATO-PROGETTI.json"
  if (Test-Path $stato) {
    Copy-Item $stato $staging
    $f = Get-Item $stato
    $tree[$f.Name] = [ordered]@{ s = [int]$f.Length; m = (Ms $f) }
  }
  $n = 0
  foreach ($dir in Get-ChildItem $Cartella -Directory | Where-Object { $_.Name -notmatch '^\.' } | Sort-Object Name) {
    if (-not (Test-Path (Join-Path $dir.FullName "SAL.md"))) { continue }
    $dest = Join-Path $staging $dir.Name
    New-Item -ItemType Directory -Path $dest | Out-Null
    $files = [ordered]@{}
    foreach ($f in Get-ChildItem $dir.FullName -File | Where-Object { $_.Extension -match '^\.(md|txt)$' -and $_.Name -notmatch $escludi -and $_.Length -le $max } | Sort-Object Name) {
      Copy-Item $f.FullName $dest
      $files[$f.Name] = [ordered]@{ s = [int]$f.Length; m = (Ms $f) }
    }
    $tree[$dir.Name] = [ordered]@{ d = $files }
    $n++
  }
  $indice = [ordered]@{ t = [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds(); tree = $tree }
  [IO.File]::WriteAllText((Join-Path $staging "_indice.json"), ($indice | ConvertTo-Json -Depth 6 -Compress), $utf8)

  if ($SoloLocale) {
    New-Item -ItemType Directory -Force -Path $SoloLocale | Out-Null
    Copy-Item (Join-Path $staging "*") $SoloLocale -Recurse -Force
    Write-Host "Prova: $n progetti copiati in $SoloLocale (server non toccato)."
  } else {
    # tar in pipe tramite cmd: PowerShell rovinerebbe i dati binari. Sul server si estrae in una cartella temporanea e si sostituisce subito.
    $rem = "set -e; T=`$(mktemp -d); tar -xf - -C `$T; mkdir -p '$Remoto'; find '$Remoto' -mindepth 1 -delete; cp -a `$T/. '$Remoto'/; rm -rf `$T"
    cmd /c "tar -cf - -C ""$staging"" . | ssh -o BatchMode=yes $Utente@$Server ""$rem"""
    if ($LASTEXITCODE -ne 0) { throw "Sincronizzazione fallita (codice $LASTEXITCODE)" }
    Write-Host "Sincronizzati $n progetti sul server ($Server)."
  }
}
finally {
  Remove-Item $staging -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
}

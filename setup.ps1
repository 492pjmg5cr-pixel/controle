# Configura o Supabase: cria as tabelas e preenche o config.js
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$cfgPath = Join-Path $PSScriptRoot 'config.js'
if (-not (Test-Path $cfgPath)) { Write-Host 'config.js nao encontrado nesta pasta.' -ForegroundColor Red; exit 1 }
$cfg = Get-Content -Raw -Encoding UTF8 $cfgPath

$jaTem = ($cfg -match "SUPABASE_URL:\s*'https?://[^']+'") -and ($cfg -match "SUPABASE_KEY:\s*'[^']+'")
if ($jaTem) {
  Write-Host 'Supabase ja esta configurado no config.js. Pulando configuracao.' -ForegroundColor Green
  exit 0
}

Write-Host ''
Write-Host '=== Configuracao do banco compartilhado (Supabase) ===' -ForegroundColor Cyan
Write-Host '1) Crie uma conta e um projeto gratis em https://supabase.com'
Write-Host '2) Em Project Settings > API copie a "Project URL" e a chave "anon public"'
Write-Host ''

$url = (Read-Host 'Cole a Project URL (ex.: https://abcdefgh.supabase.co)').Trim().TrimEnd('/')
$key = (Read-Host 'Cole a chave anon public').Trim()
if ($url -notmatch '^https://([a-z0-9]+)\.supabase\.co$') { Write-Host 'URL invalida.' -ForegroundColor Red; exit 1 }
$ref = $Matches[1]
if (-not $key) { Write-Host 'Chave vazia.' -ForegroundColor Red; exit 1 }

# Cria as tabelas automaticamente (opcional)
$sqlFile = @('schema.sql','supabase\schema.sql') | ForEach-Object { Join-Path $PSScriptRoot $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
Write-Host ''
Write-Host 'Para criar as tabelas automaticamente, informe um Access Token pessoal' -ForegroundColor Cyan
Write-Host '(supabase.com/dashboard/account/tokens > Generate new token, comeca com sbp_).'
Write-Host 'Se preferir, deixe vazio e rode o schema.sql manualmente no SQL Editor.'
$tok = (Read-Host 'Access Token (opcional)').Trim()

if ($tok -and $sqlFile) {
  try {
    $sql = Get-Content -Raw -Encoding UTF8 $sqlFile
    $json = @{ query = $sql } | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Method Post -Uri "https://api.supabase.com/v1/projects/$ref/database/query" `
      -Headers @{ Authorization = "Bearer $tok" } -ContentType 'application/json; charset=utf-8' `
      -Body ([Text.Encoding]::UTF8.GetBytes($json)) | Out-Null
    Write-Host 'Tabelas criadas com sucesso.' -ForegroundColor Green
  } catch {
    Write-Host ('Falha ao criar as tabelas: ' + $_.Exception.Message) -ForegroundColor Yellow
    Write-Host 'Rode o schema.sql manualmente no SQL Editor do Supabase.' -ForegroundColor Yellow
  }
} else {
  Write-Host 'Lembre-se de rodar o schema.sql no SQL Editor do Supabase (New query > colar > Run).' -ForegroundColor Yellow
}

# Grava no config.js
$cfg = $cfg -replace "SUPABASE_URL:\s*'[^']*'", ("SUPABASE_URL: '" + $url + "'")
$cfg = $cfg -replace "SUPABASE_KEY:\s*'[^']*'", ("SUPABASE_KEY: '" + $key + "'")
[IO.File]::WriteAllText($cfgPath, $cfg, (New-Object Text.UTF8Encoding($false)))
Write-Host 'config.js atualizado.' -ForegroundColor Green

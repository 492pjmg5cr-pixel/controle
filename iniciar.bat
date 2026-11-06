@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Controle de Estoque

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
if errorlevel 1 (
  echo.
  echo Configuracao nao concluida.
  pause
  exit /b 1
)

set PY=
where python >nul 2>nul && set PY=python
if not defined PY where py >nul 2>nul && set PY=py
if not defined PY (
  echo.
  echo Python nao encontrado. Instale em https://www.python.org/downloads
  echo ^(marque "Add python.exe to PATH"^) e execute este arquivo de novo.
  pause
  exit /b 1
)

echo.
echo ================================================
echo  App no ar. Os dados ficam no Supabase e todos
echo  os aparelhos veem os mesmos produtos.
echo.
echo  Neste computador:  http://localhost:8000
echo  Outros aparelhos na mesma rede Wi-Fi:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do echo     http://%%a:8000
echo ================================================
echo  Feche esta janela para parar o servidor.
echo.
start "" http://localhost:8000
%PY% -m http.server 8000 --bind 0.0.0.0

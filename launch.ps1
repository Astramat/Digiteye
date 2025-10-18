<#
.SYNOPSIS
    Active le venv et lance le serveur Python (bridge.py)
.DESCRIPTION
    Conversion PowerShell du script .bat initial.
#>

# ────────────────────────────────────────────────
# 1) Définition du venv
# ────────────────────────────────────────────────

$VENV = "D:\LAURA\llm\.venv-core"
$ACTIVATE = Join-Path $VENV "Scripts\Activate.ps1"

if (-not (Test-Path $ACTIVATE)) {
    Write-Host "[ERROR] venv introuvable: $VENV" -ForegroundColor Red
    exit 1
}

# ────────────────────────────────────────────────
# 2) Activation du venv
# ────────────────────────────────────────────────

# Dot-source (important : garde les variables dans le scope courant)
. $ACTIVATE

# ────────────────────────────────────────────────
# 3) Aller dans le dossier du script courant
# ────────────────────────────────────────────────

Set-Location -Path $PSScriptRoot

# ────────────────────────────────────────────────
# 4) Dépendances (décommenter si besoin)
# ────────────────────────────────────────────────

# python -m pip install --upgrade pip
# if (Test-Path "requirements.txt") {
#     pip install -r requirements.txt
# } else {
#     pip install --upgrade huggingface_hub transformers fastapi uvicorn pillow requests pydantic python-multipart
# }

# ────────────────────────────────────────────────
# 5) (Optionnel) Ton token HF
# ────────────────────────────────────────────────

# $env:HF_TOKEN = "hf_xxx"

# ────────────────────────────────────────────────
# 6) Lancer le serveur
# ────────────────────────────────────────────────

python bridge.py

Write-Host ""
Write-Host "[INFO] Serveur arrêté. Appuyez sur une touche pour fermer." -ForegroundColor Yellow
[void][System.Console]::ReadKey($true)

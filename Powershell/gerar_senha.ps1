function Get-Senha {
    param (
        [int]$length = 12,
        [string]$type = "all"
    )

    $uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $lowercase = "abcdefghijklmnopqrstuvwxyz"
    $numbers = "0123456789"
    $specialChars = "!@#$%^&*()-_=+[]{}|;:,.<>?/`~"
    $allChars = $uppercase + $lowercase + $numbers + $specialChars

    switch ($type) {
        "1" {$allChars = $numbers}
        "2" {$allChars = $uppercase}
        "3" {$allChars = $lowercase}
        "4" {$allChars = $uppercase + $lowercase}
        "5" {$allChars = $uppercase + $numbers}
        "6" {$allChars = $lowercase + $numbers}
        "7" {$allChars = $uppercase + $lowercase + $numbers}
        "8" {$allChars = $uppercase + $lowercase + $numbers + $specialChars}
        default {Write-Host "Opção inválida. Gerando senha com letras, números e caracteres especiais." -ForegroundColor Red; $default}
    }

    if ($length -le 0) {
        Write-Host "Comprimento de senha não informado. Usando o comprimento padrão de 12." -ForegroundColor Red
        $length = 12
    }

    $password = -join (1..$length | ForEach-Object { $allChars[(Get-Random -Minimum 0 -Maximum $allChars.Length)] })

    return $password
}

function Get-Escolha {
    $opcoesValidas = 0..8
    do {
        Write-Host "`nSelecione o tipo de senha:" -ForegroundColor Cyan
        Write-Host "1. Somente números" -ForegroundColor Cyan
        Write-Host "2. Somente letras maiúsculas" -ForegroundColor Cyan
        Write-Host "3. Somente letras minúsculas" -ForegroundColor Cyan
        Write-Host "4. Letras maiúsculas e minúsculas" -ForegroundColor Cyan
        Write-Host "5. Letras maiúsculas e números" -ForegroundColor Cyan
        Write-Host "6. Letras minúsculas e números" -ForegroundColor Cyan
        Write-Host "7. Letras maiúsculas, minúsculas e números" -ForegroundColor Cyan
        Write-Host "8. Letras, números e caracteres especiais" -ForegroundColor Cyan
        Write-Host "0. Encerrar" -ForegroundColor Cyan
        $escolha = Read-Host "Digite o número correspondente à sua escolha"
        $escolha = [int]$escolha  # Converter para número inteiro
        if ([string]::IsNullOrWhiteSpace($escolha)) {
            Write-Host "Nenhuma entrada fornecida. Por favor, insira uma escolha válida." -ForegroundColor Red
        }
        elseif ($escolha -notin $opcoesValidas) {
            Write-Host "Opção inválida. Por favor, escolha uma opção válida." -ForegroundColor Red
        }
    } while ([string]::IsNullOrWhiteSpace($escolha) -or $escolha -notin $opcoesValidas)
    return $escolha
}

function Get-Tamanho-Senha {
    return [int](Read-Host "Digite o comprimento desejado da senha")
}

function Gerar-Senha {
    while ($true) {
        $choice = Get-Escolha
        if ($choice -eq 0) {
            Write-Host "Encerrando o programa." -ForegroundColor Red
            break  # Sai do loop e encerra a execução do programa
        }
        $length = Get-Tamanho-Senha
        $senha = Get-Senha -length $length -type $choice
        Write-Host "Sua senha gerada é: " -NoNewline -ForegroundColor Blue
        Write-Host $senha -NoNewline -ForegroundColor Green
        return
    }
}

# Necessário deixar para que o script seja executado, caso você execute como um ./gerar_senha.ps1
Gerar-Senha # Se deseja executar ao iniciar o powershell, remova ou comente essa linha.

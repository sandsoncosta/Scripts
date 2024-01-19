# Passar o caminho do arquivo csv com os nomes de usuários a serem criados.
$csvPath = Join-Path $PSScriptRoot "users.csv"

# Uma lista de senhas fáceis e difíceis para simular a complexidade de senhas no ambiente.
$passwords = @("MinhaSenha123", "Qwerty123", "password", "admin123", "*****", "Kento123!", "Flores123", "S3n#4Th3G14nT123", "JesusSalva", "RockYou2021", "PowerTheShell", "K`$4p9wY8r@2L", "D#6qPx7o*5Fv", "G@2sL9xP3qRw", "T!8zN7k#6p1X", "H%5jF2v*4qLp", "W@3rB6z1&8Xv", "Y*9sM7x2v#4L", "J!6dF4k#8w9P", "U&2hP8l`$5m3Z", "X%7tL1w#9r4K")

$userData = Import-Csv $csvPath

foreach ($user in $userData) {
    $firstName = $user.nome
    $lastName = $user.sobrenome
    $username = $user.login
    $department = $user.departamento

    $ouPath = "OU=$department,OU=Departamentos,DC=xpto,DC=local"

    $userExists = Get-ADUser -Filter {SamAccountName -eq $username}

    if ($userExists -eq $null) {
        # Seleciona aleatoriamente uma senha
        $selectedPassword = $passwords | Get-Random

        # Cria o usuário no AD
        New-ADUser -SamAccountName $username -UserPrincipalName "$username@xpto.local" -GivenName $firstName -Surname $lastName -Name "$firstName $lastName" -DisplayName "$firstName $lastName" -Enabled $true -Path $ouPath -AccountPassword (ConvertTo-SecureString $selectedPassword -AsPlainText -Force) -ChangePasswordAtLogon $false
        
        Write-Host "Usuário '$username' criado com sucesso na OU '$ouName' com a senha: $selectedPassword."
    } else {
        Write-Host "O usuário '$username' já existe na OU '$department'."
    }
}

# -*- coding: utf-8 -*-
# Define a codificação para UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Aqui fica listada todas OUs 
$ouNames = @("Administração", "Financeiro", "TI", "Vendas", "Marketing", "Red Team", "Blue Team", "Visitantes", "Estagiários", "Clientes", "Servidores", "Banco de Dados")

# Uma lista de senhas fáceis e difíceis para simular a complexidade de senhas no ambiente.
$passwords = @("MinhaSenha123", "Qwerty123", "password", "admin123", "********", "Kento123!", "Flores123", "S3n#4Th3G14nT123", "JesusSalva", "RockYou2021", "PowerTheShell", "K`$4p9wY8r@2L", "D#6qPx7o*5Fv", "G@2sL9xP3qRw", "T!8zN7k#6p1X", "H%5jF2v*4qLp", "W@3rB6z1&8Xv", "Y*9sM7x2v#4L", "J!6dF4k#8w9P", "U&2hP8l`$5m3Z", "X%7tL1w#9r4K")
# $password = "senha"

$firstNames = @("João", "José", "Miguel", "Arthur", "Gabriel", "Davi", "Luiz", "Bernardo", "Heitor", "Pedro", "Lucas", "Matheus", "Rafael", "Vicente", "Enzo", "Felipe", "Samuel", "Gael", "Leonardo", "Maria", "Alice", "Helena", "Heloísa", "Laura", "Luiza", "Sophia", "Valentina", "Gabriela", "Manuela", "Ana", "Isabella", "Julia", "Michael", "James", "Robert", "David", "William", "Richard", "Charles", "Emily", "Olivia", "Mia", "Abigail", "Emma", "Charlotte")
$lastNames = @("Silva", "Santos", "Oliveira", "Pereira", "Alves", "Ferreira", "Souza", "Rodrigues", "Lima", "Carvalho", "Gomes", "Costa", "Martins", "Reis", "Nascimento", "Almeida", "Barbosa", "Castro", "Moreira", "Ribeiro", "Nunes", "Fernandes", "Smith", "Johnson", "Williams", "Jones", "Davis", "Miller", "Wilson", "Carter", "Gonzalez", "Hernandez", "Garcia", "Lee", "Rodriguez", "Thomas", "Jackson")

foreach ($ouName in $ouNames) {
    $ouPath = "OU=$ouName,OU=Departamentos,DC=xpto,DC=local"

    for ($i = 1; $i -le 5; $i++) {
        $firstName = $firstNames | Get-Random
        $lastName = $lastNames | Get-Random
        $username = "$firstName.$lastName"

        # Convertendo para minúsculas e removendo acentos. Para criar nome.sobrenome para login.
        $username = $username.ToLower()
        $username = $username -replace "[ã]", "a"
        $username = $username -replace "[é]", "e"
        $username = $username -replace "[í]", "i"

        $userExists = Get-ADUser -Filter {SamAccountName -eq $username}

        if ($userExists -eq $null) {
            # Seleciona aleatoriamente uma senha. Comentar essa linha caso não queira usar senha random.
            $selectedPassword = $passwords | Get-Random

            # Cria o usuário no AD
            # Caso queia usar senha única, remover a parte: (ConvertTo-SecureString $selectedPassword -AsPlainText -Force)
            # e colocar apenas $password
            New-ADUser -SamAccountName $username -UserPrincipalName "$username@xpto.local" -GivenName $firstName -Surname $lastName -Name "$firstName $lastName" -DisplayName "$firstName $lastName" -Enabled $true -Path $ouPath -AccountPassword (ConvertTo-SecureString $selectedPassword -AsPlainText -Force) -ChangePasswordAtLogon $false

            Write-Host "Usuário '$username' criado com sucesso na OU '$ouName' com a senha: $selectedPassword."
        } else {
            Write-Host "O usuário '$username' já existe na OU '$ouName'."
        }
    }
}

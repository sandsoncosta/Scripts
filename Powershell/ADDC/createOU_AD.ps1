$ouNames = @("Administração", "Financeiro", "TI", "Vendas", "Marketing", "Red Team", "Blue Team", "Visitantes", "Estagiários", "Clientes", "Servidores", "Banco de Dados")

$ouPath = "OU=Departamentos,DC=xpto,DC=local"

foreach ($ouName in $ouNames) {

    $ouExists = Get-ADOrganizationalUnit -Filter {Name -eq $ouName}

    if ($ouExists -eq $null) {
        New-ADOrganizationalUnit -Name $ouName -Path $ouPath -Description "$ouName" -ProtectedFromAccidentalDeletion $false
        Write-Host "Unidade Organizacional '$ouName' criada com sucesso."
    } else {
        Write-Host "A Unidade Organizacional '$ouName' já existe."
    }
}

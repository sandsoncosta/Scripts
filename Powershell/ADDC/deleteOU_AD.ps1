
Import-Module ActiveDirectory

$ouToDelete = @("Administração", "Financeiro", "TI", "Vendas", "Marketing", "Red Team", "Blue Team", "Visitantes", "Estagiários", "Clientes", "Servidores", "Banco de Dados")

foreach ($OUName in $ousToDelete) {
    $ouToDelete = Get-ADOrganizationalUnit -Filter { Name -eq $OUName }
    

    if ($ouToDelete -ne $null) {
        # A linha abaixo só deleta as OUs se estiverem vazias.
        # Caso queira deletar as OUs com os objetos inclusos, precisa incluir a opção -Recurisve na linha abaixo. 
        Remove-ADOrganizationalUnit -Identity $ouToDelete -Confirm:$false
        Write-Host "Unidade Organizacional '$OUName' removida com sucesso."
    } else {
        Write-Host "A Unidade Organizacional '$OUName' não foi encontrada."
    }
}
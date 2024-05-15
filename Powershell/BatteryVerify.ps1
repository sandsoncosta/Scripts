# Ajustar o script para exibir uma notificação na tela com 20% e 10% de bateria
# Definir os limites de notificação da bateria
# Pega o tipo de chassi do device...
# [3, 4, 5, 6, 7, 15, 16] --> Desktop
# [8, 9, 10, 11, 12, 14, 18, 21, 31, 32] --> note
# [30] --> Tablet
# [17, 23] --> Servidor
#Refer: https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-systemenclosure

$batteryLimit20 = 20
$batteryLimit10 = 10

# Função para verificar o tipo de chassi
function Get-ChassisType {
    $chassisType = (Get-CimInstance -ClassName Win32_SystemEnclosure).ChassisTypes
    $notebookTypes = @(8, 9, 10, 11, 12, 14, 18, 21, 31, 32)
    foreach ($type in $chassisType) {
        if ($notebookTypes -contains $type) {
            return $true
        }
    }
    return $false
}

if (Get-ChassisType) {

    # Função para verificar o nível da bateria e notificar
    function Get-Battery {
        # Obter informações da bateria
        $battery = Get-CimInstance -ClassName Win32_Battery
        $batteryLevel = $battery.EstimatedChargeRemaining

        # Parâmetros para os limites da bateria
        $batteryLimit20 = $batteryLimit20
        $batteryLimit10 = $batteryLimit10

        # Verificar se o nível da bateria é igual ou inferior aos limites
        if ($batteryLevel -le $batteryLimit20 -or $batteryLevel -le $batteryLimit10) {
            # Exibir notificação
            $notificationMessage = "A bateria do computador $($env:COMPUTERNAME) está com apenas $batteryLevel% de carga. Por favor, conecte o carregador."
            Write-Host $notificationMessage
        }
    }

    # Verificar a bateria inicialmente
    Get-Battery

} else {
    Write-Host "Este computador não é um notebook. Não serão exibidas notificações de nível de bateria."
}

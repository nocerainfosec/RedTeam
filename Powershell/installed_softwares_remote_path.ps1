<#
.SYNOPSIS
    Este Script lista os programas instalados no Windows e grava em uma pasta remota.

.DESCRIPTION
    O script recupera informações sobre os aplicativos instalados consultando o registro do Windows. As informações coletadas incluem apenas o nome do aplicativo. O script também coleta informações sobre o nome do computador e o nome de usuário da máquina.

.AUTHOR
    Guilherme Nocera - Red Team - Security Researcher - Nocera Infosec
#>

# Defina o local do domínio para salvar os resultados
$localDominio = "\\seudominio\pastaCompartilhada"
# Obtenha o nome do computador e o usuário atual
$hostname = $env:COMPUTERNAME
$username = $env:USERNAME
# Defina o caminho do arquivo
$caminhoArquivo = "$localDominio\$hostname-$username-SoftwareInstalado.txt"

# Função para obter software instalado usando Get-CimInstance
function Obter-SoftwareInstalado {
    $software = Get-CimInstance -ClassName Win32_Product | Select-Object -Property Name, Version
    return $software
}

# Coletar informações de software instalado
$softwareInstalado = Obter-SoftwareInstalado

# Criar o conteúdo a ser escrito no arquivo
$conteudo = @"
Hostname: $hostname
Usuário: $username
Data: $(Get-Date)
Software Instalado:
"@

foreach ($software in $softwareInstalado) {
    $conteudo += "Nome: $($software.Name), Versão: $($software.Version)`n"
}

# Escrever o conteúdo no arquivo
$conteudo | Out-File -FilePath $caminhoArquivo -Force -Encoding UTF8

# Mensagem de sucesso
Write-Output "Lista de softwares instalados salva em $caminhoArquivo"

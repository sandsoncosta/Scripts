#!/bin/bash

# Define a cor vermelha (código ANSI)
RED='\033[0;31m'
# Reseta a cor (código ANSI)
NRED='\033[0m' # No Color
# Define a cor amarela (código ANSI)
YELLOW='\033[1;33m'
# Reseta a cor (código ANSI)
NYEL='\033[0m' # No Color
# Define a cor azul (código ANSI)
BLUE='\033[0;34m'
# Reseta a cor (código ANSI)
NBLUE='\033[0m' # No Color

# Define o nome do arquivo de log
LOG_FILE="/var/log/install_script.log"

show_progress() {
  local msg="$1"
  while true; do
    echo -n -e "[\] $msg... Aguarde.\r"
    sleep 0.5
    echo -n -e "[-] $msg... Aguarde..\r"
    sleep 0.5
    echo -n -e "[/] $msg... Aguarde...\r"
    sleep 0.5
    echo -n -e "[-] $msg... Aguarde....\r"
    sleep 0.5
  done
}

# Verificar se o pacote está instalado
is_package_installed() {
  local package_name="$1"
  if [ "$os_id" == "Ubuntu" ] || [ "$os_id" == "Debian" ]; then
    dpkg -l | grep -q -w "$package_name"
  elif [ "$os_id" == "CentOS" ] || [ "$os_id" == "Red Hat Enterprise Linux (RHEL)" ]; then
    rpm -q "$package_name" > /dev/null 2>&1
  fi
}

# Adicione mensagens de log para depuração
log_message() {
  local message="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

# Inicia o registro de log
exec > >(tee -a "$LOG_FILE") 2>&1
# exec > "$LOG_FILE" 2>&1
echo "Início do script: $(date)"

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Por favor, execute este script com o sudo.${NRED}"
  exit 1
fi

# Solicita a senha de root para instalar pacotes sem precisar de yes
# read -s -p 'Por favor, digite a senha de root para instalação dos pacotes sem interação do usuário: ' ROOT_PASSWORD"

# Solicita o IP do servidor do coletor/syslog
# Limpar o buffer de entrada
#read -t 1 -n 10000 discard
echo -e "${YELLOW}[*] Digite o IP do servidor do coletor/syslog:${NYEL}"
read ip_collector
echo "IP do servidor do coletor/syslog: $ip_collector"

# Detecta a versão do SO
echo -e "${YELLOW}[*] Detectando versão do SO...${NYEL}"
# os_version=$(lsb_release -a 2>/dev/null | grep 'Release' | awk '{print $2}')
os_id=$(lsb_release -a 2>/dev/null | grep 'ID' | awk -F ':' '{print $2}' | tr -d '\t ')

echo "[+] Detectado: $os_id"

# Verifica se o SO é compatível com o script
case "$os_id" in
"Ubuntu" | "Debian" | "CentOS" | "Red Hat Enterprise Linux (RHEL)")
  # echo "[+] Detectado: $os_id"
  ;;
*)
  echo -e "${RED}[!] Sistema não compatível com o instalador... Por favor, contate o suporte para instalação manual.${NRED}"
  exit 1
  ;;
esac

# Detecta a conexão com a internet
echo -e "${YELLOW}[*] Testando conexão com a internet...${NYEL}"
if ping -c 1 google.com &>/dev/null; then
  echo "[+] Conexão OK"
else
  echo -e "${RED}[!] Sem conexão com a internet... Por favor, entre em contato com o suporte para instalação manual.${NRED}"
  exit 1
fi

if [ "$os_id" == "Ubuntu" ] || [ "$os_id" == "Debian" ]; then
  packages_to_install=("wget" "curl" "auditd" "gcc" "make" "libaudit-dev" "libauparse-dev" "git" "autoconf" "automake" "libtool" "pkg-config")
fi

if [ "$os_id" == "Ubuntu" ] || [ "$os_id" == "Debian" ]; then
  if ! is_package_installed "wget"; then
    packages_to_install+=" wget"
  fi
  if ! is_package_installed "curl"; then
    packages_to_install+=" curl"
  fi
  if ! is_package_installed "auditd"; then
    packages_to_install+=" auditd"
  fi
  if ! is_package_installed "gcc"; then
    packages_to_install+=" gcc"
  fi
  if ! is_package_installed "make"; then
    packages_to_install+=" make"
  fi
  if ! is_package_installed "libaudit-dev"; then
    packages_to_install+=" libaudit-dev"
  fi
  if ! is_package_installed "autoconf"; then
    packages_to_install+=" autoconf"
  fi
  if ! is_package_installed "automake"; then
    packages_to_install+=" automake"
  fi
  if ! is_package_installed "libtool"; then
    packages_to_install+=" libtool"
  fi
  if ! is_package_installed "git"; then
    packages_to_install+=" git"
  fi
  if ! is_package_installed "pkg-config"; then
    packages_to_install+=" pkg-config"
  fi
  if ! is_package_installed "libauparse-dev"; then
    packages_to_install+=" libauparse-dev"
  fi
fi

if [ "$os_id" == "CentOS" ] || [ "$os_id" == "Red Hat" ]; then
  if ! is_package_installed "wget"; then
    packages_to_install+=" wget"
  fi
  if ! is_package_installed "curl"; then
    packages_to_install+=" curl"
  fi
  if ! is_package_installed "auditd"; then
    packages_to_install+=" auditd"
  fi
  if ! is_package_installed "gcc"; then
    packages_to_install+=" gcc"
  fi
  if ! is_package_installed "make"; then
    packages_to_install+=" make"
  fi
  if ! is_package_installed "audit-libs-devel"; then
    packages_to_install+=" audit-libs-devel"
  fi
  if ! is_package_installed "autoconf"; then
    packages_to_install+=" autoconf"
  fi
  if ! is_package_installed "automake"; then
    packages_to_install+=" automake"
  fi
  if ! is_package_installed "libtool"; then
    packages_to_install+=" libtool"
  fi
  if ! is_package_installed "git"; then
    packages_to_install+=" git"
  fi
fi


while true; do
  # Solicitar permissão para atualizar o repositório e listar pacotes a serem instalados
  echo -e "${YELLOW}[*] Os seguintes pacotes serão instalados: $packages_to_install${NYEL}"
  echo -e "${RED}[*] Deseja atualizar o repositório e instalar pacotes? (y/n): ${NRED}"
  read install_choice
  echo "Resposta do usuário: $install_choice"

  case "$install_choice" in
    [Yy]*)
      #echo "[+] Atualizando repositório... Aguarde..."
      if [ "$os_id" == "Ubuntu" ] || [ "$os_id" == "Debian" ]; then
        apt-get update > /dev/null 2>&1 &
        while ps -p $! > /dev/null; do
          echo -n -e "[\] Atualizando repositório... Aguarde.\r"
          sleep 0.5
          echo -n -e "[-] Atualizando repositório... Aguarde..\r"
          sleep 0.5
          echo -n -e "[/] Atualizando repositório... Aguarde...\r"
          sleep 0.5
          echo -n -e "[-] Atualizando repositório... Aguarde....\r"
          sleep 0.5
        done
        wait $!
      elif [ "$os_id" == "CentOS" ] || [ "$os_id" == "Red Hat Enterprise Linux (RHEL)" ]; then
        yum -y update > /dev/null 2>&1 &
        while ps -p $! > /dev/null; do
          echo -n -e "[\] Atualizando repositório... Aguarde.\r"
          sleep 0.5
          echo -n -e "[-] Atualizando repositório... Aguarde..\r"
          sleep 0.5
          echo -n -e "[/] Atualizando repositório... Aguarde...\r"
          sleep 0.5
          echo -n -e "[-] Atualizando repositório... Aguarde....\r"
          sleep 0.5
        done
        wait $!
      fi

      # Instalação dos pacotes sem verificar se já estão instalados
      if [ "$os_id" == "Ubuntu" ] || [ "$os_id" == "Debian" ]; then
        apt-get install -y ${packages_to_install[*]} > /dev/null 2>&1
      elif [ "$os_id" == "CentOS" ] || [ "$os_id" == "Red Hat Enterprise Linux (RHEL)" ]; then
        yum -y install ${packages_to_install[*]} --skip-broken > /dev/null 2>&1
      fi
      break  # Sai do loop enquanto
      ;;
    [Nn]*)
      echo "[!] Instalação interrompida pelo usuário. Script encerrado..."
      exit 0
      ;;
    *)
      echo -e "${RED}[!] Por favor, digite 'y' ou 'n'.${NRED}"
      ;;
  esac
done

#echo "[+] Todos os pacotes já estão instalados. Não é necessário atualizar o repositório."



# Baixa e configura as regras do auditd
echo -e "${YELLOW}[*] Baixando e configurando regras...${NYEL}"

if [ -n "$(command -v wget)" ]; then
  wget -O /etc/audit/rules.d/audit.rules https://raw.githubusercontent.com/Neo23x0/auditd/master/audit.rules > /dev/null 2>&1
  echo "[+] Regras baixadas e configuradas..."
elif [ -n "$(command -v curl)" ]; then
  curl -o /etc/audit/rules.d/audit.rules https://raw.githubusercontent.com/Neo23x0/auditd/master/audit.rules > /dev/null 2>&1
  echo "[+] Regras baixadas e configuradas..."
fi

# Clona e configura o repositório aushape
echo -e "${YELLOW}[*] Clonando repositório Aushape...${NYEL}"
git clone https://github.com/Scribery/aushape.git > /dev/null 2>&1
echo "[+] Repositório clonado..."
echo "[+] Configurando instalação do Aushape..."
cd aushape
autoreconf -i -f > /dev/null 2>&1
./configure --prefix=/usr --sysconfdir=/etc && make > /dev/null 2>&1
echo "[+] Instalando pacote... aushape"
sudo make install > /dev/null 2>&1

# Cria o arquivo aushape-audispd-plugin
echo "[+] Configurando regras de logs."
echo '#!/bin/sh' >/usr/bin/aushape-audispd-plugin
echo 'exec /usr/bin/aushape -l json --events-per-doc=none --fold=all -o syslog' >>/usr/bin/aushape-audispd-plugin
echo "[+] Executando permissões de escrita..."
chmod +x /usr/bin/aushape-audispd-plugin

# Cria o arquivo aushape.conf em /etc/audisp/plugins.d/

echo "[+] Criando .conf do aushape..."
cat <<EOF >/etc/audisp/plugins.d/aushape.conf
active = yes
direction = out
path = /usr/bin/aushape-audispd-plugin
type = always
format = string
EOF

# Reinicie o serviço auditd
echo "[+] Reinciando auditd..."
systemctl restart auditd

# Crie o arquivo rsyslog.conf
if [ -f "/etc/rsyslog.conf" ]; then
  echo -e "${YELLOW}[*] Backup do arquivo rsyslog.conf criado em /etc/rsyslog.conf.backup${NYEL}"
  mv /etc/rsyslog.conf /etc/rsyslog.conf.backup
fi

echo "[+] Recriando rsyslog.conf..."
cat <<EOF >/etc/rsyslog.conf
#################
#### MODULES ####
#################

module(load="imuxsock") # provides support for local system logging
module(load="imklog")   # provides kernel logging support


###########################
#### GLOBAL DIRECTIVES ####
###########################

$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

$FileOwner root
$FileGroup adm
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022

$WorkDirectory /var/spool/rsyslog

$IncludeConfig /etc/rsyslog.d/*.conf

###############
#### RULES ####
###############

auth,authpriv.*			/var/log/auth.log
*.*;auth,authpriv.none		-/var/log/syslog
# cron.*				/var/log/cron.log
# daemon.*			-/var/log/daemon.log
# kern.*				-/var/log/kern.log
# lpr.*				-/var/log/lpr.log
# mail.*				-/var/log/mail.log
user.*				-/var/log/user.log
local1.info

#
# Logging for the mail system.  Split it up so that
# it is easy to write scripts to parse these files.
#
# mail.info			-/var/log/mail.info
# mail.warn			-/var/log/mail.warn
# mail.err			/var/log/mail.err

#
# Some "catch-all" log files.
#
*.=debug;\
	auth,authpriv.none;\
	news.none;mail.none	-/var/log/debug
*.=info;*.=notice;*.=warn;\
	auth,authpriv.none;\
	cron,daemon.none;\
	mail,news.none		-/var/log/messages

#
# Emergencies are sent to everybody logged in.
#
*.emerg				:omusrmsg:*
*.*     	 	@@$ip_collector:514
local1.info		@@$ip_collector:514
EOF

# Reinicie o auditd e rsyslog
echo "[+] Reiniciando o auditd..."
systemctl restart auditd
echo "[+] Reiniciando o rsyslog..."
systemctl restart rsyslog

# Adicione comando à cron
echo "[+] Incluindo na cron o log de Heartbeat..."
echo "*/5 * * * * root logger -p local1.info -t heartbeat 'Heartbeat is active'" >>/etc/crontab

echo "[+] Saída da cron:" >> "$LOG_FILE"
cat /etc/crontab >> "$LOG_FILE"
cat /etc/crontab

# Salve o log em um arquivo .log
echo "Log criado em /var/log/install_script.log"
#exec >/var/log/install_script.log 2>&1

echo -e "${BLUE}Script concluído!${NBLUE}"
exec >&- 2>&-
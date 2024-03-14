#!/bin/bash

# o script é executado como root?
if [ "$(id -u)" != "0" ]; then
   echo "Este script deve ser executado como root" 1>&2
   exit 1
fi

CAMINHO_ATUAL=$(pwd)

# criando a pasta destino no /usr/local/bin se ela não existir
DESTINO="/usr/local/bin/Q1"
mkdir -p "$DESTINO"

# copiando toda a pasta para o destino bin 
cp -r "$CAMINHO_ATUAL"/* "$DESTINO/"

# olhando se q1.sh foi copiado com sucesso
if [ ! -f "$DESTINO/q1.sh" ]; then
    echo "Falha ao copiar q1.sh para $DESTINO."
    exit 2
fi

echo "q1.sh copiado para $DESTINO com sucesso."

# lógica de instalação de pacotes
echo "Instalando pacotes necessários..."

# Lista de pacotes necessários
pacotes=("bc" "ca-certificates" "lm-sensors" "msmtp")

# Loop através da lista de pacotes para verificar e instalar se necessário
for pacote in "${pacotes[@]}"; do
    if ! dpkg -l | grep -q "^ii.*$pacote"; then
        echo "O pacote $pacote não está instalado. Instalando..."
        sudo apt-get update
        sudo apt-get install -y "$pacote"

        # Verifica se a instalação foi bem-sucedida
        if [ $? -eq 0 ]; then
            echo "O pacote $pacote foi instalado com sucesso."
        else
            echo "Erro ao instalar o pacote $pacote."
            exit 1
        fi
    else
        echo "O pacote $pacote já está instalado."
    fi
done

# definir local padrão para o arquivo de configuração do msmtp. Importante pois pode existir outra configuração local.
# TO DO: péssima prática escrever os dados do MSMTP direto aqui, se eu tiver tempo faço a lógica com openssl, mas criei esse email só pra isso, então OK
MSMTP_CONFIG_FILE="/home/MSMTP/.msmtprc"
mkdir -p /home/MSMTP 
touch "$MSMTP_CONFIG_FILE" 

cat > "$MSMTP_CONFIG_FILE" <<EOF
# configuração default
defaults
auth on
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile /home/MSMTP/.msmtp.log

# configuração da conta Outlook
account outlook
host smtp-mail.outlook.com
port 587
from azeitonadoteste@hotmail.com
user azeitonadoteste@hotmail.com
password DeusEMais
account default : outlook
EOF

# permissões do arquivo de configuração
chmod 600 "$MSMTP_CONFIG_FILE"

echo "Configuração do msmtp concluída."

# crontab 
# pega o minuto e a hora atual
minuto_atual=$(date +'%M')
hora_atual=$(date +'%H')

# calcula o próximo minuto
proximo_minuto=$((minuto_atual + 1))

# se o próximo minuto for 60, a gente ajusta pra 0 e aumenta uma hora
if [ $proximo_minuto -eq 60 ]; then
    proximo_minuto=0
    hora_atual=$((hora_atual + 1))
    # se a hora for 24, ajusta pra 0, porque passou do dia
    if [ $hora_atual -eq 24 ]; then
        hora_atual=0
    fi
fi

# garante que o minuto e a hora tenham dois dígitos
proximo_minuto=$(printf "%02d" $proximo_minuto)
hora_atual=$(printf "%02d" $hora_atual)

# cria a linha pro crontab com o horário de daqui a 1 minuto
crontab_job="$proximo_minuto $hora_atual * * * /usr/local/bin/Q1/q1.sh"

# adiciona o novo job no crontab
(crontab -l 2>/dev/null; echo "$crontab_job") | crontab -

# o script no crontab pra rodar daqui a 1 minuto
echo "script adicionado ao crontab para execução às $hora_atual:$proximo_minuto todos os dias."
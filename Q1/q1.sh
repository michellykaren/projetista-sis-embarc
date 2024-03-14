#!/bin/bash

# defina os limites de alerta e quem irá receber o email
limite_particao=2 
limite_ram=12
limite_temp=50
dest_mail="azeitonadoteste@gmail.com"

# verifico o uso das partições
particoes=$(df | awk -v limite_particao="$limite_particao" '{gsub(/%/, "", $5); if (NR!=1 && $5+0 > limite_particao && $1 ~ "/dev/") print $1 " " $5"%"}')

# verifico uso de memória RAM
uso_ram=$(free | awk '/Mem/{print $3/$2 * 100}' | awk '{printf "%.2f", $1}')

# verifico temperatura dos cores
if ls /sys/class/thermal/thermal_zone*/temp 1> /dev/null 2>&1; then
    temperaturas=$(cat /sys/class/thermal/thermal_zone*/temp | awk -v limite_temp="$limite_temp" '{temp=$1/1000; if (temp > limite_temp) print temp"°C"}')
else
    temperaturas="Não foi possível verificar a temperatura. Verificação não compatível com a configuração de pastas atual do sistema."
fi

# defino o local padrão do arquivo de log com base na existência do diretório /usr/local/bin/Q1
if [ -d "/usr/local/bin/Q1" ]; then
    ARQUIVO_LOG="/usr/local/bin/Q1/q1.log"
    ARQUIVO_LOG="$(pwd)/q1.log"
else
    ARQUIVO_LOG="$(pwd)/q1.log"
fi

# verifico se o arquivo de log existe e o cria se necessário
if [ ! -f "$ARQUIVO_LOG" ]; then
    touch "$ARQUIVO_LOG"
fi

# verificando limites
if [ -n "$particoes" ] || [ "$(echo "$uso_ram > $limite_ram" | bc)" -eq 1 ] || [ -n "$temperaturas" ]; then
    # construindo mensagem de log
    mensagem_log="$(date '+%Y-%m-%d %H:%M:%S') - Uso de recursos acima do normal!\n"
    mensagem_log+="Limites definidos para partição, RAM e Temperatura: ${limite_particao}%, ${limite_ram}%, ${limite_temp}°C\n"
    if [ -n "$particoes" ]; then
        mensagem_log+="Partições acima do limite:\n$particoes\n"
    fi
    if [ "$temperaturas" != "Não foi possível verificar a temperatura. Verificação não compatível com a configuração de pastas atual do sistema." ]; then
        mensagem_log+="Temperaturas acima do limite:\n$temperaturas\n"
    else
        mensagem_log+="$temperaturas\n"
    fi
    mensagem_log+="Uso de RAM: $uso_ram%\n"
    
    # escrevendo no arquivo de log
    echo -e "$mensagem_log" >> "$ARQUIVO_LOG"

    # enviando email

    # determino o diretório home do usuário real
    if [ "$SUDO_USER" ]; then
        HOME_REAL_USER=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    else
        HOME_REAL_USER=$HOME
    fi

    # define o caminho do arquivo de configuração do msmtp para o usuário real
    MSMTP_CONFIG_FILE="/home/MSMTP/.msmtprc"

    # verificando se o arquivo de configuração já existe
    if [ -f "$MSMTP_CONFIG_FILE" ]; then
        echo "O arquivo de configuração $MSMTP_CONFIG_FILE será usado."
    else
        echo "O arquivo de configuração $MSMTP_CONFIG_FILE não foi encontrado. Configure antes de continuar."
        exit 1
    fi

    # corpo do email
    corpo_email="Subject: Uso dos recursos acima do normal\n\n${mensagem_log}"

    # envio do email
    echo -e "$corpo_email" | msmtp -a outlook --file="$MSMTP_CONFIG_FILE" "$dest_mail" 
        
fi

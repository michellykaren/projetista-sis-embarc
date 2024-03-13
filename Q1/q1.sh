#!/bin/bash

# definindo os limites de alerta
limite_particao=2 # Mudança aqui se desejar limites específicos
limite_ram=12

# verificando o uso das partições
particoes=$(df | awk -v limite_particao="$limite_particao" '{gsub(/%/, "", $5); if (NR!=1 && $5+0 > limite_particao && $1 ~ "/dev/") print $1 " " $5"%"}')

# verificando uso de memória RAM
uso_ram=$(free | awk '/Mem/{print $3/$2 * 100}' | awk '{printf "%.2f", $1}')

# se o arquivo de log existe
arquivo_log="q1.log"
if [ ! -f "$arquivo_log" ]; then
    touch "$arquivo_log"
fi

# verificando limites
if [ -n "$particoes" ] || [ "$(echo "$uso_ram > $limite_ram" | bc)" -eq 1 ]; then
    # construindo mensagem de log
    mensagem_log="$(date '+%Y-%m-%d %H:%M:%S') - Uso de recursos acima do normal!\n"
    mensagem_log+="Limites definidos para partição e RAM: ${limite_particao}%, ${limite_ram}%\n"
    if [ -n "$particoes" ]; then
        mensagem_log+="Partições acima do limite:\n$particoes\n"
    fi
    mensagem_log+="Uso de RAM: $uso_ram%\n"
    
    # escrevendo no arquivo de log
    echo -e "$mensagem_log" >> "$arquivo_log"

    # enviando email
    corpo_email="Subject: Uso dos recursos acima do normal\n\n${mensagem_log}"
    echo -e "$corpo_email" | msmtp -a outlook azeitonadoteste@gmail.com
fi

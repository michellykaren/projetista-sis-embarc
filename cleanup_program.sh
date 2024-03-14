#!/bin/bash

# 1. deletar pasta /usr/local/bin/Q1 com tudo dentro
echo "Deletando pasta /usr/local/bin/Q1..."
sudo rm -rf /usr/local/bin/Q1

# 2. deletar linhas no crontab que apontem para /usr/local/bin/Q1
echo "Removendo entradas do crontab referentes a /usr/local/bin/Q1..."
sudo crontab -l | grep -v '/usr/local/bin/Q1' | sudo crontab -

# 3. deletar pasta de configuração do MSMTP em /home/MSMTP/
echo "Deletando pasta de configuração do MSMTP em /home/MSMTP/..."
sudo rm -rf /home/MSMTP/

echo "Limpeza concluída."

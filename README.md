# Projeto de Avaliação de Nível Projetista Sistemas Embarcados

---

# Visão do projeto
O teste consiste em desafios divididos em 4 questões para avaliar o nível de conhecimento do candidato em linguagens C e C++, desenvolvimento em Linux, programação paralela, comunicação interprocessos e conhecimentos de sistemas de computação.

Tecnologias usadas:
*   Ubuntu 22.04.3 LTS
*   gcc version 11.4.0
*   Bash (Bourne Again SHell)
*   git

---

# Resumo dos Projetos Q1, Q2, Q3 e Q4

## Q1

### Problema:
Precisamos de um script que, executado pela crontab do sistema, verifica o uso das partições, memória RAM e a temperatura dos cores, enviando um e-mail de alerta e salvar em um arquivo log se qualquer um estiver acima do limite definido no script.

### Solução:
Utilizou-se o `crontab` para agendar a execução do script que faz as verificações e envia e-mails de alerta.
No script config_q1.sh foi feita toda a parte necessária para copiar script de monitoramento de recursos (q1.sh) no bin do sistema, configuração do protocolo para envio de email e instalação dos pacotes necessários. Durante a sua execução várias checagens são realizadas para evitar possíveis erros de path, de existência de arquivos e de configurações necessárias para o bom funcionamento do script.

### Execução:
Executar cada linha abaixo separadamente.

```bash
sudo -i
chmod +x Q1/config_q1.sh
./Q1/config_q1.sh
```

### Verificação de Bom Funcionamento:
Verifique a crontab com 
```bash
crontab -l
```
Verifique o log em /usr/local/bin/Q1:
```bash
[ -f "/usr/local/bin/Q1/q1.log" ] && echo "Presente" || echo "Ausente"
```
Verifique se recebeu o e-mail (azeitonadoteste@hotmail.com).

---
## Q2

### Problema:
Corrigir um código que inicializa várias threads para logar mensagens, mas que mostra essas mensagens fora de sincronia.

### Solução:
Usar um mutex para criar uma região crítica que sincroniza o acesso à saída, garantindo que as mensagens não sejam interrompidas.

### Execução:

Executar cada linha abaixo separadamente.

```bash
make
./q2.o
make clean
```

### Verificação de Bom Funcionamento:
Verifique no syslog com 

```bash
cat /var/log/syslog
```

---
## Q3

### Problema:
Criar um programa em C++ com duas threads: uma Produtora que lê um arquivo XML e envia conteúdo para uma fila, e uma Consumidora que lê dessa fila conteúdos específicos.

### Solução:
O produtor lê o arquivo XML, extrai informações com regex e coloca na fila. O consumidor processa esses dados. Usam-se mutex e variável de condição para sincronizar.

### Execução:

Executar cada linha abaixo separadamente.

```bash
make
./q3.o
make clean
```

### Verificação de Bom Funcionamento:
Verifique as saídas dos dados do payload no console e a criação/supressão do executável com make e make clean.

---
## Q4

### Problema:
Desenvolver um software em C para simular a leitura de imagens de uma câmera em tempo real e o processamento para TO DO

### Solução
Usamos `mkfifo` para criar um pipe nomeado, permitindo a comunicação entre os processos sem escrita em disco.

### Execução:

Executar cada linha abaixo separadamente.

```bash
gcc q4.c -o q4
./q4
```

### Verificação de Bom Funcionamento
Verifique no console:
- "Processo 1: Lendo imagem."
- "Processo 2: Processar e salvar imagem."
- "Processo 1: Imagem enviada."
- "Processo 2: Imagem salva."

Isso ilustra o funcionamento concorrente dos processos: embora o processo pai tenha começado primeiro, a velocidade de execução, o tempo que leva para ler e enviar os dados da imagem, e a pronta disponibilidade do processo filho para processar esses dados podem levar a uma situação em que o "processamento e salvamento da imagem" pelo processo filho é concluído antes do processo pai fazer o print do envio da imagem.


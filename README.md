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
Para executar o projeto faça o `git clone https://github.com/michellykaren/projetista-sis-embarc.git`, depois execute o terminal a partir da raiz do projeto `cd projetista-sis-embarc`. O tempo para a verificação de todas as questões é de 10 minutos a 30 minutos.

## Q1

### Problema:
Precisamos de um script que, executado pela crontab do sistema, verifica o uso das partições, memória RAM e a temperatura dos cores, enviando um e-mail de alerta e salvando em um arquivo log se qualquer um estiver acima do limite definido no script.

### Solução:
Utilizou-se o `crontab` para agendar a execução do script que faz as verificações e envia e-mails de alerta.
No script config_q1.sh foi feita toda a parte necessária para copiar script de monitoramento de recursos (q1.sh) no bin do sistema, configuração do protocolo para envio de email e instalação dos pacotes necessários. Durante a sua execução várias checagens são realizadas para evitar possíveis erros de path, de existência de arquivos e de configurações necessárias para o bom funcionamento do script.

### Execução:

Caso você queira mudar os limites de valores padrão e quem deve receber o email de notificação mude as linhas 4, 5, 6 e 7 de q1.sh.

```bash
4. limite_particao=0 
5. limite_ram=0
6. limite_temp=0
7. dest_mail="azeitonadoteste@gmail.com"
```

Após definir os limites de alerta e quem irá receber o email, execute os comandos a seguir a partir da raiz do projeto.
Executar cada linha abaixo separadamente.

```bash
sudo su
```
```bash
cd Q1
```
```bash
chmod +x config_q1.sh
```
```bash
./config_q1.sh
```
Se aparecer alguma opção de configuração de mail, escolha `No configuration` e se o msmtp configuration pedir algo, como na imagem abaixo, escolha `<No>`.

![image](https://github.com/michellykaren/projetista-sis-embarc/assets/29697453/530bad60-2559-415e-ab5c-3ecf749fde27)

### Verificação de Bom Funcionamento:
- Verifique a presença do script /usr/local/bin/Q1/q1.sh no crontab digitando o comando 
```bash
crontab -l
```

- Verifique se recebeu o e-mail de azeitonadoteste@hotmail.com um minuto após executar `./config_q1.sh`

- Em caso de limites ultrapassados, verifique o log em /usr/local/bin/Q1:
```bash
test -f "/usr/local/bin/Q1/q1.log" && echo "Presente" || echo "Ausente" 
```

```bash
cat /usr/local/bin/Q1/q1.log
```
---
## Q2

### Problema:
Corrigir um código que inicializa várias threads para logar mensagens, mas que mostra essas mensagens fora de sincronia.

### Solução:
Usar um mutex para criar uma região crítica que sincroniza o acesso à saída, garantindo que as mensagens não sejam interrompidas.

### Execução:

Executar cada linha abaixo separadamente.

```bash
cd Q2
```
```bash
make
```
```bash
./q2.o
```
```bash
make clean
```

### Verificação de Bom Funcionamento:
- Verifique a criação/supressão do executável com `make` e `make clean`.
- Verifique presença das mensagens organizadas no terminal e verifique no syslog com 

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
cd Q3
```
```bash
make
```
```bash
./q3.o
```
```bash
make clean
```

### Verificação de Bom Funcionamento:
- Verifique a criação/supressão do executável com `make` e `make clean`.

- Verifique as saídas dos dados do payload no console como na imagem abaixo:

![image](https://github.com/michellykaren/projetista-sis-embarc/assets/29697453/9c971640-49ce-4707-be52-62cf336f0731)

---
## Q4

### Problema:
Desenvolver um programa em C para simular a captura e processamento de imagens de veículos em tempo real, operando em dois processos distintos: um para ler imagens de uma câmera (real ou simulada) e outro para apenas receber e salvar essas imagens em disco. A comunicação entre os processos deve evitar o uso de disco e, ao invés, utilizar um método de Comunicação Inter-Processos (IPC) escolhido pelo desenvolvedor. Além disso, antes da transferência da imagem, o tamanho dela deve ser comunicado do Processo 1 para o Processo 2, garantindo um protocolo de comunicação entre eles.

### Solução:
Usa-se um pipe nomeado (FIFO) para a comunicação inter-processos (IPC), permitindo a comunicação unidirecional entre dois processos de forma simples. Outras opções incluem memória compartilhada ou Sockets UNIX.
Nessa solução o processo 1 lê um arquivo de imagem e envia seu conteúdo através de um pipe nomeado para o processo 2, que então salva a "imagem processada" em um novo arquivo. O código tenta remover o pipe nomeado ao final da execução para evitar a presença de um pipe nomeado não utilizado no sistema de arquivos.
O protocolo de comunicação garante que a imagem seja recebida corretamente, pois, antes de enviar a imagem propriamente dita, o Processo 1 envia o tamanho da imagem em bytes. O Processo 2 lê essa informação primeiro, sabendo assim quantos bytes esperar para a imagem. 

### Execução:

Executar cada linha abaixo separadamente.

```bash
cd Q4
```
```bash
make
```
```bash
./q4.o
```
### Verificação de Bom Funcionamento:
- Verifique a presença da imagem `processed_img1.jpg` em Q4/processed_img:
```bash
test -f /processed_img/processed_img1.jpg && echo "Imagem presente" || echo "Imagem ausente"  
```

- Verifique no console a seguinte mensagem:
"Processo 1: Lendo imagem."
"Processo 2: Processar e salvar imagem."
"Processo 1: Imagem enviada."
"Processo 2: Imagem salva."

Essas mensagens ilustram o funcionamento concorrente dos processos: embora o processo pai tenha começado primeiro, a velocidade de execução, o tempo que leva para ler e enviar os dados da imagem, e a pronta disponibilidade do processo filho para processar esses dados podem levar a uma situação em que o "processamento e salvamento da imagem" pelo processo filho é concluído antes do processo pai fazer o print do envio da imagem.

---
### SOS! Como limpar as configurações feitas?
Após validações, execute os comandos abaixo na raiz do projeto:

```bash
chmod +x cleanup_program.sh
```

```bash
./cleanup_program.sh
```

---
Qualquer dúvida, contato pelo email michellykaren15@gmail.com :)


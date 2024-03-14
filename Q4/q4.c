#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h>     // funções unix, como close() e read()
#include <fcntl.h>      // pra open(), que a gente usa pra abrir o pipe
#include <sys/stat.h>   // mkfifo() tá aqui
#include <sys/types.h>  // também é por mkfifo()

#define FIFO_PATH "/tmp/myfifo"     // onde o nosso pipe vai ficar
#define IMG_PATH "img/img1.jpg"     // caminho pra imagem que a gente quer ler
#define PROCESSED_IMG_PATH "processed_img/processed_img1.jpg"   // onde a gente vai salvar
#define BUFFER_SIZE 1024            // tamanho do buffer, pra não ler tudo de uma vez só

void readImage() {
    printf("Processo 1: Lendo imagem.\n");  // só pra gente saber que começou
    char buffer[BUFFER_SIZE];               // aqui a gente vai guardar pedaços da imagem
    FILE *img = fopen(IMG_PATH, "rb");      // abre a imagem pra leitura
    if (!img) {                             // se não conseguir abrir, dá um erro e para tudo
        perror("Failed to open image");
        exit(EXIT_FAILURE);
    }

    int fd = open(FIFO_PATH, O_WRONLY);     // abre o pipe pra escrita
    size_t bytes_read;                      // quantos bytes a gente leu
    while ((bytes_read = fread(buffer, 1, BUFFER_SIZE, img)) > 0) { // lê pedaço por pedaço
        write(fd, buffer, bytes_read);                              // e escreve no pipe
    }

    close(fd);                                  // fecha o pipe
    fclose(img);                                // fecha o arquivo da imagem
    printf("Processo 1: Imagem enviada.\n");    // avisa que terminou
}


void processImage() {
    printf("Processo 2: Processar e salvar imagem.\n"); 
    char buffer[BUFFER_SIZE];               // buffer de novo
    int fd = open(FIFO_PATH, O_RDONLY);     // abre o pipe, mas pra ler dessa vez
    FILE *processed_img = fopen(PROCESSED_IMG_PATH, "wb");  // abre o arquivo onde vai salvar
    if (!processed_img) {                                   // se der ruim, avisa e para
        perror("Failed to open processed image");
        exit(EXIT_FAILURE);
    }

    ssize_t bytes_read;                                         // aqui também vai contar os bytes lidos
    while ((bytes_read = read(fd, buffer, BUFFER_SIZE)) > 0) {  // lê do pipe
        fwrite(buffer, 1, bytes_read, processed_img);           // escreve no arquivo
    }

    close(fd);                              // fecha o pipe
    fclose(processed_img);                  // fecha o arquivo
    printf("Process 2: Imagem salva\n"); 
}

int main() {
    mkfifo(FIFO_PATH, 0666);    // cria o pipe

    pid_t pid = fork();         // divide o processo em dois

    if (pid < 0) {              // se der erro no fork, avisa
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if (pid > 0) {              // se for o processo pai
        readImage();            // lê a imagem e manda pelo pipe
    } else {                    // se for o processo filho
        processImage();         // pega do pipe e salva
    }

                                // se for o pai, limpa o pipe depois
    if (pid > 0) {
        unlink(FIFO_PATH);
    }

    return 0;
}

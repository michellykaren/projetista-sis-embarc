#include <iostream>
#include <fstream>
#include <string>
#include <queue>
#include <mutex>
#include <condition_variable> // pra poder esperar até ter algo na fila pra consumir
#include <thread>
#include <regex>

std::mutex mtex;            // o trinco pra controlar acesso à fila
std::condition_variable cv; // a condição pra esperar/sinalizar entre produtor/consumidor
std::queue<std::string> q;  // a fila de mensagens
bool done = false;          // pra saber quando terminou de produzir

void produtor() {
    std::cout << "Produtor iniciado.\n";
    std::ifstream input("input.xml");
    std::string line;
    std::string payload;
    std::regex payloadRegex("<payload>(.*?)</payload>");

    while (std::getline(input, line)) {

        std::smatch matches;                            // aqui guarda o resultado da busca pela regex

        if (std::regex_search(line, matches, payloadRegex) && matches.size() > 1) {
            payload = matches[1].str();                 // pega só a parte que interessa

            std::unique_lock<std::mutex> lock(mtex);    // trancou o trinco
            q.push(payload);                            // põe na fila
            std::cout << "Produtor: Mensagem " << payload << " adicionada.\n";
            cv.notify_one();                            // avisa que tem coisa nova
        }
    }

    std::unique_lock<std::mutex> lock(mtex);            // sinaliza que acabou
    done = true;
    cv.notify_all();
    std::cout << "Produtor concluído.\n";
}

void consumidor() {
    std::cout << "Consumidor iniciado.\n";              // vai ficar esperando ter algo na fila pra consumir
    std::unique_lock<std::mutex> lock(mtex);

    while (!done || !q.empty()) {                       // enquanto não terminou ou ainda tem coisa na fila
        cv.wait(lock, []{return done || !q.empty();});  // espera ter algo
        while (!q.empty()) {                            // enquanto tem coisa na fila
            std::string payload = q.front();            // pega a primeira
            q.pop();                                    // tira ela da fila
            lock.unlock();                              // libera o trinco pra outra thread poder usar

            std::cout << "Consumidor: " << payload << '\n';

            lock.lock();                                // trancou de novo pra próxima volta do loop
        }
    }
    std::cout << "Consumidor concluído.\n";
}

int main() {
    std::thread t1(produtor);
    std::thread t2(consumidor);

    t1.join();
    t2.join();

    return 0;
}

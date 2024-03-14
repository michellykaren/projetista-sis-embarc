#include <iostream>
#include <vector>
#include <thread>
#include <mutex>
#include <syslog.h>

static const int THREAD_COUNT = 10;

std::mutex mtex;

static void print_log(int id)
{
    // início da região crítica
    mtex.lock(); 
    syslog(LOG_INFO | LOG_USER, "--------------------");
    syslog(LOG_INFO | LOG_USER, "Iniciando bloco %d", id);
    syslog(LOG_INFO | LOG_USER, "Hello world from thread %d", id);
    syslog(LOG_INFO | LOG_USER, "Fim do bloco %d", id);
    syslog(LOG_INFO | LOG_USER, "--------------------");
    // final da região crítica
    mtex.unlock();
}

int main()
{
    // abre uma conexão com o syslog
    openlog("q2_app", LOG_CONS | LOG_PID | LOG_NDELAY, LOG_LOCAL1);

    std::vector<std::thread> v;

    for (int i = 0; i < THREAD_COUNT; ++i)
    {
        v.emplace_back(print_log, i);
    }

    for (auto &t : v)
    {
        t.join();
    }

    // fecha a conexão com o syslog
    closelog();

    return 0;
}


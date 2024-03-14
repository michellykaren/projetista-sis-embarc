#include <iostream>
#include <fstream>
#include <string>
#include <queue>
#include <mutex>
#include <condition_variable>
#include <thread>

using namespace std;

mutex mtex;
condition_variable cv;
queue<string> queue;
bool done = false;

void produtor() {
    ifstream input("Q3/input.xml");
    string line;
    string payload;
}

void consumidor() {}

int main() {
    thread t1(produtor);
    thread t2(consumidor);

    return 0;
}

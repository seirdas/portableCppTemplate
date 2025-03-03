#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <string>
#include "Producer.hpp"


Producer myProducer;
unsigned int myDataSize = 32;
bool stopThread = false;

void TSocketHost();

int main() {
    std::cout << "----------" << std::endl;
    stopThread = false;
    
    // Abrir primero el productor
    {
        // simular el socket abierto
        myProducer.start(myDataSize);

        std::this_thread::sleep_for(std::chrono::seconds(8));
    
        // Simular el lector de datos
        std::thread consumerThread(TSocketHost);
        std::this_thread::sleep_for(std::chrono::seconds(20));
    
        // Cerrar ambos
        stopThread = true;
        myProducer.stop();
        consumerThread.join();
        std::cout << " **MAIN: Productor y consumidor cerrados" << std::endl;
    }

    std::cout << "----------" << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(4));
    stopThread = false;

    // Abrir primero el consumidor
    {
        std::cout << " **MAIN: Abrir primero el consumidor" << std::endl;
    
        std::thread consumerThread(TSocketHost);
        std::this_thread::sleep_for(std::chrono::seconds(10));
        myProducer.start(myDataSize);
        std::this_thread::sleep_for(std::chrono::seconds(30));
    
        // Cerrar ambos
        stopThread = true;
        myProducer.stop();
        consumerThread.join();
        std::cout << " **MAIN: Productor y consumidor cerrados" << std::endl;
    }

    std::cout << "----------" << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(4));
    stopThread = false;

    // Abrir el consumidor y cerrar el productor entre medias
    {
        std::cout << " **MAIN: Abrir consumidor y cerrar productor" << std::endl;
    
        std::thread consumerThread(TSocketHost);
        std::this_thread::sleep_for(std::chrono::seconds(10));
        myProducer.start(myDataSize);
        std::this_thread::sleep_for(std::chrono::seconds(10));
        myProducer.stop();
        std::this_thread::sleep_for(std::chrono::seconds(10));
        myProducer.start(myDataSize);
        std::this_thread::sleep_for(std::chrono::seconds(10));
    
        // Cerrar ambos
        stopThread = true;
        consumerThread.join();
        std::cout << " **MAIN: Productor y consumidor cerrados" << std::endl;
    }



    return 0;
}



void TSocketHost(){
    unsigned int counter = 0;

    do {
        std::cout << " #Cons: waiting for data " << counter <<"..." << std::endl;
        std::string data = myProducer.getData();
        std::string data2;
        memcpy(&data2, &data, sizeof(data));
        std::cout << " #Cons: Data received:        " << data2 << std::endl;
        counter++;
    } while (!stopThread);

    std::cout << " #Cons: Consumer stopped" << std::endl;
}
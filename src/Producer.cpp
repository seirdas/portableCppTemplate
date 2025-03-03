
#include "Producer.h"



// General __________________________________________________________

Producer::Producer()  
{        }

Producer::~Producer() 
{        }


void Producer::start(unsigned int dataSize){
    this->dataSize = dataSize;
    stopThread = false;
    worker = std::thread(&workerThread, this);
}

void Producer::stop(){
    stopThread = true;
    worker.join();
}



// Actions __________________________________________________________

std::string Producer::getData(){
    // Wait for new data if the queue is empty
    std::unique_lock<std::mutex> lock(queueMutex); // Lock the mutex
    queueCV.wait(lock, [this]() { return !dataQueue.empty(); });

    // Get the front element
    std::string data = dataQueue.front();
    dataQueue.pop();
    return data;
}



// Hilo productor ___________________________________________________

void Producer::workerThread()
{
    std::cout << "    - PROD: Worker started" << std::endl;
    do {
        if (dataQueue.size() > (int)MAX_QUEUE_SIZE){
            std::cerr << " - PROD: !! Data queue overloaded !!" << std::endl;
            clearQueue();
        }

        std::string str = generate(dataSize);
        addToQueue(str);
        std::cout << "    - PROD: Data generated:   " << str << std::endl;

        queueCV.notify_one();
    } while (!stopThread);
    std::cout << "    - PROD: Worker closed" << std::endl;
}

std::string Producer::generate(unsigned int const dataSize){
        // simular el trabajo para obtener el dato (entre 0 a 2s)
        srand(static_cast<unsigned int>(std::time(nullptr)));
        unsigned int myTime = rand()%3000;
        std::this_thread::sleep_for(std::chrono::milliseconds(myTime));

        std::string result = "";
        result.resize(dataSize);

        result[0] = static_cast<char>(dataQueue.size());
        result[1] = '_';
        for (unsigned int i = 2; i < dataSize-1; i++) 
            result[i] = (char)(rand() % 94 + 33);

        return result;
}



// Queue ____________________________________________________________

void Producer::clearQueue() {
    std::lock_guard<std::mutex> lock(queueMutex);
    while (!dataQueue.empty()) 
        dataQueue.pop();
}

std::string Producer::getFirstElement() {
    std::lock_guard<std::mutex> lock(queueMutex);
    std::string element = dataQueue.front();
    dataQueue.pop();
    return element;
}

void Producer::addToQueue(std::string data) {
    std::lock_guard<std::mutex> lock(queueMutex);
    dataQueue.push(data);
}
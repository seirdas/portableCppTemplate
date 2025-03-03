
#include <iostream>
#include <thread>
#include <chrono>
#include <queue>
#include <mutex>
#include <condition_variable>
#include <string>

#define MAX_QUEUE_SIZE 4

class Producer {

    // General____________________________________________________________
    public:

        /// @brief default constructor
        Producer();

        /// @brief default destructor
        ~Producer();


        /// @brief Pone a correr el hilo productor
        void start(unsigned int dataSize);

        /// @brief Para el hilo productor
        void stop();

    private:
        bool stopThread = false;            // Flag para parar el hilo
        unsigned int dataSize;              // Tamaño de datos generados
    // Actions____________________________________________________________
    public:

        /// @brief Pide los datos de la cola de forma externa
        std::string getData();

    private:
        std::thread worker;                 // Thread productor
        std::queue<std::string> dataQueue;  // Cola de datos
        std::mutex queueMutex;              // Mutex to protect the queue
        std::condition_variable queueCV;    // Condition variable for waiting

        /// @brief Simula trabajo y genera los datos
        void workerThread();

        /// @brief Genera un string de datos aleatorios
        /// @param dataSize Tamaño de datos generados
        /// @return Datos generados
        std::string generate(unsigned int dataSize);

    // Queue ____________________________________________________________
    private:
        /// @brief Limpia la cola
        void clearQueue();
        
        /// @brief Devuelve el primer elemento de la cola y lo quita de la cola
        /// @return Primer elemento
        std::string getFirstElement();
        
        /// @brief Añade un elemento a la cola
        /// @param datos para añadir a la cola 
        void addToQueue(std::string data);

};
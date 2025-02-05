#include <iostream>
#include "defines.h"
#include "functions.h"

int calculate(int input){
    return (3+input)*2;
}

int main() {
    print(TEXT);
    int a = 0;
    int b = calculate(a);
    std::cout << b << std::endl;
    return 1;
}
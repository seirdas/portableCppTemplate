#include <iostream>
#include <SFML/Graphics.hpp>
#include <optional>

int main()
{
    std::cout << "Hello, SFML!" << std::endl;
    sf::RenderWindow window(sf::VideoMode({200, 200}), "SFML works!");

    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Yellow);

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        window.clear();
        window.draw(shape);
        window.display();
    }
}
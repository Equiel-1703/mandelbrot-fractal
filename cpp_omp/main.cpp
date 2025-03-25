#include "BMP.hpp"
#include <iostream>

#define IMG_SIZE 100

int main(int argc, char const *argv[])
{
    BMP bmp("teste.bmp", IMG_SIZE, IMG_SIZE);

    bmp.writePixel(0, 0, 255, 0, 0); // Red
    bmp.writePixel(1, 0, 0, 255, 0); // Green
    bmp.writePixel(2, 0, 0, 0, 255); // Blue
    bmp.writePixel(3, 0, 255, 255, 0); // Yellow
    bmp.writePixel(4, 0, 255, 0, 255); // Magenta
    bmp.writePixel(5, 0, 0, 255, 255); // Cyan

    bmp.save();
    
    std::cout << "BMP file created successfully!" << std::endl;

    return 0;
}

#include <iostream>
#include <complex>
#include <omp.h>

#include "BMP.hpp"

#define MAX_ITERATIONS 1'000
#define THRESHOLD 2.0

int calculateMandelbrot(double real, double img)
{
    std::complex<double> c(real, img);
    std::complex<double> z(0.0, 0.0);

    int i = 1;
    while (i < MAX_ITERATIONS)
    {
        z = z * z + c;

        if (std::abs(z) > THRESHOLD)
            break;

        ++i;
    }

    return i;
}

int main(int argc, char const *argv[])
{
    if (argc != 2)
    {
        std::cerr << "Usage: " << argv[0] << " <image_size>" << std::endl;
        return 1;
    }

    const int IMG_SIZE = std::stoi(argv[1]);
    if (IMG_SIZE <= 0)
    {
        std::cerr << "ERROR: Image size must be a positive integer." << std::endl;
        return 1;
    }

    if (IMG_SIZE > 100'000)
    {
        std::cerr << "ERROR: Image size is too large. Maximum size is 100,000." << std::endl;
        return 1;
    }

    const double x_min = -2.0, x_max = 2.0;
    const double y_min = -2.0, y_max = 2.0;
    const double scale = 0.5;

    int *fractals = new int[IMG_SIZE * IMG_SIZE];
    if (!fractals)
    {
        std::cerr << "ERROR: Memory allocation failed." << std::endl;
        return 1;
    }

    double start_time = omp_get_wtime();

#pragma omp parallel for schedule(dynamic, 1) collapse(2)
    for (int x = 0; x < IMG_SIZE; x++)
    {
        for (int y = 0; y < IMG_SIZE; y++)
        {
            double x_frac, y_frac;

            x_frac = x_min + (x_max - x_min) * (double(x) / double(IMG_SIZE));
            y_frac = y_min + (y_max - y_min) * (double(y) / double(IMG_SIZE));

            x_frac *= scale;
            y_frac *= scale;

            fractals[y * IMG_SIZE + x] = calculateMandelbrot(x_frac, y_frac);
        }
    }

    double end_time = omp_get_wtime();

    // Output the image (Sequential section)
    BMP bmp_image("mandelbort.bmp", IMG_SIZE, IMG_SIZE);

    for (int x = 0; x < IMG_SIZE; x++)
    {
        for (int y = 0; y < IMG_SIZE; y++)
        {
            int frac_val = fractals[y * IMG_SIZE + x];

            if (frac_val == MAX_ITERATIONS)
                bmp_image.writePixel(x, y, 0, 0, 0); // É parte do mandelbrot, pintamos de preto
            else
                bmp_image.writePixel(x, y, frac_val % 256, frac_val % 256 / 2, 0);
        }
    }

    bmp_image.save();

    std::cout << std::endl << "== Image saved successfully. ==\n";
    std::cout << "Fractal generated: mandelbrot.bmp\n";
    std::cout << "Image size: " << IMG_SIZE << "x" << IMG_SIZE << "\n";
    std::cout << "Max iterations: " << MAX_ITERATIONS << "\n";
    std::cout << "Threshold: " << THRESHOLD << "\n";
    std::cout << "Mandelbrot fractal generated successfully.\n\n";
    std::cout << "== Execution time: " << (end_time - start_time) << " seconds." << std::endl << std::endl;

    delete[] fractals;
    std::cout << "== Memory freed successfully. ==" << std::endl;
    return 0;
}

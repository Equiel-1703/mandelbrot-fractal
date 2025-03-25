#include <iostream>
#include <complex>

// Include OpenMP for measuring execution time
#include <omp.h>

#include "BMP.hpp"

#define MAX_ITERATIONS 1'000
#define THRESHOLD 2.0

__device__ int calculateMandelbrot(double real, double img)
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

__global__ void createFractal(int *fractals, int *img_size)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    int IMG_SIZE = *img_size;

    if (x >= IMG_SIZE || y >= IMG_SIZE)
        return;

    const double x_min = -2.0, x_max = 2.0;
    const double y_min = -2.0, y_max = 2.0;
    const double scale = 0.5;

    double x_frac, y_frac;

    x_frac = x_min + (x_max - x_min) * (double(x) / double(IMG_SIZE));
    y_frac = y_min + (y_max - y_min) * (double(y) / double(IMG_SIZE));

    x_frac *= scale;
    y_frac *= scale;

    fractals[y * IMG_SIZE + x] = calculateMandelbrot(x_frac, y_frac);
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

    // Pointers to memory in GPU
    int *fractals, *img_size;
    cudaError_t err;

    err = cudaMalloc(&fractals, IMG_SIZE * IMG_SIZE * sizeof(int));
    if (err != cudaSuccess)
    {
        std::cerr << "ERROR: Memory allocation failed on GPU." << std::endl;
        return 1;
    }

    err = cudaMalloc(&img_size, sizeof(int));
    if (err != cudaSuccess)
    {
        std::cerr << "ERROR: Memory allocation failed on GPU." << std::endl;
        cudaFree(fractals);
        return 1;
    }

    // Copy image size to GPU
    cudaMemcpy(img_size, &IMG_SIZE, sizeof(int), cudaMemcpyHostToDevice);

    // Get supported device properties
    cudaDeviceProp deviceProp;

    cudaGetDeviceProperties(&deviceProp, 0);
    std::cout << "== Device name: " << deviceProp.name << std::endl;
    std::cout << "== Maximum threads per block: " << deviceProp.maxThreadsPerBlock << std::endl;
    std::cout << "== Maximum blocks: " << deviceProp.maxGridSize[0] << " x " << deviceProp.maxGridSize[1] << " x " << deviceProp.maxGridSize[2] << std::endl;

    // Calculate the number of threads and blocks
    int threads_num = sqrt(deviceProp.maxThreadsPerBlock);
    int blocks_num = ceil(double(IMG_SIZE) / double(threads_num));
    
    dim3 threads(threads_num, threads_num, 1);
    dim3 blocks(blocks_num, blocks_num, 1);
    
    std::cout << "== Using blocks: " << blocks.x << " x " << blocks.y << std::endl;
    std::cout << "== Using threads: " << threads.x << " x " << threads.y << std::endl;

    // Start the timer
    double start_time = omp_get_wtime();

    // Launch kernel to create fractal
    createFractal<<<blocks, threads>>>(fractals, img_size);

    // Wait for GPU to finish
    cudaDeviceSynchronize();

    // Stop the timer
    double end_time = omp_get_wtime();

    // Check for errors in kernel launch
    err = cudaGetLastError();
    if (err != cudaSuccess)
    {
        std::cerr << "ERROR: Kernel launch failed: " << cudaGetErrorString(err) << std::endl;
        cudaFree(fractals);
        cudaFree(img_size);
        return 1;
    }

    // Copy fractal data back to CPU
    int *fractals_cpu = new int[IMG_SIZE * IMG_SIZE];
    err = cudaMemcpy(fractals_cpu, fractals, IMG_SIZE * IMG_SIZE * sizeof(int), cudaMemcpyDeviceToHost);
    if (err != cudaSuccess)
    {
        std::cerr << "ERROR: Memory copy failed from GPU to CPU." << std::endl;
        delete[] fractals_cpu;
        cudaFree(fractals);
        cudaFree(img_size);
        return 1;
    }
    // Free GPU memory
    cudaFree(fractals);
    cudaFree(img_size);
    fractals = nullptr;
    img_size = nullptr;

    // Output the image (Sequential section)
    BMP bmp_image("mandelbrot.bmp", IMG_SIZE, IMG_SIZE);

    for (int x = 0; x < IMG_SIZE; x++)
    {
        for (int y = 0; y < IMG_SIZE; y++)
        {
            int frac_val = fractals_cpu[y * IMG_SIZE + x];

            if (frac_val == MAX_ITERATIONS)
                bmp_image.writePixel(x, y, 0, 0, 0); // É parte do mandelbrot, pintamos de preto
            else
                bmp_image.writePixel(x, y, frac_val % 256, frac_val % 256 / 2, 0);
        }
    }

    bmp_image.save();

    std::cout << std::endl
              << "== Image saved successfully. ==\n";
    std::cout << "Fractal generated: mandelbrot.bmp\n";
    std::cout << "Image size: " << IMG_SIZE << "x" << IMG_SIZE << "\n";
    std::cout << "Max iterations: " << MAX_ITERATIONS << "\n";
    std::cout << "Threshold: " << THRESHOLD << "\n";
    std::cout << "Mandelbrot fractal generated successfully.\n\n";
    std::cout << "== Execution time: " << (end_time - start_time) << " seconds." << std::endl
              << std::endl;

    // Free CPU memory
    delete[] fractals_cpu;
    std::cout << "== Memory freed successfully. ==" << std::endl;
    return 0;
}

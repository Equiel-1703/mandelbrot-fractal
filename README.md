# Mandelbrot Fractal Generator

This project contains two parallel implementations of a Mandelbrot fractal generator that outputs the fractal as a BMP image. The implementations were developed as part of my Parallel Computing class and are written in C++ to leverage parallel computing for performance optimization.

![fractal_sample](https://github.com/user-attachments/assets/c8329dc2-6aa4-4bab-bd62-4e2150e8ffa4)

## Implementations

1. **C++ with OpenMP**  
    This version uses OpenMP to parallelize the computation of the Mandelbrot set across multiple CPU threads.

2. **C++ with CUDA**  
    This version utilizes CUDA to offload the computation to the GPU, achieving significant speedup for large fractals.

## Features

- Custom BMP class for generating and saving BMP images.
- High-performance parallel computation of the Mandelbrot set.
- Support for both CPU and GPU-based execution.

## Requirements

- A C++ compiler with OpenMP support (e.g., GCC or Clang).
- NVIDIA GPU and CUDA Toolkit for the CUDA implementation OR
- AMD Radeon GPU and ROCm for compiling with HIP tools (in fact, this was what I used for development and testing).

## Usage

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/mandelbrot-fractal.git
    cd mandelbrot-fractal
    ```

2. Choose which implementation you want to run:
    - For the OpenMP version, compile and run:
        ```bash
        cd cpp_omp
        make clean
        make all
        ./mandelbrot_omp <IMAGE_SIZE>
        ```
    - For the CUDA version, same steps:
        ```bash
        cd cuda
        make clean
        make all
        ./mandelbrot_cuda <IMAGE_SIZE>
        ```
    
    Replace `<IMAGE_SIZE>` with the desired size of the image (e.g., 800 for an 800x800 image).

## Output

The program generates a BMP image of the Mandelbrot fractal in the current directory where the executable is run. The image will be named `mandelbrot.bmp`.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Special thanks to the OpenMP, CUDA and AMD communities for their excellent documentation and tools.

Enjoy exploring the beauty of fractals! 😎

HIPIFY = hipify-clang
HIPCC = hipcc
CXXFLAGS = -Wall -std=c++17 -I$(COMMON_DIR) -fopenmp
OBJ_DIR = objs
COMMON_DIR = ../common

SRC_DIRS = . $(COMMON_DIR)

SRCS = $(wildcard $(foreach dir, $(SRC_DIRS), $(dir)/*.cpp))  # Find .cpp files
OBJS = $(patsubst %.cpp, $(OBJ_DIR)/%.o, $(notdir $(SRCS)))   # Convert .cpp to .o

CUDA_SRCS = $(wildcard $(foreach dir, $(SRC_DIRS), $(dir)/*.cu))  # Find .cu files
CUDA_OBJS = $(patsubst %.cu, $(OBJ_DIR)/%.o, $(notdir $(CUDA_SRCS)))   # Convert .cu to .o

EXECUTABLE = mandelbrot_cuda.out

all: $(EXECUTABLE)

$(EXECUTABLE): $(CUDA_OBJS) $(OBJS)
	$(HIPCC) $(CXXFLAGS) -o $(EXECUTABLE) $(CUDA_OBJS) $(OBJS)

$(OBJ_DIR)/%.o: %.cpp | $(OBJ_DIR)
	$(HIPCC) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(COMMON_DIR)/%.cpp | $(OBJ_DIR)
	$(HIPCC) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/%.hip: %.cu | $(OBJ_DIR)
	$(HIPIFY) -I$(COMMON_DIR) $< -o $@

$(OBJ_DIR)/%.o: $(OBJ_DIR)/%.hip | $(OBJ_DIR)
	$(HIPCC) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

clean:
	rm -f $(OBJ_DIR)/*.o $(EXECUTABLE)
	rm -f $(OBJ_DIR)/*
	rm -f *.bmp
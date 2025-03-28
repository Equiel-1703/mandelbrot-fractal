HIPIFY = hipify-clang
HIPCC = hipcc
CXXFLAGS = -Wall -std=c++17 -I$(COMMON_DIR) -fopenmp
OBJ_DIR = objs
COMMON_DIR = ../common

SRC_DIRS = . $(COMMON_DIR)

CPP_SRCS = $(wildcard $(foreach dir, $(SRC_DIRS), $(dir)/*.cpp))  # Find .cpp files
CPP_OBJS = $(patsubst %.cpp, $(OBJ_DIR)/%.o, $(notdir $(CPP_SRCS)))   # Convert .cpp to .o

CUDA_SRCS = $(wildcard $(foreach dir, $(SRC_DIRS), $(dir)/*.cu))  # Find .cu files
HIP_OBJS = $(patsubst %.cu, $(OBJ_DIR)/%.o, $(notdir $(CUDA_SRCS)))   # Convert .cu to .o

EXECUTABLE = mandelbrot_cuda.out

all: $(EXECUTABLE)

# Rule to create the final executable
$(EXECUTABLE): $(HIP_OBJS) $(CPP_OBJS)
	$(HIPCC) $(CXXFLAGS) -o $(EXECUTABLE) $(HIP_OBJS) $(CPP_OBJS)

# Rule to compile .cpp files
$(OBJ_DIR)/%.o: %.cpp | $(OBJ_DIR)
	$(HIPCC) $(CXXFLAGS) -c $< -o $@

# Rule to compile .cpp files from common directory
$(OBJ_DIR)/%.o: $(COMMON_DIR)/%.cpp | $(OBJ_DIR)
	$(HIPCC) $(CXXFLAGS) -c $< -o $@

# Rule to convert CUDA .cu files to HIP .hip files
$(OBJ_DIR)/%.hip: %.cu | $(OBJ_DIR)
	$(HIPIFY) -I$(COMMON_DIR) $< -o $@

# Rule to compile .hip files
$(OBJ_DIR)/%.o: $(OBJ_DIR)/%.hip | $(OBJ_DIR)
	$(HIPCC) $(CXXFLAGS) -c $< -o $@

# Rule to create the object directory if it doesn't exist
$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

clean:
	rm -f $(OBJ_DIR)/*.o
	rm -f $(EXECUTABLE)
	rm -f *.bmp
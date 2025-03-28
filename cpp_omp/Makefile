CXX = g++
CXXFLAGS = -Wall -std=c++17 -I$(COMMON_DIR) -fopenmp
OBJ_DIR = objs
COMMON_DIR = ../common

SRC_DIRS = . $(COMMON_DIR)

SRCS = $(wildcard $(foreach dir, $(SRC_DIRS), $(dir)/*.cpp))  # Find .cpp files
OBJS = $(patsubst %.cpp, $(OBJ_DIR)/%.o, $(notdir $(SRCS)))   # Convert .cpp to .o

EXECUTABLE = mandelbrot_omp.out

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(EXECUTABLE) $(OBJS)

$(OBJ_DIR)/%.o: %.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(COMMON_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

clean:
	rm -f $(OBJ_DIR)/*.o $(EXECUTABLE)
	rm -f $(OBJ_DIR)/*
	rm -f *.bmp
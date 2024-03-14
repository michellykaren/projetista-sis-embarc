CXX=g++
CXXFLAGS=-Wall -std=c++11 -pthread
LDFLAGS=-pthread
TARGET=q3

all: $(TARGET)

$(TARGET): q3.cpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) q3.cpp $(LDFLAGS)

clean:
	rm -f $(TARGET)
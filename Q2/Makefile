CXX=g++
CXXFLAGS=-Wall -std=c++11 -pthread
LDFLAGS=-pthread
TARGET=q2

all: $(TARGET)

$(TARGET): q2.cpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) q2.cpp $(LDFLAGS)

clean:
	rm -f $(TARGET)

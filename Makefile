OPENLIBM_INC := $(shell pkg-config --cflags-only-I openlibm 2>/dev/null || echo "-I/opt/homebrew/opt/openlibm/include/openlibm -I/usr/include/openlibm")
OPENLIBM_LIB := $(shell pkg-config --libs openlibm 2>/dev/null || echo "-L/opt/homebrew/opt/openlibm/lib -lopenlibm")
CXXFLAGS := -O2 -ffp-contract=off $(OPENLIBM_INC)

main: main.o Worm.o WormBody.o NervousSystem.o StretchReceptor.o Muscles.o TSearch.o random.o
	g++ -pthread -o main main.o Worm.o WormBody.o NervousSystem.o StretchReceptor.o Muscles.o TSearch.o random.o $(OPENLIBM_LIB)
random.o: random.cpp random.h VectorMatrix.h
	g++ -c $(CXXFLAGS) random.cpp
TSearch.o: TSearch.cpp TSearch.h
	g++ -c $(CXXFLAGS) TSearch.cpp
Worm.o: Worm.cpp Worm.h
	g++ -c $(CXXFLAGS) Worm.cpp
WormBody.o: WormBody.cpp WormBody.h
	g++ -c $(CXXFLAGS) WormBody.cpp
NervousSystem.o: NervousSystem.cpp NervousSystem.h VectorMatrix.h random.h
	g++ -c $(CXXFLAGS) NervousSystem.cpp
StretchReceptor.o: StretchReceptor.cpp StretchReceptor.h
	g++ -c $(CXXFLAGS) StretchReceptor.cpp
Muscles.o: Muscles.cpp Muscles.h VectorMatrix.h random.h
	g++ -c $(CXXFLAGS) Muscles.cpp
main.o: main.cpp Worm.h WormBody.h StretchReceptor.h Muscles.h TSearch.h
	g++ -c $(CXXFLAGS) main.cpp
clean:
	rm -f *.o main

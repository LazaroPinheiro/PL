CFLAGS=$(shell pkg-config --cflags glib-2.0)
LFLAGS=$(shell pkg-config --libs glib-2.0)

TP1: TP1.fl
	flex -o TP1.c TP1.fl
	cc $(CFLAGS) -o TP1 TP1.c $(LFLAGS)

clean:
	rm TP1
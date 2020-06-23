CFLAGS=$(shell pkg-config --cflags glib-2.0)
LFLAGS=$(shell pkg-config --libs glib-2.0)

DSL: DSL.fl
	flex -o DSL.c DSL.fl
	cc $(CFLAGS) -o DSL DSL.c $(LFLAGS)

clean:
	rm -f DSL
	rm -f *.c
	rm -f *.h
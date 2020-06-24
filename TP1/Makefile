CFLAGS=$(shell pkg-config --cflags glib-2.0)
LFLAGS=$(shell pkg-config --libs glib-2.0)

TP1: step1.fl
	flex -o step1.c step1.fl
	cc $(CFLAGS) -o TP1 step1.c $(LFLAGS)

clean:
	if [ -a TP1 ]; then rm TP1; fi;
	rm -f a.out
	rm -f *.txt
	rm -f *.json
	rm -f *.c
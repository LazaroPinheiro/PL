CFLAGS=$(shell pkg-config --cflags glib-2.0)
LFLAGS=$(shell pkg-config --libs glib-2.0)

DSL: DSL.fl DSL.y
	flex DSL.fl
	yacc -d DSL.y
	cc $(CFLAGS) y.tab.c lex.yy.c -o DSL $(LFLAGS)


clean:
	rm -f DSL *.c *.h
	if [ -a base ]; then rm -r base; fi;
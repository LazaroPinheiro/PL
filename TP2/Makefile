SHELL=bash
a=DSL

$a:  $a.fl $a.y
	flex $a.fl
	yacc -d $a.y
	cc -o $a y.tab.c lex.yy.c -lm

clean:
	rm -f $a lex.yy.c y.tab.* 
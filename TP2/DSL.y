%{
    int yylex();
    void yyerror(char*);
    #include<stdio.h>
    #include<string.h>
    #include<math.h>
    #include<stdlib.h>
%}

%union{
    char* string;
}

%token CONCEITO TITULO SUBTITULO CONTEUDO PARAGRAFO
%type <string> CONCEITO TITULO SUBTITULO CONTEUDO

%%



%%

int main(int argc, char* argv[]){
	if(argc == 2){yyin = fopen(argv[1],"r");}
    yyparse();
	return 0;
}

void yyerror(char* s){
    extern int yylineno;
    extern char* yytext;
    fprintf(stderr,"linha %d: %s (%s)\n",yylineno,s, yytext);
}
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

<<<<<<< Updated upstream
=======
caderno : caderno par
        |
        ;

par : documento triplos
    ;

documento : CONCEITO TITULO topicos                 { printf("CONCEITO: %s\n", $1); printf("TITULO: %s\n", $2); }
          ;

topicos : topicos SUBTITULO texto                   { printf("SUBTITULO: %s\n", $2); }
        |
        ;

texto : texto CONTEUDO                              { printf("%s\n", $2); }
      | texto PARAGRAFO                             { printf("%s\n", $2); printf("Paragrafo\n"); }
      | CONTEUDO                                    { printf("%s\n", $1); }
      | PARAGRAFO                                   { printf("%s\n", $1); printf("Paragrafo\n"); }
      ;

triplos : triplos SUJEITO relacoes                  { printf("SUJEITO: %s\n", $2); }
        |
        ;

relacoes : relacoes RELACAO objectos                { printf("RELACAO: %s\n", $2); }
         | RELACAO objectos                         { printf("RELACAO: %s\n", $1); }
         ;
>>>>>>> Stashed changes


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
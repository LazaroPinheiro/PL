%{
    #define _GNU_SOURCE

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>

    int yylex();
    void yyerror(char*);
    void generate(char*);
%}

%union{
    char* string;
}

%token CONCEITO TITULO SUBTITULO CONTEUDO PARAGRAFO SUJEITO RELACAO OBJECTO
%type <string> CONCEITO TITULO SUBTITULO PARAGRAFO CONTEUDO SUJEITO RELACAO OBJECTO

%%

caderno : caderno par
        |
        ;

par : documento triplos
    ;

documento : CONCEITO TITULO topicos                 { generate($1); }
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

objectos : objectos OBJECTO                         { printf("OBJECTO: %s\n", $2); }
         | OBJECTO                                  { printf("OBJECTO: %s\n", $1); }
         ;

%%

void generate(char* name){
    if(name){
        char* command = malloc((32 + strlen(name))*sizeof(char));
        strcat(command, "cd base;");
        strcat(command, "mkdir ");
        strcat(command, name);
        strcat(command, ";cd ");
        strcat(command, name);
        strcat(command, ";touch ");
        strcat(command, name);
        strcat(command, ".html");
        system(command);
        free(command);
    }
}


int main(int argc, char* argv[]){
    system("mkdir base");
    system("cd base ; touch index.html");
    yyparse();
	return 0;
}

void yyerror(char* s){
    extern int yylineno;
    extern char* yytext;
    fprintf(stderr,"linha %d: %s (%s)\n",yylineno,s, yytext);
}
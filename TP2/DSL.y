%{
    #define _GNU_SOURCE

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include <unistd.h>
    #include <fcntl.h>
    #include <glib.h>

    int yylex();
    void yyerror(char*);
    void generateConceito(char*, char*);
    void writeInIndexHtml(char* path, char* name);

    char* indexPath = "base/index.html";
    GString* text;
%}

%union{
    char* string;
}

%token CONCEITO TITULO SUBTITULO CONTEUDO PARAGRAFO SUJEITO RELACAO OBJECTO
%type <string> CONCEITO TITULO SUBTITULO PARAGRAFO CONTEUDO SUJEITO RELACAO OBJECTO topicos

%%

caderno : caderno par
        |
        ;

par : documento triplos
    ;

documento : CONCEITO TITULO topicos                 { generateConceito($1, $2); g_string_erase(text, 0, -1); }
          ;

topicos : topicos SUBTITULO texto                   { char* aux; asprintf(&aux, "<h3>%s</h3>\n", $2); g_string_append(text,aux); free(aux); }
        |                                           {}
        ;

texto : texto CONTEUDO                              //{ printf("%s\n", $2); }
      | texto PARAGRAFO                             //{ printf("%s\n", $2); printf("Paragrafo\n"); }
      | CONTEUDO                                    //{ printf("%s\n", $1); }
      | PARAGRAFO                                   //{ printf("%s\n", $1); printf("Paragrafo\n"); }
      ;

triplos : triplos SUJEITO relacoes                  //{ printf("SUJEITO: %s\n", $2); }
        |
        ;

relacoes : relacoes RELACAO objectos                //{ printf("RELACAO: %s\n", $2); }
         | RELACAO objectos                         //{ printf("RELACAO: %s\n", $1); }
         ;

objectos : objectos OBJECTO                         //{ printf("OBJECTO: %s\n", $2); }
         | OBJECTO                                  //{ printf("OBJECTO: %s\n", $1); }
         ;

%%

void generateConceito(char* conceito, char* titulo){
    if(conceito && titulo){
        char *command, *path;
        asprintf(&command,"cd base;mkdir %s;cd %s;touch %s.html",conceito, conceito, conceito);
        system(command);
        free(command);

        asprintf(&path,"base/%s/%s.html",conceito, conceito);
        FILE* file = fopen(path,"w");
        fprintf(file, "<h1>%s</h1>\n<h2>%s</h2>", conceito,titulo);
        fclose(file);
        writeInIndexHtml(path+5, conceito);
        free(path);
    }
}


void writeInIndexHtml(char* path, char* name){

    if(path && name){
        
        char *command; 
        asprintf(&command, "cd base;grep -w -c \"%s\" index.html > output", name);
        system(command);
        free(command);

        FILE* f = fopen("base/output", "r");
        char buffer[2];

        fgets(buffer, sizeof(buffer), f);

        if(buffer[0] == '0'){
            FILE* file = fopen(indexPath,"a");
            fprintf(file, "<a href='%s'><li>%s</li></a>\n", path, name);
            fclose(file);
        }

        system("cd base; rm -f output");
    }
}


int main(int argc, char* argv[]){
    text = g_string_new(NULL);
    system("mkdir base");
    system("cd base ; touch index.html");
    FILE* file = fopen(indexPath,"w");
    fprintf(file, "<h1>Conceitos</h1>\n\n");
    fclose(file);
    yyparse();
	return 0;
}

void yyerror(char* s){
    extern int yylineno;
    extern char* yytext;
    fprintf(stderr,"linha %d: %s (%s)\n",yylineno,s, yytext);
}
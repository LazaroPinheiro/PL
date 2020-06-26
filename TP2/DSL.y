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
    void addText(char*, char*);
    void writeInIndexHtml(char*, char*);

    char* indexPath = "base/index.html";
%}

%union{
    char* string;
}

%token CONCEITO TITULO SUBTITULO CONTEUDO SUJEITO RELACAO OBJECTO
%type <string> CONCEITO TITULO SUBTITULO CONTEUDO SUJEITO RELACAO OBJECTO topicos texto

%%

caderno : caderno par
        |
        ;

par : documento triplos
    ;

documento : CONCEITO TITULO topicos                 { generateConceito($1, $2); addText($1, $3); }
          ;

topicos : topicos SUBTITULO texto                   { asprintf(&$$, "<h3>%s</h3>\n%s", $2, $3); }
        |                                           {}
        ;

texto : texto CONTEUDO                              { asprintf(&$$, "<p>%s</p>\n", $2); }
      | CONTEUDO                                    //{ printf("%s\n", $1); }
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
        fprintf(file, "<!DOCTYPE html>\n\t<html lang=\"pt-pt\">\n\t<head>\n\t\t<title>%s</title>\n\t\t<meta charset=\"utf-8\">\n\t</head>\n\t<body>\n",conceito);
        fprintf(file, "\t\t<div class=\"documento\">\n\t\t\t<h1>%s</h1>\n\t\t\t<h2>%s</h2>", conceito,titulo);
        fclose(file);
        writeInIndexHtml(path+5, conceito);
        free(path);
    }
}


void addText(char* conceito, char* texto){
    if(conceito && texto){
        char* path;
        asprintf(&path,"base/%s/%s.html",conceito, conceito);
        FILE* file = fopen(path,"a");
        fprintf(file, "%s", texto);
        fclose(file);
        free(path);
    }
}

/*
 *  actions in index.html
 */

void generateIndexHtml(){
    system("mkdir base");
    system("cd base ; touch index.html");
    FILE* file = fopen(indexPath,"w");
    fprintf(file, "<!DOCTYPE html>\n\t<html lang=\"pt-pt\">\n\t<head>\n\t\t<title>index</title>\n\t\t<meta charset=\"utf-8\">\n\t</head>\n\t<body>\n");
    fprintf(file, "\t\t<div class=\"index\">\n\t\t\t<h1>Conceitos</h1>\n\n");
    fclose(file);
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
            fprintf(file, "\t\t\t<a href='%s'><li>%s</li></a>\n", path, name);
            fclose(file);
        }

        system("cd base; rm -f output");
    }
}

void finalizeIndexHtml(){
    FILE* file = fopen(indexPath,"a");
    fprintf(file, "\t\t</div>\n\t</body>\n</html>");
    fclose(file);
}


int main(int argc, char* argv[]){
    generateIndexHtml();
    yyparse();
    finalizeIndexHtml();
	return 0;
}

void yyerror(char* s){
    extern int yylineno;
    extern char* yytext;
    fprintf(stderr,"linha %d: %s (%s)\n",yylineno,s, yytext);
}
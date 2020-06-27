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

topicos : topicos SUBTITULO texto                   { asprintf(&$$,"%s\t\t\t\t<h3>%s</h3>\n%s", $1, $2,$3); }
        |                                           { asprintf(&$$,"");}
        ;

texto : texto CONTEUDO                              { asprintf(&$$,"%s\t\t\t\t<p>%s</p>\n\n", $1, $2);}
      |                                             { asprintf(&$$,"");}
      ;

triplos : triplos SUJEITO relacoes                  {  }
        |
        ;

relacoes : relacoes RELACAO objectos                {  }
         |                                          {  }
         ;

objectos : objectos OBJECTO                         {  }
         |                                          {  }
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
        fprintf(file, "<!DOCTYPE html>\n\t<html lang=\"pt-pt\">\n\t<head>\n\t\t<title>%s</title>\n\t\t<meta charset=\"utf-8\">\n\t</head>\n\t<body>\n\t\t<div class=\"documento\">\n\t\t\t<h1>%s</h1>\n\t\t\t<h2>%s</h2>\n", conceito, conceito,titulo);
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
        fprintf(file, "\t\t\t<div class=\"topicos\">\n%s\t\t\t</div>\n\t\t</div>\n", texto);
        fclose(file);
        free(path);
    }
}

/*
 *  actions in index.html
 */

void generateIndexHtml(){
    system("mkdir base ; cd base ; touch index.html");
    FILE* file = fopen(indexPath,"w");
    fprintf(file, "<!DOCTYPE html>\n\t<html lang=\"pt-pt\">\n\t<head>\n\t\t<title>index</title>\n\t\t<meta charset=\"utf-8\">\n\t</head>\n\t<body>\n\t\t<div class=\"index\">\n\t\t\t<h1>Conceitos</h1>\n");
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
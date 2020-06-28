%{
    #define _GNU_SOURCE
    #define FALSE 0
    #define TRUE 1
    #define NUM_MAX_IMAGES 5

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include <unistd.h>
    #include <fcntl.h>
    #include <glib.h>

    int yylex();
    void yyerror(char*);

    void fileGenerator(char*, int);
    void addText(char*, char*, char*);
    void generateTriplo (char*);
    void addTriplos(char*, char*);
    char* formatName (char*);
    void writeInIndexHtml(char*, char*);
    void addImages (char*);

    char* indexPath = "base/index.html";

    typedef struct imagens {
        char* sujeito;
        int numImgs;
        char* imgs[NUM_MAX_IMAGES];
    } *Imagens;

    GArray *buff;

    char* imgs[NUM_MAX_IMAGES];
    int imageCount = 0;
%}

%union{
    char* string;
}

%token CONCEITO TITULO SUBTITULO CONTEUDO SUJEITO RELACAO OBJECTO IMAGEM
%type <string> CONCEITO TITULO SUBTITULO CONTEUDO SUJEITO RELACAO OBJECTO IMAGEM topicos texto triplos relacoes objectos documento

%%

caderno : caderno par
        |
        ;

par : documento triplos                             { addTriplos($1, $2); } 
    ;

documento : CONCEITO TITULO topicos                 { fileGenerator($1, TRUE); addText($1, $2, $3); }
          ;

topicos : topicos SUBTITULO texto                   { asprintf(&$$, "%s\t\t\t\t<h3>%s</h3>\n%s", $1, $2, $3); }
        |                                           { asprintf(&$$, "");}
        ;

texto : texto CONTEUDO                              { asprintf(&$$, "%s\t\t\t\t<p>%s</p>\n\n", $1, $2); }
      |                                             { asprintf(&$$, "");}
      ;

triplos : triplos SUJEITO relacoes                  { generateTriplo($2); asprintf(&$$, "%s\t\t\t<ul data-role=\"treeview\">\n\t\t\t\t<a href=\"../%s/%s.html\">\n\t\t\t\t\t<h4>%s</h4>\n\t\t\t\t</a>\n\t\t\t\t<ul>%s\n\t\t\t\t</ul>\n\t\t\t</ul>\n", $1, formatName($2), formatName($2), $2, $3); addImages($2); }
        |                                           { asprintf(&$$, ""); }
        ;

relacoes : relacoes RELACAO objectos                { asprintf(&$$, "%s\n\t\t\t\t\t<ul data-role=\"treeview\">\n\t\t\t\t\t\t<h5>%s</h5>\n\t\t\t\t\t\t<ul>\n%s\t\t\t\t\t\t</ul>\n\t\t\t\t\t</ul>", $1, $2, $3); }
         |                                          { asprintf(&$$, ""); }
         ;

objectos : objectos OBJECTO                         { generateTriplo($2); asprintf(&$$, "%s\t\t\t\t\t\t\t<a href=\"../%s/%s.html\">\n\t\t\t\t\t\t\t\t<p>%s</p>\n\t\t\t\t\t\t\t</a>\n", $1, formatName($2), formatName($2), $2); }
         | objectos IMAGEM                          { asprintf(&$$, "%s", $1); asprintf(imgs+imageCount, "%s", $2); imageCount++; }
         |                                          { asprintf(&$$, ""); }
         ;

%%

// Gerar o ficheiro HTLM
void fileGenerator(char* name, int isConcept){
    if(name){
         char *command, *path;
         char* nameFormated = formatName(name);
        asprintf(&path,"base/%s/%s.html", nameFormated, nameFormated);

        if (access(path, F_OK) == -1){
            asprintf(&command,"cd base;mkdir %s;cd %s;touch %s.html", nameFormated, nameFormated, nameFormated);
            system(command);
            free(command);

            FILE* file = fopen(path,"w");
            fprintf(file, "<!DOCTYPE html>\n\t<html lang=\"pt-pt\">\n\t<head>\n\t\t<title>%s</title>\n\t\t<meta charset=\"utf-8\">\n\t\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n\t\t<link rel=\"stylesheet\" href=\"https://www.w3schools.com/w3css/4/w3.css\">\n\t\t<style>\n\t\t\tdiv.triplos {border: 1px solid black;padding: 25px 50px 75px 100px;background-color: lightblue;}\n\t\t\tdiv.cabecalho {\n\t\t\t\ttext-align: center;\n\t\t\t}\n\t\t\tdiv.imagens {\n\t\t\t\twidth:100%%;\n\t\t\t\ttext-align:center;\n\t\t\t}\n\t\t\tdiv.imagem {\n\t\t\t\tdisplay:inline-block;\n\t\t\t}\n\t\t</style>\n\t</head>\n\t<body>\n\t\t<div class=\"w3-bar w3-black\">\n\t\t\t<a href=\"../../%s\" class=\"w3-bar-item w3-button\">Home</a>\n\t\t</div>\n\t\t<div class=\"cabecalho\">\n\t\t\t<h1>%s</h1>\n\t\t</div>\n", nameFormated, indexPath, name);
            fclose(file);
        }

        if(isConcept){
            writeInIndexHtml(path+5, name);
        } 

        free(path);
    }
}

// Adicionar texto ao ficheiro HTLM
void addText(char* conceito, char* subtitulo, char* texto){
    if(conceito && subtitulo && texto){
        char* path;
        asprintf(&path,"base/%s/%s.html",conceito, conceito);
        FILE* file = fopen(path,"a");
        fprintf(file, "\n\t\t<div class=\"documento\">\n\t\t\t<div class=\"cabecalho\">\n\t\t\t\t<h2>%s</h2>\n\t\t\t</div>\n\t\t\t<div class=\"topicos\">\n%s\t\t\t</div>\n\t\t</div>\n", subtitulo, texto);
        fclose(file);
        free(path);
    }
}

// Adicionar os triplos ao ficheiro HTML
void addTriplos (char* conceito, char* texto){
    if(conceito && texto){
        char* path;
        asprintf(&path,"base/%s/%s.html",conceito, conceito);
        FILE* file = fopen(path,"a");
        fprintf(file, "\t\t<div class=\"triplos\">\n\t\t\t<div class=\"cabecalho\">\n\t\t\t\t<h2>Triplos</h2>\n\t\t\t</div>\n%s\t\t</div>\n", texto);
        fclose(file);
        free(path);
    }
}

// Gerar o ficheiro HTML para cada sujeito/objeto
void generateTriplo (char* name) {

    if (name[strlen(name)-1] == ' ') name[strlen(name)-1] = '\0';

    char* nameFormated = formatName(name);

    char* path;
    asprintf(&path, "base/%s", nameFormated);

    fileGenerator(name, FALSE);

    free(path);
}

// Formatar o nome de um sujeito/objeto
char* formatName (char* name) {
    char* nameFormated;
    asprintf(&nameFormated, "%s", name);

    for (int i = 0; nameFormated[i] != '\0'; i++){
        if (nameFormated[i] == ' ') nameFormated[i] = '_';
    }

    return nameFormated;
}

// Adicionar as imagens ao ficheiro HTML
void addImages (char* sujeito){

    if (sujeito[strlen(sujeito)-1] == ' ') sujeito[strlen(sujeito)-1] = '\0';

    if(imageCount > 0){
        int found = 0;
        Imagens imagens;

        for(int i = 0 ; i < buff->len && !found ; i++){
            imagens = g_array_index(buff, Imagens, i);
            if(strcmp(imagens->sujeito, sujeito) == 0){
                found = 1;
                for (int i = imagens->numImgs; i < imagens->numImgs + imageCount && i < NUM_MAX_IMAGES; i++){
                    asprintf(imagens->imgs+i, "\t\t\t<img class=\"imagem\" src=\"%s\" width=\"100\" height=\"100\">", imgs[i]);
                }
                imagens->numImgs += imageCount;
            }
        }

        if(!found){  
            imagens = (Imagens)malloc(sizeof(struct imagens));
            asprintf(&imagens->sujeito, "%s", sujeito);
            imagens->numImgs = imageCount;
            for (int i = 0; i < imageCount; i++){
                asprintf(imagens->imgs+i, "\t\t\t<img class=\"imagem\" src=\"%s\" width=\"100\" height=\"100\">", imgs[i]);
            }

            g_array_append_val(buff, imagens);
        }

        imageCount = 0;
    }
}

// Finalizar todos os ficheiros HTML
void finalizeFiles(){
    char *command; 
    asprintf(&command, "cd base; ls -d */ | sed 's/.$//' > output ");
    system(command);
    free(command);

    FILE* f = fopen("base/output", "r");
    char directory[128];
    char* path;
    char* name;
    Imagens imagens;

    if(!f){
        perror("Ocorreu um erro!\n");
    }else{
        while (fgets(directory, 128, f)){
            name = strtok (directory, "\n");
            asprintf(&path, "base/%s/%s.html", name, name);
            FILE* fp = fopen(path, "a");
            
            int flag = 0;
            for(int i = 0 ; i < buff->len ; i++){
                imagens = g_array_index(buff, Imagens, i);
                if(strcmp(imagens->sujeito, name) == 0){
                    if(flag == 0){
                        fprintf(fp,"\t\t<div class=\"imagens\">\n\t\t\t<div class=\"cabecalho\">\n\t\t\t\t<h2>Imagens</h2>\n\t\t\t</div>\n");
                        flag = 1;
                    }
                    for(int j = 0; j < imagens->numImgs ; j++ ){
                        fprintf(fp,"%s\n", imagens->imgs[j] );
                        free(imagens->imgs[j]);
                    }
                    free(imagens->sujeito);
                }
                flag = 0;
            }
            fprintf(fp, "\n\t</body>\n</html>");
            fclose(fp);
            free(path);
        }
        fclose(f);

        system("cd base; rm -f output");
    }
}

// Gerar o index
void generateIndexHtml(){
    system("mkdir base ; cd base ; touch index.html");
    FILE* file = fopen(indexPath,"w");
    fprintf(file, "<!DOCTYPE html>\n\t<html lang=\"pt-pt\">\n\t<head>\n\t\t<title>index</title>\n\t\t<meta charset=\"utf-8\">\n\t\t<style>\n\t\t\tdiv.cabecalho {\n\t\t\t\ttext-align: center;\n\t\t\t}\n\t\t</style></head>\n\t<body>\n\t\t<div class=\"index\">\n\t\t\t<div class=\"cabecalho\">\n\t\t\t\t<h1>Conceitos</h1>\n\t\t\t</div>\n");
    fclose(file);
}

// Adicionar um conceito ao index
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

// Finalizar o index
void finalizeIndexHtml(){
    FILE* file = fopen(indexPath,"a");
    fprintf(file, "\t\t</div>\n\t</body>\n</html>");
    fclose(file);
}


int main(int argc, char* argv[]){
    extern FILE *yyin;
    if(argc > 1){ yyin = fopen(argv[1],"r"); }else{perror("Argumentos Insuficientes!");}
    buff = g_array_new(FALSE, FALSE, sizeof(Imagens));
    generateIndexHtml();
    yyparse();
    finalizeIndexHtml();
    finalizeFiles();
    g_array_free (buff, TRUE);
	return 0;
}


void yyerror(char* s){
    extern int yylineno;
    extern char* yytext;
    fprintf(stderr,"linha %d: %s (%s)\n",yylineno,s, yytext);
}
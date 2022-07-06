%{
  #include<stdio.h>  
  #include <stdlib.h>
  #include <string.h>
  void yyerror(const char *);
  int yylex();
  FILE *iFile, *oFile;
  extern FILE *yyin;
  
  enum{
	  INTEGER_TYPE = 0,
	  FLOAT_TYPE = 1
  };
  
  struct symbol{
	  int type;
	  char name[256];
  };
  
  struct symbol symbol_table[1024];  
  int check_symbol_table(const char*); 
  int type_flag = 0;
  int idx;
  char t[10];
  int t_counter = 0;
  int symbol_table_counter = 0;
  int next_t();
  
%}
 
%union { float fl_val;
		 int in_val;
		 char st_val[256];
		}
	
%token <st_val> INTEGER
%token <st_val> FLOAT
%token <st_val> IDENTIFIER
%token <st_val> EQUAL
%token <in_val> TYPE


%left '+' '-'
  
%left '*' '/'
  
%left '(' ')'

%right UMINUS

%type <st_val> expr
  

%%
lines : lines smcls
	  | lines '\n'
	  | 
	  ;
	  
smcls : assgin ';'
	  | declare ';'
	  ;

	
assgin : IDENTIFIER EQUAL expr {
								idx = check_symbol_table($1);
								
								if (idx == -1) { 
									fprintf(oFile, "Error!\n(%s is unknown id)\n",$1);
									exit(0);
								}                         
								fprintf(oFile, "%s = %s\n", $1, $3);
								
								if(type_flag != symbol_table[idx].type){
									fprintf(oFile, "//warning: type mismatch\n");								
								}
								
								type_flag = 0;										
                             }
     ;

declare : TYPE IDENTIFIER { 
                         if (check_symbol_table($2) != -1) {
                            fprintf(oFile, "Error!\n(%s is already declared)\n", $2);
                            exit(0);
                         }
                         strcpy(symbol_table[symbol_table_counter].name, $2);
                         symbol_table[symbol_table_counter++].type = $1; }
     ;	
	

expr : FLOAT {
		type_flag |= FLOAT_TYPE;
		strcpy($$, $1);
	 }
	 
	 | INTEGER {
		type_flag |= INTEGER_TYPE;
		strcpy($$, $1);
	 }
		
	 | IDENTIFIER{
		idx = check_symbol_table($1);
		if (idx == -1) {
			fprintf(oFile, "Error!\n%s is unknown id\n", $1);
			exit(0);
		}
		type_flag |= symbol_table[idx].type;
		strcpy($$, $1);
	 }  
	
	 | expr '+' expr { sprintf(t, "t%d", next_t());
					strcpy($$, t);
                    fprintf(oFile, "%s = %s + %s\n", t, $1, $3); 
					}
  
	 | expr '-' expr { sprintf(t, "t%d", next_t());
                    strcpy($$, t);
                    fprintf(oFile, "%s = %s - %s\n", $$, $1, $3); 
					}
  
	 | expr '*' expr { sprintf(t, "t%d", next_t());
                    strcpy($$, t);
                    fprintf(oFile, "%s = %s * %s\n", $$, $1, $3); 
					}
  
	 | expr '/' expr { sprintf(t, "t%d", next_t());
                    strcpy($$, t);
                    fprintf(oFile, "%s = %s / %s\n", $$, $1, $3); 
					}
  
	 | '-' expr %prec UMINUS { sprintf(t, "t%d", next_t());
                            strcpy($$, t);
                            fprintf(oFile, "%s = -%s\n", $$, $2); 
							} 
  
  ;
  
%% 
void yyerror(const char *s)
{
   fprintf(oFile, "error\n");   
}

int next_t(){
	return t_counter++;
}

int check_symbol_table(const char *exist){
  int che = -1;
  for (int i = 0; i < symbol_table_counter; i++) {
    if (!strcmp(symbol_table[i].name, exist)) {
      che = i;
      break;
    }
  }
  return che;
}

int main(int argc, char **argv)
{
   iFile = fopen(argv[1], "r");
   oFile = fopen("output.txt", "w");
   yyin = iFile;
   printf("nn");
   
   for(int i=0;i<1024;i++)
	yyparse();  
   
   fclose(iFile);
   fclose(oFile); 
   
   return 0;
 
}
  

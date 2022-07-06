%{  
  #include "test.tab.h" 
  #include <stdio.h>
  #include <stdlib.h>   
  void yyerror(char *);  
  enum{
	  INTEGER_TYPE = 0,
	  FLOAT_TYPE = 1 
  };
  
%}

digit [0-9]
num {integer}\.{digit}+((E|e)[+\-]?{digit}+)?
integer (0|([1-9]{digit}*))
delim[ \t]+
whitespace {delim}+
letter[A-Za-z]
op [-+*/()]
equal =
smcl ;
nl \n
id {letter}({letter}|{digit})*
%%

{num} { strcpy(yylval.st_val, yytext);
		return FLOAT; }  
{integer} { strcpy(yylval.st_val, yytext);
            return INTEGER;}
(int) { yylval.in_val = INTEGER_TYPE;
        return TYPE; }
(float) { yylval.in_val = FLOAT_TYPE;
          return TYPE; }
{id} { strcpy(yylval.st_val, yytext);
       return IDENTIFIER; }
{whitespace} ;
{op} { return *yytext; }
{smcl} { return *yytext;}
{nl} { return *yytext;} 

{equal} { strcpy(yylval.st_val, yytext);
      return EQUAL; }


%%
  
int yywrap()
{
 return 1;
}
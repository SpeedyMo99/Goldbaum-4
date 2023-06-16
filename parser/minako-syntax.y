%define parse.error verbose
%define parse.trace

%code requires {
	#include <stdio.h>
	
	extern void yyerror(const char*);
	extern FILE *yyin;
}

%code {
	extern int yylex();
	extern int yylineno;
}

%union {
	char *string;
	double floatValue;
	int intValue;
}

%token AND           "&&"
%token OR            "||"
%token EQ            "=="
%token NEQ           "!="
%token LEQ           "<="
%token GEQ           ">="
%token LSS           "<"
%token GRT           ">"
%token KW_BOOLEAN    "bool"
%token KW_DO         "do"
%token KW_ELSE       "else"
%token KW_FLOAT      "float"
%token KW_FOR        "for"
%token KW_IF         "if"
%token KW_INT        "int"
%token KW_PRINTF     "printf"
%token KW_RETURN     "return"
%token KW_VOID       "void"
%token KW_WHILE      "while"
%token CONST_INT     "integer literal"
%token CONST_FLOAT   "float literal"
%token CONST_BOOLEAN "boolean literal"
%token CONST_STRING  "string literal"
%token ID            "identifier"

// definition of association and precedence of operators
%left '+' '-' OR
%left '*' '/' AND
%nonassoc UMINUS

// workaround for handling dangling else
// LOWER_THAN_ELSE stands for a not existing else
%nonassoc LOWER_THAN_ELSE
%nonassoc KW_ELSE

%%

program: declassignment ';' program {}

	|functiondefinition program {}

	| /* empty */ {}

	;



functiondefinition: type id '(' parameterlist ')' '{' statementlist '}' {}

	|type id '(' ')' '{' statementlist '}' {}

	;



parameterlist: type id parameterlist2 {}

	;



parameterlist2: ',' type id parameterlist2 {}

	| /* empty */ {}

	;



functioncall: id '(' ')' {}

	|id '(' assignment A ')' {}

	;



A: ',' assignment A {}

  	|/* empty */ {}

  	;



statementlist: block statementlist {}

	|/* empty */ {}

	;



block: '{' statementlist '}' {}

	|statement {}

	;



statement: ifstatement {}

	|forstatement {}

	|whilestatement {}

	|returnstatement ';' {}

	|dowhilestatement ';' {}

	|printf ';' {}

	|declassignment ';' {}

	|statassignment ';' {}

	|functioncall ';' {}

	;



statblock: '{' statementlist '}' {}

	|statement {}

	;



ifstatement: KW_IF '(' assignment ')' statblock {}

	|KW_IF '(' assignment ')' statblock KW_ELSE statblock {}

	;



forstatement: KW_FOR '(' statassignment ';' expr ';' statassignment ')' statblock {}

	|KW_FOR '(' declassignment ';' expr ';' statassignment ')' statblock {}

	;



dowhilestatement: KW_DO statblock KW_WHILE '(' assignment ')' {}

	;



whilestatement: KW_WHILE '(' assignment ')' statblock {}

	;



returnstatement: KW_RETURN {}

	|KW_RETURN assignment {}

	;



printf: KW_PRINTF '(' assignment ')' {}

	|KW_PRINTF '(' CONST_STRING ')' {}

	;



declassignment: type id {}

	|type id '=' assignment {}

	;



statassignment: id '=' assignment {}

	;



assignment: statassignment {}

	|expr {}

	;



expr: simpexpr B {}

	;



B: "==" simpexpr {}

	|"!=" simpexpr {}

	|"<=" simpexpr {}

	|">=" simpexpr {}

	|"<" simpexpr {}

	|">" simpexpr {}

	|/* empty */

	;



simpexpr: '-' term C {}

	|term C {}

	;



C: '+' term C {}

	|'-' term C {}

	| "||" term C {}

	|/* empty */ {}

	;



term: factor D {}

	;



D: '*' factor D {}

	|'/' factor D {}

	| "&&" factor D {}

	|/* empty */ {}

	;



factor: CONST_INT {}

	|CONST_FLOAT {}

	|CONST_BOOLEAN {}

	|functioncall {}

	|id {}

	|'(' assignment ')' {}

	;



type: KW_BOOLEAN {}

	|KW_FLOAT {}

	|KW_INT {}

	|KW_VOID {}

	;



id: ID {}

	;

%%

int main(int argc, char *argv[]) {
	yydebug = 1;

	if (argc < 2) {
		yyin = stdin;
	} else {
		yyin = fopen(argv[1], "r");
		if (yyin == 0) {
			printf("ERROR: Datei %s nicht gefunden", argv[1]);
		}
	}

	return yyparse();
}

void yyerror(const char *msg) {
	fprintf(stderr, "Line %d: %s\n", yylineno, msg);
}

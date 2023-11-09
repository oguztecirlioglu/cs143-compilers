/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

int char_count = 0;
int commentDepth = 0;

char str_buf[MAX_STR_CONST]; /* to assemble string constants */
char *str_buf_ptr;

bool max_strlen_check();
bool max_strlen_check(int);
int max_strlen_err();
void clean_str();

%}

/*
 * Define names for regular expressions here.
 */

%x NESTED_COMMENT STRING STRING_ERR INLINE_COMMENT

INLINE_COMMENT        --
NESTED_COMMENT_OPEN   \(\*
NESTED_COMMENT_CLOSE  \*\)

DIGIT                 [0-9]
CLASS                 (?i:class)
ELSE                  (?i:else)
FI                    (?i:fi)
IF                    (?i:if)
IN                    (?i:in)
INHERITS              (?i:inherits)
ISVOID                (?i:isvoid)
LET                   (?i:let)
LOOP                  (?i:loop)
POOL                  (?i:pool)
THEN                  (?i:then)
WHILE                 (?i:while)
CASE                  (?i:case)
ESAC                  (?i:esac)
NEW                   (?i:new)
OF                    (?i:of)
NOT                   (?i:not)
TRUE                  t(?i:rue)
FALSE                 f(?i:alse)

TYPE_ID               [A-Z][a-zA-Z0-9_]*
OBJECT_ID             [a-z][a-zA-Z0-9_]*

ASSIGNMENT            "<-"
DARROW                "=>"
LE                    "<="


WHITESPACE            [ \f\r\t\v]


%%

 /*
  Notes to self:
  Variables of the basic classes Int, Bool, and String are initialized specially; see Section 8.
  Void is used for variables where no initialisation occurs and isnt a simple type (mentioned above). 

  The lexical units of Cool are integers, type identifiers, object identifiers, special notation, strings, keywords, and white space
  Need to add edge cases for terminating in middle of string etc, AND make "\n" into one char.
  */


{INLINE_COMMENT}                        { BEGIN(INLINE_COMMENT); }
<INLINE_COMMENT>.+                      { }
<INLINE_COMMENT>\n                       { BEGIN(0); curr_lineno++; }

{NESTED_COMMENT_OPEN}                   { commentDepth++; BEGIN NESTED_COMMENT; }
<NESTED_COMMENT>{NESTED_COMMENT_OPEN}   { commentDepth++; }
<NESTED_COMMENT><<EOF>>                 { BEGIN(INITIAL); cool_yylval.error_msg = "EOF in comment"; return ERROR; }
<NESTED_COMMENT>\n                      { curr_lineno++; }
<NESTED_COMMENT>{NESTED_COMMENT_CLOSE}  { commentDepth--; if(commentDepth == 0) BEGIN 0; }
<NESTED_COMMENT>.                       { }
{NESTED_COMMENT_CLOSE}                  { cool_yylval.error_msg = "Unmatched *)"; return ERROR; }

\" {
    BEGIN(STRING);
    clean_str();
    str_buf_ptr = str_buf;
}
<STRING>\" {
    BEGIN(INITIAL);
    if (max_strlen_check()) return max_strlen_err();
    str_buf_ptr = 0;
    cool_yylval.symbol = stringtable.add_string(str_buf);
    return STR_CONST;
}
<STRING><<EOF>> {
    BEGIN(0);
    cool_yylval.error_msg = "EOF in string constant";
    return ERROR;
}
<STRING>\n {
    BEGIN(0);
    curr_lineno++;
    cool_yylval.error_msg = "Unterminated string constant";
    return ERROR;
}
<STRING>\\[^ntbf\0] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = yytext[1];
}
<STRING>\\[\0] {
    BEGIN(STRING_ERR);
    curr_lineno++;
    cool_yylval.error_msg = "String contains null character";
    return ERROR;
}
<STRING>\0 {
    BEGIN(STRING_ERR);
    curr_lineno++;
    cool_yylval.error_msg = "String contains null character";
    return ERROR;
}
<STRING>\\[n] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = '\n';
}
<STRING>\\[t] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = '\t';
}
<STRING>\\[b] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = '\b';
}
<STRING>\\[f] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = '\f';
}
<STRING>. {
    if (max_strlen_check()) return max_strlen_err();
    *str_buf_ptr++ = *yytext;
}

<STRING_ERR>\"  {
                    BEGIN(INITIAL);
	            }
<STRING_ERR>\\\n {
	                curr_lineno++;
                    BEGIN(INITIAL);
                }
<STRING_ERR>\n  {
	                curr_lineno++;
                    BEGIN(INITIAL);
	            }
<STRING_ERR>.   {}

{CLASS}                                 { return (CLASS); }
{ELSE}                                  { return (ELSE); }
{FI}                                    { return (FI); }
{IF}                                    { return (IF); }
{IN}                                    { return (IN); }
{INHERITS}                              { return (INHERITS); }
{ISVOID}                                { return (ISVOID); }
{LET}                                   { return (LET); }
{LOOP}                                  { return (LOOP); }
{POOL}                                  { return (POOL); }
{THEN}                                  { return (THEN); }
{WHILE}                                 { return (WHILE); }
{CASE}                                  { return (CASE); }
{ESAC}                                  { return (ESAC); }
{NEW}                                   { return (NEW); }
{OF}                                    { return (OF); }
{NOT}                                   { return (NOT); }

{TRUE}                                  { cool_yylval.boolean = true; return (BOOL_CONST); }
{FALSE}                                 { cool_yylval.boolean = false; return (BOOL_CONST); }

{DIGIT}+                                { cool_yylval.symbol = inttable.add_string(yytext); return (INT_CONST); }

{DARROW}		                            { return (DARROW); }
{LE}                                    { return (LE); }
{ASSIGNMENT}                            { return (ASSIGN); }

"{"                                     { return (int('{')); }
"}"                                     { return (int('}')); }
"("                                     { return (int('(')); }
")"                                     { return (int(')')); }
";"                                     { return (int(';')); }
":"                                     { return (int(':')); }
","                                     { return (int(',')); }
"="                                     { return (int('=')); }
"<"                                     { return (int('<')); }
"."                                     { return (int('.')); }
"@"                                     { return (int('@')); }
"+"                                     { return (int('+')); }
"-"                                     { return (int('-')); }
"*"                                     { return (int('*')); }
"/"                                     { return (int('/')); }
"~"                                     { return (int('~')); }

{TYPE_ID}                               { cool_yylval.symbol = idtable.add_string(yytext); return (TYPEID); }
{OBJECT_ID}                             { cool_yylval.symbol = idtable.add_string(yytext); return (OBJECTID); }


 /*
 * {ERROR}
 * {LET_STMT}
 */

\n                                      { curr_lineno++; }
{WHITESPACE}+                           { }
.                                       { cool_yylval.error_msg = strdup(yytext); return (ERROR); }


 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%

bool max_strlen_check() { 
    return (str_buf_ptr - str_buf) + 1 > MAX_STR_CONST; 
}

bool max_strlen_check(int size) {
    return (str_buf_ptr - str_buf) + size > MAX_STR_CONST;
}

void clean_str() {
  memset(str_buf, 0, MAX_STR_CONST * sizeof(char));
}

int max_strlen_err() { 
    BEGIN(INITIAL);
    cool_yylval.error_msg = "String constant too long";
    return ERROR;
}
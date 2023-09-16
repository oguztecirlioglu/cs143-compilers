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

%}

/*
 * Define names for regular expressions here.
 */

%Start NESTED_COMMENT INLINE_COMMENT

INLINE_COMMENT        --
NESTED_COMMENT_OPEN   \(\*
NESTED_COMMENT_CLOSE  \*\)

DARROW                =>
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

WHITESPACE            [ \f\r\t\v]


%%

 /*
  *  Notes to self:
  *  Class names begin with uppercase chars.
  *  Type declaration is of form x:C, where x is a variable and C is a type.
  *  An attribute has the form: <id> : <type> [ <- <expr> ]
  *  Variables of the basic classes Int, Bool, and String are initialized specially; see Section 8.
  *  Void is used for variables where no initialisation occurs and isnt a simple type (mentioned above). 
  *
  *  The lexical units of Cool are integers, type identifiers, object identifiers, special notation, strings, keywords, and white space
  */

 /*
  *  The multiple-character operators.
  */

{INLINE_COMMENT}                        { cout << "open inline comment" << endl; BEGIN INLINE_COMMENT; }
<INLINE_COMMENT>\n                      { cout << "close inline comment" << endl; BEGIN 0;}
<INLINE_COMMENT>.+                      { }

{NESTED_COMMENT_OPEN}                   { cout << "open nested comment" << endl; commentDepth++; BEGIN NESTED_COMMENT; }
<NESTED_COMMENT>([^*]|(\*+[^)*]))+      { }
<NESTED_COMMENT>{NESTED_COMMENT_CLOSE}  { cout << "close nested comment" << endl; commentDepth--; if(commentDepth == 0) BEGIN 0; }


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

{TRUE}                                  { cout << "matched true" << endl; }
{FALSE}                                 { cout << "matched false" << endl; }

{DIGIT}+                                { cool_yylval.symbol = inttable.add_string(yytext); return (INT_CONST); }
{DARROW}		                            { return (DARROW); }

{WHITESPACE}+                           { }
\n                                      { curr_lineno++; }
.                                       { char_count++; }


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

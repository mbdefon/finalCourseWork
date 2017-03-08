import java_cup.runtime.*;

%%
%class Lexer
%unicode
%cup
%line
%column

%{

  StringBuffer string = new StringBuffer();

  private boolean debug_mode;
  public  boolean debug()            { return debug_mode; }
  public  void    debug(boolean mode){ debug_mode = mode; }

  private void print_lexeme(int type, Object value){
    if(!debug()){ return; }

    System.out.print("<");
    switch(type){
      case sym.LET:
        System.out.print("LET"); break;
      case sym.EQUAL:
        System.out.print(":="); break;
      case sym.SEMICOL:
        System.out.print(";"); break;
      case sym.PLUS:
        System.out.print("+"); break;
      case sym.MINUS:
        System.out.print("-"); break;
      case sym.MULT:
        System.out.print("*"); break;
      case sym.DIV:
        System.out.print("/"); break;
      case sym.MAIN:
        System.out.print("main"); break;
      case sym.LPAREN:
        System.out.print("("); break;
      case sym.RPAREN:
        System.out.print(")"); break;
      case sym.L_CBRACK:
        System.out.print("{"); break;
      case sym.R_CBRACK:
        System.out.print("}"); break;
      case sym.INTEGER:
        System.out.printf("INT %d", value); break;
      case sym.IDENTIFIER:
        System.out.printf("IDENT %s", value); break;
      case sym.PRINT:
        System.out.printf("print"); break;
      //case sym.STRING_LITERAL:
      //            System.out.printf("STRING_LITERAL %s", value); break;
      case sym.CHAR:
                  System.out.printf("CHAR %c", value); break;      // EDIT CHAR !!

      case sym.BOOL_TYPE:
              System.out.printf("bool");            break;
      case sym.CHAR_TYPE:
                    System.out.printf("char type"); break;
      case sym.INT_TYPE:
                    System.out.printf("int type");  break;

    }
    System.out.print(">  ");
  }

  private Symbol symbol(int type) {
    print_lexeme(type, null);
    return new Symbol(type, yyline, yycolumn);
  }
  private Symbol symbol(int type, Object value) {
    print_lexeme(type, value);
    return new Symbol(type, yyline, yycolumn, value);
  }

%}





LineTerminator = \r|\n|\r\n
Whitespace = {LineTerminator}|" "|"\t"
InputCharacter = [^LineTerminator]

Letter = [a-zA-Z]
Digit = [0-9]
IdChar = {Letter} | {Digit} | "_"
Identifier = {Letter}{IdChar}*
Integer = (0|[1-9]{Digit}*)

 /* Character */
character = [:jletterdigit:] | \p{Punctuation} | " "
char = "'" {character} "'"

 /*String*/

string = "\"" {character}* "\""

  /* Comments */
Comment = {HashComment}|{EndOfLineComment}
HashComment = "/#" [^#]* ~"#/" | "/#" "#" + "/"
EndOfLineComment = "#" {InputCharacter}* {LineTerminator}?

%state CHAR





%%
<YYINITIAL> {

 /* DEFINE KEYWORDS */

  "main"        { return symbol(sym.MAIN);             }
  "let"         { return symbol(sym.LET);              }
  "print"       { return symbol(sym.PRINT);            }
  "dict"        { return symbol(sym.DICTIONARY);       }
  "top"         { return symbol(sym.TOP);              }
  "seq"         { return symbol(sym.SEQUENCE);         }
  "len"         { return symbol(sym.LEN);        }
  "index"



  /* DEFINE TYPES */

  "bool"        { return symbol(sym.BOOL_TYPE);        }
  "char"        { return symbol(sym.CHAR_TYPE);        }
  "int"         { return symbol(sym.INT_TYPE);         }
  "rat"         { return symbol(sym.RAT_TYPE);         }
  "float"       { return symbol(sym.FLOAT_TYPE);       }
  "T"           { return symbol(sym.TRUE);             }
  "F"           { return symbol(sym.FALSE);            }



  {Integer}     { return symbol(sym.INTEGER, Integer.parseInt(yytext()));}
  {Identifier}  { return symbol(sym.IDENTIFIER, yytext());   }

  /* length */

  {Whitespace}  { /* do nothing */               }
  ":="          { return symbol(sym.EQUAL);      }
  ";"           { return symbol(sym.SEMICOL);    }
  "+"           { return symbol(sym.PLUS);       }
  "-"           { return symbol(sym.MINUS);      }
  "*"           { return symbol(sym.MULT);       }
  "/"           { return symbol(sym.DIV);        }
  "("           { return symbol(sym.LPAREN);     }
  ")"           { return symbol(sym.RPAREN);     }
  "{"           { return symbol(sym.L_CBRACK);   }
  "}"           { return symbol(sym.R_CBRACK);   }
  "."           { return symbol(sym.PERIOD_SYM); }
  "_"           { return symbol(sym.UNDERSCORE); }
  ","           { return symbol(sym.COMMA);      }
  "<"           { return symbol(sym.INF);        }
  ">"           { return symbol(sym.SUP);        }
  ":"           { return symbol(sym.DEUX_POINTS);}
  "["           { return symbol(sym.LSQ_BRACK);  }
  "]"           { return symbol(sym.RSQ_BRACK);  }

  {char}        { return symbol(sym.CHAR);       }
  {string}      { return symbol(sym.STRING);     }

}


//<CHAR> {
//  \'                             { yybegin(YYINITIAL);
//                                   return symbol(sym.CHAR,
//                                   string.toString()); }
//  {character}                    { string.append( yytext() ); }
//  [^]                            { throw new Error("Character must be closed with a '. Cant be void:" + yytext()); }
//}


[^]  {
  System.out.println("file:" + (yyline+1) +
    ":0: Error: Invalid input '" + yytext()+"'");
  return symbol(sym.BADCHAR);
}


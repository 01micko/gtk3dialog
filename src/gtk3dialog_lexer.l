%{
/*
 * gtk3dialog_lexer.l:
 * Gtk3dialog - A small utility for fast and easy GUI building.
 * Copyright (C) 2003-2007  László Pere <pipas@linux.pte.hu>
 * Copyright (C) 2011-2012  Thunor <thunorsif@hotmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

/*
**
** $Id: lexer.l,v 1.2 2004/11/20 20:01:25 root Exp root $
** $Log: lexer.l,v $
** Revision 1.2  2004/11/20 20:01:25  root
** - Log entries.
**
*/

#define YY_INPUT(buf,result,max_size) \
    { \
    int c = getnextchar(); \
    result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
    }


#include <string.h>
#include <gtk/gtk.h>

#include "gtk3dialog.h"
#include "attributes.h"
#include "gtk3dialog_parser.h"

int getnextchar(void);
int gtk3dialog_error(char *);

extern int linenumber;
gchar *Token;
/* step: line number of last <action> or <input> tag */
static int less_than_allowed_at = 0;

%}

	/**************************************************************
	 * Thunor: Uncomment and unindent this to debug.
	 **************************************************************
	* %option debug */

%x EMBEDDED
%x ST_TAG_ATTR ST_QUOTED_TAGATTR
%x ST_STRING ST_QUOTED_STRING
%x COMMENT

%%

	#ifdef DEBUG
		g_message("%s(): Start", __func__);
	#endif

	/* step: XML-style comments  <!-- .... --> work anywhere but:
	 * inside double-quoted strings they become verbatim text;
	 * inside a tag they are invalid;
	 * comments cannot be nested.
	 */
"<!--"           { BEGIN(COMMENT); }
<COMMENT>"-->"   { BEGIN(0); }
<COMMENT>\n      { ++linenumber; }
<COMMENT>[^\n-]+ { ; }
<COMMENT>.       { ; }


">"       				{ Token=">"; return(yytext[0]); 			}
<*>$[ \t\n]* 				{ Token="indent chars"; 				}

	/*
	 * Attributes.
	 */
<ST_TAG_ATTR>[-a-zA-Z0-9_]+ {
	#ifdef DEBUG 
	g_message(" -> TAG_ATTR_NAME: '%s'", yytext);
	#endif
	Token="tag attribute name";
	gtk3dialog_lval.cval=strdup(yytext);
	return TAG_ATTR_NAME;
}


<ST_TAG_ATTR>= 				{
					  #ifdef DEBUG 
					  g_message(" -> spec char: '%s'", yytext);
					  #endif
					  Token="=";
					  return '=';
												}
<ST_TAG_ATTR>\> 			{
					  #ifdef DEBUG 
					  g_message(" -> spec char: '%s'", yytext);
					  #endif
					  Token=">";
					  BEGIN(0);
					  return '>';
												}

<ST_TAG_ATTR>\" 			{
					  Token = "double quote";
					  BEGIN(ST_QUOTED_TAGATTR);				}
					  
<ST_QUOTED_TAGATTR>\n			{
					  Token = "string";
					  ++linenumber;
					  yymore();						}

<ST_QUOTED_TAGATTR>[^\n\\"]+		{
					  Token = "string";
					  yymore();						}

<ST_QUOTED_TAGATTR>("\\\"")		{
					  Token = "string";
					  yymore();						}
					  
<ST_QUOTED_TAGATTR>\"			{
					  Token = yytext;
					  gtk3dialog_lval.cval = g_strdup(yytext);
					  gtk3dialog_lval.cval[strlen(gtk3dialog_lval.cval) - 1] = '\0';
					  BEGIN(ST_TAG_ATTR);
					  return STRING;
					  							}






	/*
	 * The elements of the embedded imperative language.
	 */
\<show\/\> { 
	Token="<show/>"; 
	return SHOW_WIDGETS;
}

\<command[ ]+assignment[ ]*=[ ]*\"  {
	Token="<command>";    
	BEGIN(EMBEDDED);
	return COMM;
}

\<if[ ]+condition[ ]*=[ ]*\"  {
	Token="<if>";    
	BEGIN(EMBEDDED);
	return IF;           
}

\<while[ ]+condition[ ]*=[ ]*\"  {
	Token="<while>";    
	BEGIN(EMBEDDED);
	return WHILE;
}

<EMBEDDED>[-+*/<>=:] {
	Token = "operator";
	return yytext[0];
}

<EMBEDDED>[a-zA-Z-]+ {
	Token = "variable";
	gtk3dialog_lval.cval = g_strdup(yytext);
	return EMB_VARIABLE;
}

<EMBEDDED>[0-9,.]+ {
	Token = "number";
	gtk3dialog_lval.cval = g_strdup(yytext);
	return EMB_NUMBER;
}

<EMBEDDED>\" { 
	BEGIN(0);
}

"</command>" { 
	Token="</if>"; 
	return ENDCOMM;
}

"</if>" { 
	Token="</if>"; 
	return ENDIF;
}

"</while>" { 
	Token="</while>"; 
	return EWHILE;
}


	/*
	 * The widget tags.
	 */
\<window\> { 
	Token="<window>"; 
	return(WINDOW);
}

\<window[ ]+ { 
	Token="<window>"; 
	BEGIN(ST_TAG_ATTR);
	return(PART_WINDOW);  		
}

\<\/window\> { 
	Token="</window>"; 
	return(EWINDOW);
}


\<notebook\> { 
	Token="<notebook>"; 
	return(NOTEBOOK);
}

\<notebook[ ]+ { 
	Token="<notebook>";
	BEGIN(ST_TAG_ATTR);
	return(PART_NOTEBOOK);
}

\<\/notebook\> { 
	Token="</notebook>"; 
	return(ENOTEBOOK);
}


\<vbox\> { 
	Token="<vbox>"; 
	return(VBOX);
}

\<vbox[ ]+ { 
	Token="<vbox>"; 
	BEGIN(ST_TAG_ATTR);
	return(PART_VBOX);
}

\<\/vbox\> { 
	Token="</vbox>"; 
	return(EVBOX);
}


\<hbox\> { 
	Token="<hbox>"; 
	return(HBOX);
}

\<hbox[ ]+ { 
	Token="<hbox>";
	BEGIN(ST_TAG_ATTR);
	return(PART_HBOX);
}

\<\/hbox\> { 
	Token="</hbox>"; 
	return(EHBOX);
}


\<frame\> { 
	Token="<frame>"; 
	gtk3dialog_lval.cval = "";  
	return(FRAME); 	
}

\<frame\ [^\>]+\> {
	Token="<frame>";
	gtk3dialog_lval.cval=strdup(&yytext[7]);  
	gtk3dialog_lval.cval[strlen(gtk3dialog_lval.cval)-1] = 0;
	return FRAME; 
}

\<\/frame\> { 
	Token="</frame>"; 
	return(EFRAME);
}


\<text\> { 
	Token="<text>"; 
	return(TEXT);
}

\<text[ ]+ { 
	Token="<text>"; 
	BEGIN(ST_TAG_ATTR);
	return(PART_TEXT);
}

\<\/text\> { 
	Token="</text>"; 
	return(ETEXT);
}


\<pixmap\> { 
	Token="<pixmap>"; 
	return(PIXMAP);
}

\<\/pixmap\> { 
	Token="</pixmap>"; 
	return(EPIXMAP); 
}

\<pixmap[ ]+ { 
	Token="<pixmap>"; 
	BEGIN(ST_TAG_ATTR);
	return(PART_PIXMAP);
}


\<entry\> { 
	Token="<entry>"; 
	return(ENTRY);
}

\<\/entry\> { 
	Token="</entry>"; 
	return(EENTRY);
}

\<entry[ ]+ { 
	Token="<entry>"; 
	BEGIN(ST_TAG_ATTR);
	return(PART_ENTRY);
}


\<edit\> { 
	Token="<edit>"; 
	return(EDIT);
}

\<edit[ ]+ { 
	Token="<edit>"; 
	BEGIN(ST_TAG_ATTR);
	return(PART_EDIT);
}

\<\/edit\> { 
	Token="</edit>"; 
	return(EEDIT);
}


\<tree\> { 
	Token="<tree>";  
	return  TREE;
}

\<tree[ ]+ { 
	Token="<tree>";  
	BEGIN(ST_TAG_ATTR);
	return PART_TREE;
}

\<\/tree\> {
	Token="</tree>"; 
	return ETREE;
}


\<chooser\> { 
	Token="<chooser>"; 
	return(CHOOSER);
}

\<\/chooser\> { 
	Token="</chooser>"; 
	return(ECHOOSER);
}

\<chooser[ ]+ { 
	Token="<chooser>";  
	BEGIN(ST_TAG_ATTR);
	return PART_CHOOSER;
}


\<button\> { 
	Token="<button>"; 
	return(BUTTON);
}

\<\/button\> { 
	Token="</button>"; 
	return(EBUTTON);
}

\<button[ ]+/([-a-zA-Z_]*=) { 
	//g_message("PART_BUTTON: '%s'", yytext);
	Token="<button>";  
	BEGIN(ST_TAG_ATTR);
	return PART_BUTTON;
}

\<button\ ok\>      			{ Token="<button>"; return(BUTTONOK);  			}
\<button\ cancel\>  			{ Token="<button>"; return(BUTTONCANCEL);  		}
\<button\ help\>    			{ Token="<button>"; return(BUTTONHELP);  		}
\<button\ yes\>     			{ Token="<button>"; return(BUTTONYES);  		}
\<button\ no\>      			{ Token="<button>"; return(BUTTONNO);  			}

\<checkbox\>				{ Token="<checkbox>"; return(CHECKBOX);       		}
\<\/checkbox\>  			{ Token="</checkbox>"; return(ECHECKBOX);     		}
\<checkbox[ ]+  			{ Token="<checkbox>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_CHECKBOX);  				}

\<radiobutton\>    			{ Token="<radiobutton>"; return(RADIO);      		}
\<\/radiobutton\>  			{ Token="</radiobutton>"; return(ERADIO);    		}
\<radiobutton[ ]+  			{ Token="<radiobutton>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_RADIO);  					}

\<progressbar\>    			{ Token="<progressbar>"; return(PROGRESSBAR);      	}
\<\/progressbar\>  			{ Token="</progressbar>"; return(EPROGRESSBAR);    	}
\<progressbar[ ]+  			{ Token="<progressbar>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_PROGRESSBAR);  				}


\<radio\>    				{ Token="<radio>"; return(RADIO);  			}
\<\/radio\>  				{ Token="</radio>"; return(ERADIO);  			}

\<menubar\>    				{ Token="<menubar>"; return(MENUBAR); }
\<menubar[ ]+    			{ Token="<menubar>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_MENUBAR); }
\<\/menubar\>  				{ Token="</menubar>"; return(EMENUBAR); }

\<menu\>    				{ Token="<menu>"; return(MENU); }
\<menu[ ]+    				{ Token="<menu>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_MENU); }
\<\/menu\>  				{ Token="</menu>"; return(EMENU); }

\<menuitem\>    			{ Token="<menuitem>"; return(MENUITEM); }
\<menuitem[ ]+  			{ Token="<menuitem>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_MENUITEM); }
\<\/menuitem\>  			{ Token="</menuitem>"; return(EMENUITEM); }

\<menuitemseparator\>    	{ Token="<menuitemseparator>"; return(MENUITEMSEPARATOR); }
\<\/menuitemseparator\>		{ Token="</menuitemseparator>"; return(EMENUITEMSEPARATOR); }

\<separator\>    			{ Token="<menuitemseparator>"; return(MENUITEMSEPARATOR); }
\<\/separator\>				{ Token="</menuitemseparator>"; return(EMENUITEMSEPARATOR); }

	/**************************************************************
	 * Thunor: Newly supported widgets.
	 **************************************************************/
\<hseparator\>    			{ Token="<hseparator>"; return(HSEPARATOR); }
\<hseparator[ ]+  			{ Token="<hseparator>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_HSEPARATOR); }
\<\/hseparator\>			{ Token="</hseparator>"; return(EHSEPARATOR); }

\<vseparator\>    			{ Token="<vseparator>"; return(VSEPARATOR); }
\<vseparator[ ]+  			{ Token="<vseparator>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_VSEPARATOR); }
\<\/vseparator\>			{ Token="</vseparator>"; return(EVSEPARATOR); }

\<comboboxtext\>   			{ Token="<comboboxtext>"; return(COMBOBOXTEXT); }
\<comboboxtext[ ]+  		{ Token="<comboboxtext>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_COMBOBOXTEXT); }
\<\/comboboxtext\>  		{ Token="</comboboxtext>"; return(ECOMBOBOXTEXT); }

\<comboboxentry\>   		{ Token="<comboboxentry>"; return(COMBOBOXENTRY); }
\<comboboxentry[ ]+  		{ Token="<comboboxentry>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_COMBOBOXENTRY); }
\<\/comboboxentry\>  		{ Token="</comboboxentry>"; return(ECOMBOBOXENTRY); }

\<hscale\>					{ Token="<hscale>"; return(HSCALE); }
\<hscale[ ]+				{ Token="<hscale>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_HSCALE); }
\<\/hscale\>				{ Token="</hscale>"; return(EHSCALE); }

\<vscale\>					{ Token="<vscale>"; return(VSCALE); }
\<vscale[ ]+				{ Token="<vscale>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_VSCALE); }
\<\/vscale\>				{ Token="</vscale>"; return(EVSCALE); }

\<spinbutton\>				{ Token="<spinbutton>"; return(SPINBUTTON); }
\<spinbutton[ ]+			{ Token="<spinbutton>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_SPINBUTTON); }
\<\/spinbutton\>			{ Token="</spinbutton>"; return(ESPINBUTTON); }

\<timer\>					{ Token="<timer>"; return(TIMER); }
\<timer[ ]+					{ Token="<timer>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_TIMER); }
\<\/timer\>					{ Token="</timer>"; return(ETIMER); }

\<togglebutton\>			{ Token="<togglebutton>"; return(TOGGLEBUTTON); }
\<togglebutton[ ]+			{ Token="<togglebutton>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_TOGGLEBUTTON); }
\<\/togglebutton\>			{ Token="</togglebutton>"; return(ETOGGLEBUTTON); }

\<statusbar\>				{ Token="<statusbar>"; return(STATUSBAR); }
\<statusbar[ ]+				{ Token="<statusbar>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_STATUSBAR); }
\<\/statusbar\>				{ Token="</statusbar>"; return(ESTATUSBAR); }

\<colorbutton\>				{ Token="<colorbutton>"; return(COLORBUTTON); }
\<colorbutton[ ]+			{ Token="<colorbutton>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_COLORBUTTON); }
\<\/colorbutton\>			{ Token="</colorbutton>"; return(ECOLORBUTTON); }

\<fontbutton\>				{ Token="<fontbutton>"; return(FONTBUTTON); }
\<fontbutton[ ]+			{ Token="<fontbutton>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_FONTBUTTON); }
\<\/fontbutton\>			{ Token="</fontbutton>"; return(EFONTBUTTON); }

\<terminal\>				{ Token="<terminal>"; return(TERMINAL); }
\<terminal[ ]+				{ Token="<terminal>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_TERMINAL); }
\<\/terminal\>				{ Token="</terminal>"; return(ETERMINAL); }

\<eventbox\>				{ Token="<eventbox>"; return(EVENTBOX); }
\<eventbox[ ]+				{ Token="<eventbox>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_EVENTBOX); }
\<\/eventbox\>				{ Token="</eventbox>"; return(EEVENTBOX); }

\<expander\>				{ Token="<expander>"; return(EXPANDER); }
\<expander[ ]+				{ Token="<expander>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_EXPANDER); }
\<\/expander\>				{ Token="</expander>"; return(EEXPANDER); }



\<label\>    				{ Token="<label>"; return(LABEL);    			}
\<\/label\>  				{ Token="</label>"; return(ELABEL);  			}

\<item\>     				{ Token="<item>"; return(ITEM);      			}
\<\/item\>   				{ Token="</item>"; return(EITEM);    			}
\<item[ ]+   				{ Token="<item>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_ITEM); 					}

\<default\>      			{ Token="<default>"; return(DEFAULT);  			}
\<\/default\>    			{ Token="</default>"; return(EDEFAULT);  		}

\<visible\>      			{ Token="<sensitive>"; return(SENSITIVE);  		}
\<\/visible\>    			{ Token="</sensitive>"; return(ESENSITIVE);  	}

\<sensitive\>      			{ Token="<sensitive>"; return(SENSITIVE);  		}
\<\/sensitive\>    			{ Token="</sensitive>"; return(ESENSITIVE);  	}

\<height\>       			{ Token="<height>"; return(HEIGHT);  			}
\<\/height\>     			{ Token="</height>"; return(EHEIGHT);  			}

\<width\>        			{ Token="<width>"; return(WIDTH);   			}
\<\/width\>      			{ Token="</width>"; return(EWIDTH);   			}

\<input\>        			{ Token="<input>";
					  less_than_allowed_at = linenumber;
					  return(INPUT);   					}
\<\/input\>      			{ Token="</input>"; return(EINPUT);   			}
\<\input\ file\> 			{ Token="<input file>"; return(INPUTFILE);   		}
\<\input\ file[ ]+ 			{ Token="<input file>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_INPUTFILE);   				}
\<\input\ [ ]*   			{ Token="<input>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_INPUT);   				}

\<output\>        			{ Token="<output>"; return(OUTPUT);   			}
\<\/output\>      			{ Token="</output>"; return(EOUTPUT);   		}
\<\output\ file\> 			{ Token="<output>"; return(OUTPUTFILE);   		}

\<variable\>     			{ Token="<variable>"; return(VARIABLE);  		}
\<variable[ ]+   			{ Token="<variable>"; 
					  BEGIN(ST_TAG_ATTR);
					  return(PART_VARIABLE); 				}
\<\/variable\>   			{ Token="</variable>"; return(EVARIABLE);  		}

	/*
	** The definition of action tags.
	*/

\<action\>     				{ Token="<action>";
					  less_than_allowed_at = linenumber;
					  return(ACTION);					}
\<action[ ]+   				{ Token="<action>";
					  BEGIN(ST_TAG_ATTR);
					  return(PART_ACTION); 					}
\<\/action\>     			{ Token="</action>"; return(EACTION);  			}






\<\/[^> ]*\> { 
	Token=g_strdup(yytext); 
	gtk3dialog_error("Unknown end tag.");  
}

	/* Matching "<!" would prevent input <!--\n from starting a <COMMENT> */
\<[^!> ]*\> {
	Token=g_strdup(yytext); 
	gtk3dialog_error("Unknown tag.");      
}
					
					/*
					 * The quoted string. It can contain anything, except
					 * unescaped double quote. Multiple line OK.
					 */
\"	  				{
					  Token = "double quote";
					  BEGIN(ST_QUOTED_STRING);				}
					  
<ST_QUOTED_STRING>\n			{ ++linenumber;
					  yymore();						}

<ST_QUOTED_STRING>[^\n\\"]+		{
					  yymore();						}

<ST_QUOTED_STRING>"\\\""		{
					  yymore();						}
					  
<ST_QUOTED_STRING>\"			{
					  Token = yytext;
					  gtk3dialog_lval.cval = g_strdup(yytext);
					  gtk3dialog_lval.cval[strlen(gtk3dialog_lval.cval) - 1] = '\0';
					  BEGIN(0);
					  return STRING;
					  							}
												
					/*
					 * An unquoted string can contain anything except 
					 * unescaped '<'. Single line only.
					 */
[^ \n\t\>\<\"][^\n\<\\]*  		{
					  Token = "string";
					  BEGIN(ST_STRING);
					  yymore();
												}
<ST_STRING>[^\n\<\\]+  			{
					  Token = "string";
					  yymore();
												}


<ST_STRING>"\\<"			{
					  yymore();
												}

<ST_STRING>\\.				{
					  yymore();
												}

					/* step: special handling for shell '<' operator */
<ST_STRING>"</"				{
					  gtk3dialog_lval.cval = g_strdup(yytext);
					  gtk3dialog_lval.cval[strlen(gtk3dialog_lval.cval) - 2] = '\0';
					  unput('/'); unput('<');
					  BEGIN(0);
					  return STRING;
					  							}

					/* step: special handling continued */
<ST_STRING>"<"				{
					  if (less_than_allowed_at == linenumber) {
						yymore();
					  } else {
						gtk3dialog_lval.cval = g_strdup(yytext);
						gtk3dialog_lval.cval[strlen(gtk3dialog_lval.cval) - 1] = '\0';
						unput('<');
						BEGIN(0);
						return STRING;
					}
					  							}

												

<*>\n 					{
					  ++linenumber;
												}
<*>[\t ] 					{
					  /* */
												}

<*>.                                       {
					  /* we do nothing, this is a dropped char. */
												}
%%


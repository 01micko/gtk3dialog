/*
 * widget_colorbutton.c: 
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

/* Includes */
#define _GNU_SOURCE
#include <gtk/gtk.h>
#include "config.h"
#include "gtk3dialog.h"
#include "attributes.h"
#include "automaton.h"
#include "widgets.h"
#include "signals.h"

/* Defines */
//#define DEBUG_CONTENT
//#define DEBUG_TRANSITS

/* Local function prototypes, located at file bottom */
static void widget_colorbutton_input_by_command(variable *var, char *command);
static void widget_colorbutton_input_by_file(variable *var, char *filename);
static void widget_colorbutton_input_by_items(variable *var);
static int hex_to_dec(char c);

/* Notes: */

/***********************************************************************
 * Clear                                                               *
 ***********************************************************************/

void widget_colorbutton_clear(variable *var)
{

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif

	fprintf(stderr, "%s(): Clear not implemented for this widget.\n", __func__);

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif
}

/***********************************************************************
 * Create                                                              *
 ***********************************************************************/
GtkWidget *widget_colorbutton_create(
	AttributeSet *Attr, tag_attr *attr, gint Type)
{
	GtkWidget        *widget;

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif

	widget = gtk_color_button_new();

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif

	return widget;
}

/***********************************************************************
 * Convert hexadecimal to decimal value                                *
 ***********************************************************************/
 
 /**
 * Thanks to @johanmalm Johan Malm
 * https://github.com/labwc/labwc/blob/master/src/theme.c
 */
static int hex_to_dec(char c)
{
	if (c >= '0' && c <= '9') {
		return c - '0';
	}
	if (c >= 'a' && c <= 'f') {
		return c - 'a' + 10;
	}
	if (c >= 'A' && c <= 'F') {
		return c - 'A' + 10;
	}
	return 0;
}

/***********************************************************************
 * Environment Variable All Construct                                  *
 ***********************************************************************/

gchar *widget_colorbutton_envvar_all_construct(variable *var)
{
	gchar            *string = {0};

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif

	/* This function should not be connected-up by default */

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif

	return string;
}

/***********************************************************************
 * Environment Variable Construct                                      *
 ***********************************************************************/

gchar *widget_colorbutton_envvar_construct(GtkWidget *widget)
{
	GdkRGBA           color;
	gchar             envvar[64];
	gchar            *string;

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif

	gtk_color_chooser_get_rgba(GTK_COLOR_CHOOSER(widget), &color);

#ifdef DEBUG_CONTENT
	fprintf(stderr, "%s(): color.red  =#%04x  rgb=%02x\n", __func__,
		color.red, (color.red);
	fprintf(stderr, "%s(): color.green=#%04x  rgb=%02x\n", __func__,
		color.green, (color.green);
	fprintf(stderr, "%s(): color.blue =#%04x  rgb=%02x\n", __func__,
		color.blue, (color.blue);
	fprintf(stderr, "%s(): color.alpha =#%04x  rgb=%02x\n", __func__,
		color.alpha, (color.alpha);
#endif
	gtk_color_chooser_get_rgba(GTK_COLOR_CHOOSER(widget), &color);
	if (gtk_color_chooser_get_use_alpha(GTK_COLOR_CHOOSER(widget))) {
		sprintf(envvar, "#%02x%02x%02x|%02x",
			(guint)(color.red * 255),
			(guint)(color.green * 255),
			(guint)(color.blue * 255),
			(guint)(color.alpha * 257));
	} else {
		sprintf(envvar, "#%02x%02x%02x|%02x",
			(guint)(color.red * 255),
			(guint)(color.green * 255),
			(guint)(color.blue * 255),
			(guint)(1.0 * 255));
	}
	string = g_strdup(envvar);

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif

	return string;
}

/***********************************************************************
 * Fileselect                                                          *
 ***********************************************************************/

void widget_colorbutton_fileselect(
	variable *var, const char *name, const char *value)
{

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif

	fprintf(stderr, "%s(): Fileselect not implemented for this widget.\n", __func__);

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif
}

/***********************************************************************
 * Refresh                                                             *
 ***********************************************************************/
void widget_colorbutton_refresh(variable *var)
{
	GdkRGBA           color;
	GList            *element;
	gchar            *act;
	gint              initialised = FALSE;
	const gchar      *a = {0};
	const gchar      *rgba_in = {0};
	list_t           *values = NULL;
	gint              a_len;
	gchar             in_color[32] = {0}; 

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif

	/* Get initialised state of widget */
	if (g_object_get_data(G_OBJECT(var->Widget), "_initialised") != NULL)
		initialised = (intptr_t)g_object_get_data(G_OBJECT(var->Widget), "_initialised");

	/* The <input> tag... */
	act = attributeset_get_first(&element, var->Attributes, ATTR_INPUT);
	while (act) {
		if (input_is_shell_command(act))
			widget_colorbutton_input_by_command(var, act + 8);
		/* input file stock = "File:", input file = "File:/path/to/file" */
		if (strncasecmp(act, "file:", 5) == 0 && strlen(act) > 5) {
			if (!initialised) {
				/* Check for file-monitor and create if requested */
				widget_file_monitor_try_create(var, act + 5);
			}
			widget_colorbutton_input_by_file(var, act + 5);
		}
		act = attributeset_get_next(&element, var->Attributes, ATTR_INPUT);
	}

	/* The <item> tags... */
	if (attributeset_is_avail(var->Attributes, ATTR_ITEM))
		widget_colorbutton_input_by_items(var);

	/* Initialise these only once at start-up */
	if (!initialised) {
		/* Apply directives */
		if (attributeset_is_avail(var->Attributes, ATTR_LABEL))
			fprintf(stderr, "%s(): <label> not implemented for this widget.\n",
				__func__);

		if (attributeset_is_avail(var->Attributes, ATTR_DEFAULT)) {
			values = linecutter(g_strdup(attributeset_get_first(&element,
				var->Attributes, ATTR_DEFAULT)), '|');
			if (values->n_lines > 0) {
				/* Parse the RGB value to create the necessary GdkRGBA.
				 * This function doesn't like trailing whitespace so it
				 * needs to be stripped first with g_strstrip() */
				rgba_in = g_strdup(g_strstrip(values->line[0]));
				if (values->n_lines > 1) {
					a = g_strdup(g_strstrip(values->line[1]));
					/* If we have alpha we need to convert the whole
					 * rgba_in string var to rgba(uint,uint,uint,double)
					 * as gdk_rgba_parse() only accepts hex in the form
					 * of #abc #aabbcc, #aaabbbccc or #aaaabbbbcccc,
					 * but we are only going to support the most common
					 * variant of hex notation. This is kindof weird because
					 * a GdkRGBA type is the same as cairo,
					 * rgba(double,double,double,double)
					 */
					/* convert to css style rgba() */
					guint r = (hex_to_dec(rgba_in[1]) * 16 + hex_to_dec(rgba_in[2]));
					guint g = (hex_to_dec(rgba_in[3]) * 16 + hex_to_dec(rgba_in[4]));
					guint b = (hex_to_dec(rgba_in[5]) * 16 + hex_to_dec(rgba_in[6]));
					float rgbf = 1.0;
					a_len = strlen(a);
					if (a_len == 2) { /* parse the #aabbcc|dd notion */
						rgbf = (hex_to_dec(a[0]) * 16 + hex_to_dec(a[1])) / 256.0;
					} else { /* parse the old 0 - 65535 notion */
						rgbf = atof(a) / 256 / 256;
					}
					gint ret = snprintf(in_color, sizeof(in_color), "rgba(%d, %d, %d, %f)", r, g, b, rgbf );
					if (ret <= 0) {
						fprintf(stderr, "%s:() valid alpha found\n", a);
					}
					if (gdk_rgba_parse(&color, in_color)) {
						gtk_color_chooser_set_rgba(GTK_COLOR_CHOOSER(var->Widget), &color);
					}
				} else {
				if (gdk_rgba_parse(&color, rgba_in)) {
#ifdef DEBUG_CONTENT
					fprintf(stderr, "%s:() valid colour found\n", __func__);
#endif
						gtk_color_chooser_set_rgba(GTK_COLOR_CHOOSER(var->Widget), &color);
					}
				}
			}
			/* Free linecutter memory */
			if (values) list_t_free(values);
		}

		if (attributeset_is_avail(var->Attributes, ATTR_HEIGHT))
			fprintf(stderr, "%s(): <height> not implemented for this widget.\n",
				__func__);
		if (attributeset_is_avail(var->Attributes, ATTR_WIDTH))
			fprintf(stderr, "%s(): <width> not implemented for this widget.\n",
				__func__);
		if ((attributeset_cmp_left(var->Attributes, ATTR_SENSITIVE, "false")) ||
			(attributeset_cmp_left(var->Attributes, ATTR_SENSITIVE, "disabled")) ||	/* Deprecated */
			(attributeset_cmp_left(var->Attributes, ATTR_SENSITIVE, "no")) ||
			(attributeset_cmp_left(var->Attributes, ATTR_SENSITIVE, "0")))
			gtk_widget_set_sensitive(var->Widget, FALSE);

		/* Connect signals */
		g_signal_connect(G_OBJECT(var->Widget), "color-set",
			G_CALLBACK(on_any_widget_color_set_event), (gpointer)var->Attributes);
	}

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif
}

/***********************************************************************
 * Removeselected                                                      *
 ***********************************************************************/

void widget_colorbutton_removeselected(variable *var)
{

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif

	fprintf(stderr, "%s(): Removeselected not implemented for this widget.\n",
		__func__);

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif
}

/***********************************************************************
 * Save                                                                *
 ***********************************************************************/

void widget_colorbutton_save(variable *var)
{
	FILE             *outfile;
	GdkRGBA           color;
	GList            *element;
	gchar            *act;
	gchar            *filename = NULL;

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif
	/* We'll use the output file filename if available */
	act = attributeset_get_first(&element, var->Attributes, ATTR_OUTPUT);
	while (act) {
		if (strncasecmp(act, "file:", 5) == 0 && strlen(act) > 5) {
			filename = act + 5;
			break;
		}
		act = attributeset_get_next(&element, var->Attributes, ATTR_OUTPUT);
	}

	/* If we have a valid filename then open it and dump the
	 * widget's data to it */
	if (filename) {
		if ((outfile = fopen(filename, "w"))) {
			gtk_color_chooser_get_rgba(GTK_COLOR_CHOOSER(var->Widget), &color);
			if (gtk_color_chooser_get_use_alpha(GTK_COLOR_CHOOSER(var->Widget))) {	
				fprintf(outfile, "#%02x%02x%02x|%02x",
					(guint)(color.red * 255),
					(guint)(color.green * 255),
					(guint)(color.blue * 255),
					(guint)(color.alpha * 257));

			} else {
				fprintf(outfile, "#%02x%02x%02x|%02x",
					(guint)(color.red * 255),
					(guint)(color.green * 255),
					(guint)(color.blue * 255),
					(guint)(1.0 * 255));
			}
			/* Close the file */
			fclose(outfile);
		} else {
			fprintf(stderr, "%s(): Couldn't open '%s' for writing.\n",
				__func__, filename);
		}
	} else {
		fprintf(stderr, "%s(): No <output file> directive found.\n", __func__);
	}

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif
}

/***********************************************************************
 * Input by Command                                                    *
 ***********************************************************************/

static void widget_colorbutton_input_by_command(variable *var, char *command)
{
	FILE             *infile;
	GdkRGBA           color;
	list_t           *values = NULL;
	gchar             line[512];
	const gchar      *rgba_in = {0};    
	gint              count;
	const gchar      *a = {0};
	gint              a_len;
	gchar             in_color[32] = {0}; 

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif

#ifdef DEBUG_CONTENT
	fprintf(stderr, "%s(): command: '%s'\n", __func__, command);
#endif
	/* Opening pipe for reading... */
	if ((infile = widget_opencommand(command))) {
		/* Just one line */
		if (fgets(line, 512, infile)) {
			/* Enforce end of string in case of max chars read */
			line[512 - 1] = 0;
			/* Remove the trailing [CR]LFs */
			for (count = strlen(line) - 1; count >= 0; count--)
				if (line[count] == 13 || line[count] == 10) line[count] = 0;
			values = linecutter(g_strdup(line), '|');
			if (values->n_lines > 0) {
				/* Parse the RGB value to create the necessary GdkRGBA.
				 * This function doesn't like trailing whitespace so it
				 * needs to be stripped first with g_strstrip() */
				rgba_in = g_strdup(g_strstrip(values->line[0]));
				if (values->n_lines > 1) {
					a = g_strdup(g_strstrip(values->line[1]));
					/* If we have alpha we need to convert the whole
					 * rgba_in string var to rgba(uint,uint,uint,double)
					 * as gdk_rgba_parse() only accepts hex in the form
					 * of #abc #aabbcc, #aaabbbccc or #aaaabbbbcccc,
					 * but we are only going to support the most common
					 * variant of hex notation. This is kindof weird because
					 * a GdkRGBA type is the same as cairo,
					 * rgba(double,double,double,double)
					 */
					/* convert to css style rgba() */
					guint r = (hex_to_dec(rgba_in[1]) * 16 + hex_to_dec(rgba_in[2]));
					guint g = (hex_to_dec(rgba_in[3]) * 16 + hex_to_dec(rgba_in[4]));
					guint b = (hex_to_dec(rgba_in[5]) * 16 + hex_to_dec(rgba_in[6]));
					float rgbf = 1.0;
					a_len = strlen(a);
					if (a_len == 2) { /* parse the #aabbcc|dd notion */
						rgbf = (hex_to_dec(a[0]) * 16 + hex_to_dec(a[1])) / 256.0;
					} else { /* parse the old 0 - 65535 notion */
						rgbf = atof(a) / 256 / 256;
					}
					gint ret = snprintf(in_color, sizeof(in_color), "rgba(%d, %d, %d, %f)", r, g, b, rgbf );
					if (ret <= 0) {
						fprintf(stderr, "%s:() valid alpha found\n", a);
					}
					if (gdk_rgba_parse(&color, in_color)) {
						gtk_color_chooser_set_rgba(GTK_COLOR_CHOOSER(var->Widget), &color);
					}
				} else {
				if (gdk_rgba_parse(&color, rgba_in)) {
#ifdef DEBUG_CONTENT
					fprintf(stderr, "%s:() valid colour found\n", __func__);
#endif
						gtk_color_chooser_set_rgba(GTK_COLOR_CHOOSER(var->Widget), &color);
					}
				}
			}
			/* Free linecutter memory */
			if (values) list_t_free(values);
		}
		/* Close the file */
		pclose(infile);
	} else {
		fprintf(stderr, "%s(): Couldn't open '%s' for reading.\n", __func__,
			command);
	}

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif
}

/***********************************************************************
 * Input by File                                                       *
 ***********************************************************************/

static void widget_colorbutton_input_by_file(variable *var, char *filename)
{
	FILE             *infile;
	GdkRGBA           color;
	list_t           *values = NULL;
	gchar             line[512];
	const gchar      *rgba_in = {0};    
	gint              count;
	const gchar      *a = {0};
	gint              a_len;
	gchar             in_color[32] = {0}; 

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif
	if ((infile = fopen(filename, "r"))) {
		/* Just one line */
		if (fgets(line, 512, infile)) {
			/* Enforce end of string in case of max chars read */
			line[512 - 1] = 0;
			/* Remove the trailing [CR]LFs */
			for (count = strlen(line) - 1; count >= 0; count--)
				if (line[count] == 13 || line[count] == 10) line[count] = 0;
			values = linecutter(g_strdup(line), '|');
			if (values->n_lines > 0) {
				/* Parse the RGB value to create the necessary GdkRGBA..
				 * This function doesn't like trailing whitespace so it
				 * needs to be stripped first with g_strstrip() */
				rgba_in = g_strdup(g_strstrip(values->line[0]));
				if (values->n_lines > 1) {
					a = g_strdup(g_strstrip(values->line[1]));
					/* If we have alpha we need to convert the whole
					 * rgba_in string var to rgba(uint,uint,uint,double)
					 * as gdk_rgba_parse() only accepts hex in the form
					 * of #abc #aabbcc, #aaabbbccc or #aaaabbbbcccc,
					 * but we are only going to support the most common
					 * variant of hex notation. This is kindof weird because
					 * a GdkRGBA type is the same as cairo,
					 * rgba(double,double,double,double)
					 */
					/* convert to css style rgba() */
					guint r = (hex_to_dec(rgba_in[1]) * 16 + hex_to_dec(rgba_in[2]));
					guint g = (hex_to_dec(rgba_in[3]) * 16 + hex_to_dec(rgba_in[4]));
					guint b = (hex_to_dec(rgba_in[5]) * 16 + hex_to_dec(rgba_in[6]));
					float rgbf = 1.0;
					a_len = strlen(a);
					if (a_len == 2) { /* parse the #aabbcc|dd notion */
						rgbf = (hex_to_dec(a[0]) * 16 + hex_to_dec(a[1])) / 256.0;
					} else { /* parse the old 0 - 65535 notion */
						rgbf = atof(a) / 256 / 256;
					}
					gint ret = snprintf(in_color, sizeof(in_color), "rgba(%d, %d, %d, %f)", r, g, b, rgbf );
					if (ret <= 0) {
						fprintf(stderr, "%s:() valid alpha found\n", a);
					}
					if (gdk_rgba_parse(&color, in_color)) {
						gtk_color_chooser_set_rgba(GTK_COLOR_CHOOSER(var->Widget), &color);
					}
				} else {
				if (gdk_rgba_parse(&color, rgba_in)) {
#ifdef DEBUG_CONTENT
					fprintf(stderr, "%s:() valid colour found\n", __func__);
#endif
						gtk_color_chooser_set_rgba(GTK_COLOR_CHOOSER(var->Widget), &color);
					}
				}
			}
			/* Free linecutter memory */
			if (values) list_t_free(values);
		}
		/* Close the file */
		fclose(infile);
	} else {
		fprintf(stderr, "%s(): Couldn't open '%s' for reading.\n", __func__,
			filename);
	}

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif
}

/***********************************************************************
 * Input by Items                                                      *
 ***********************************************************************/

static void widget_colorbutton_input_by_items(variable *var)
{

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Entering.\n", __func__);
#endif

	fprintf(stderr, "%s(): <item> not implemented for this widget.\n", __func__);

#ifdef DEBUG_TRANSITS
	fprintf(stderr, "%s(): Exiting.\n", __func__);
#endif
}

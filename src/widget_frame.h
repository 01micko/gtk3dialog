/*
 * widget_frame.h: 
 * Gtk3dialog - A small utility for fast and easy GUI building.
 * Copyright (C) 2003-2007  L�szl� Pere <pipas@linux.pte.hu>
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

#ifndef WIDGET_FRAME_H
#define WIDGET_FRAME_H

/* Function prototypes */
void widget_frame_clear(variable *var);
GtkWidget *widget_frame_create(
	AttributeSet *Attr, tag_attr *attr, gint Type);
gchar *widget_frame_envvar_all_construct(variable *var);
gchar *widget_frame_envvar_construct(GtkWidget *widget);
void widget_frame_fileselect(
	variable *var, const char *name, const char *value);
void widget_frame_refresh(variable *var);
void widget_frame_removeselected(variable *var);
void widget_frame_save(variable *var);

#endif

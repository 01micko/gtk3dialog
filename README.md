# Gtk3dialog - A small utility for fast and easy GUI building (WIP)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

## NOTES

This fork may not be what you want as it only supports `gtk-3.0` with
only the `meson` build system. See the original project [gtkdialog](https://github.com/puppylinux-woof-CE/gtkdialog)

- GTK-2.0 is purged
- Autotools is purged
- deprecated widgets are purged
- many, many compile warnings are fixed, many more to go

## TO DO

In no particualr order:

- [x] rename (project, binary etc) (WIP)
- [x] fix CI
- [x] purge all the gtk2 `#if` s (there are many)
- [x] update all deprecated functions - with exceptions
- [ ] fix the rest of the compiler warnings
- [ ] add at least `gtk-grid` widget
- [ ] fix documentataion including a `man` page
- [ ] even better wayland support (WIP)
- [ ] CSD (maybe)
- [ ] fix examples and `html` docs for new name
- [ ] Wiki

# Build

```
meson setup build [configure-options]
meson compile -C build
ninja -C build install # as root

```

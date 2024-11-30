project('gtk3dialog', 'c', version: '0.1.0', license: 'GPLv2')

gthread = dependency('gthread-2.0')

gtkver = get_option('gtkver')

if gtkver == 3
	gtk = dependency('gtk+-3.0')
	vte = dependency('vte-2.91', required: false)
	libnotify = dependency('libnotify', required: false)
	gtk_layer_shell = dependency('gtk-layer-shell-0', required: false)
	if not gtk_layer_shell.found()
		proj = subproject(
			'gtk-layer-shell',
			default_options: ['default_library=static', 'introspection=false'],
			required: false,
		)
		if proj.found()
			gtk_layer_shell = proj.get_variable('gtk_layer_shell')
		endif
	endif
else
	gtk = dependency('gtk+-2.0')
	vte = dependency('vte', required: false)
endif

install_subdir(
	'man', install_dir : get_option('datadir')
)

if get_option('docs')
	subdir('doc')
	install_subdir(
	'examples', install_dir : join_paths(get_option('datadir'), 'doc', 'gtk3dialog')
	)
endif

subdir('src')
subdir('data')

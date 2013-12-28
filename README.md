i3-scripts
==========

A set of scripts to make [i3] behave like I want it to.

[i3]: http://i3wm.org/

workspace_switcher.pl
---------------------

A workspace switcher inspired by how [Awesome] behaved with a slightly modified
config back when I used it. Each output has its own set of numbered workspaces
(output 1 gets ``1 [1]``, ``2 [1]``, etc. up to `10 [1]`). It also implements a
back-and-forth switching mechanism similar to ``workspace_back_and_forth yes``,
but uses separate histories per output.

[Awesome]: http://awesome.naquadah.org/

The script needs to be started after i3 has loaded. I run the following command,
but there are of course more than one way to run it. If you can figure out a
clever way to load it from inside the i3 config, please let me know.

```
i3 exec ~/i3-scripts/workspace_switcher.pl
```

### Keybindings

``workspace_switcher.pl`` uses keys ``$mod (+ shift) + 0..9``. By default $mod
is ``Super_L``, the left Windows key, because that's what I use. Feel free to
change this keybinding inside the script.

By default however, ``$mod + 0..9`` are taken by i3, causing the script to fail
after doing GrabKey, eventually barfing an X11 error message. Make sure to
comment out these keys inside your i3 config. (Comment rather than remove so you
can easily get them back should anything fail unexpectedly.)

### Dependencies

The workspace switcher needs at least Perl modules [AnyEvent::I3] and
[X11::Protocol]. I was able to install them using `cpan`, hopefully available on
your distro.

[AnyEvent::I3]: https://metacpan.org/pod/AnyEvent-I3
[X11::Protocol]: https://metacpan.org/pod/X11::Protocol
[CPAN]: http://www.cpan.org/

DEPRECATED!
===========

This is contenticious and it's cool, but you can do the same with much more
flexibility with [Mojolicious::Plugin::ContentManagement][MPCM], so you may
want to look at it instead.

[MPCM]: http://github.com/memowe/mojolicious-plugin-content_management

contenticious
=============

A simple file based "CMS" on Mojo steroids!

Synopsis
--------

    $ vim pages/index.md
    $ mkdir pages/section
    $ vim pages/section/foo.md
    $ ./contenticious.pl daemon

Description
-----------

Contenticious is a very simple way to glue together some content to a small website. You just write Markdown files and check the generated HTML in your browser. To publish, use the `dump` command to generate static HTML as described below.

### How to organize your content

This is the simple part.

#### Basic content management

Write `*.md` files in the `pages` directory, they will be interpreted with [Markdown][MD].

[MD]: http://daringfireball.net/projects/markdown/

You can organize them in directories and link to other files (replace the `.md` with `.html`. If you want a start page for a directory, name it `index.md`. If no `index.md` exists, contenticious will generate an index page for that directory.

You don't have to think about navigation - contenticious will generate a navigation bar for you.

If you want, you can place additional content like pictures or PDF documents in the `public` directory. They will be served automatically.

You can view the Markdown content in your browser after invoking

    ./contenticious.pl daemon

For additional options, `contenticious.pl help daemon` will be your friend.

#### Advanced content-fu

To manage the sorting in the navigation, prepend digits and an underscore to your file names (`017_zoom.md` first, then `042_albundy.md`).

If you want a different name for your page in the navigation, provide the navi metadata `navi` by prepending the following line to the markdown file:

    navi: the SpEcIaL nåm€ øf ≤this≥ page

For a special page title, provide a `title` metadata line in the same manner.

To hide a page in the navigation, set the `navihide` metadata to true value: `navihide: 1`.

You can also set a directory's navigation name with a `navi: ...` line as above in a file named `meta` in that directory.

### How to deploy

This is the simple part. The command

    ./contenticious.pl dump

will dump all the content to the `static` directory, ready to upload to your web server.

### Customization (C11N)

This is the simple part. Just change the standard stylesheet in `public`. If that's not enough c11n for you, invoke the command

    ./contenticious.pl templates

and all the templates are dumped to the `templates` directory. There you can change the templates, written in [ep][ep].

[ep]: http://search.cpan.org/dist/Mojo/lib/Mojo/Template.pm

Bugs and Caveats
----------------

At this time, it's impossible by design to use a file and a directory with the same name, like `foo/*` and `foo.md`. Please use `foo/*` and `foo/index.md` instead. If you have a really good reason to use the first case, please let me know.

Authors and license
-------------------

Copyright (c) 2009 Mirko Westermeier, <mirko@westermeier.de>

Credits:

- Maxim Vuets, <maxim.vuets@gmail.com>

Thank you for your contributions!

Published under the MIT license. See MIT-LICENSE.

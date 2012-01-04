contenticious
=============

**Contenticious is a very simple way to build a nice little website from your content**.

You just write [Markdown][mado] files in a directory structure and check the generated HTML live in your browser. The presentation is highly customizable on many levels, but I think the default is readable and rather pretty.

Contenticious can "be" a web server for your content, but you can dump everything to static files with a single command and upload it to your favourite web hoster.

[mado]: http://daringfireball.net/projects/markdown/

How to get it
-------------

Contenticious is built on top of [Mojolicious][mojo], a very cool [Perl][perl] web framework. Mojolicious doesn't have any dependencies besides a modern Perl interpreter. It's very easy to install Mojolicious with this one-liner:

    $ sudo sh -c "curl -L cpanmin.us | perl - Mojolicious"

The latest version of contenticious lives in a [repository on github][gihu] and you can get it via this one-liner:

    $ git clone git://github.com/memowe/contenticious.git

Done.

[mojo]: http://mojolicio.us/
[perl]: http://perl.org/
[gihu]: http://github.com/memowe/contenticious

Let's go!
---------

`cd` to the contenticious directory. The interesting directory here is `pages`. You'll find some files in here so you can get a first impression of what's going on here. Feel free to play around and edit everything you can find.

Wait. You don't see anything but your terminal. Now please `cd` to your contenticious directory and start the preview server:

    $ morbo contenticious.pl
    ...
    Server available at http://127.0.0.1:3000.

Now open your browser and type in that address. In contenticious's default configuration caching is disabled, so you can just edit files in your favourite text editor and after a browser refresh your text is just there - but pretty!

Notice how contenticious creates a navigation for you.

### On directory and file names

Your directory and file names become url path parts. You may want to add
numbers to the directory and file names to get the navigation items in the
right order. The numbers will never be seen outside.

To define content for a directory itself you can provide an `index.md` file.
If you don't provide an `index.md` file for a directory, contenticious will
render a list page for you. See this table for better illustration.

    file system                     urls
    -------------------------------------------------------
    pages
      |-- 017_c.md                  /c.html
      |-- 018_perl
      |    |-- index.md             /perl.html
      |    |-- 01_introduction.md   /perl/introduction.html
      |    '-- 42_the_cpan.md       /perl/the_cpan.html
      '-- 072_brainfuck             /brainfuck.html
           |--- 17_turing.md        /brainfuck/turing.html
           '--- 69_wtf.md           /brainfuck/wtf.html

In this case, `/brainfuck.html` will be an auto-generated listing of the two
sub pages, turing and wtf. Later you will be informed how to customize the
contenticious templates. You can adjust the listing by editing the template
`list.html.ep`.

**Note**: it's impossible to have a directory and a file with the same path
name, but I'm pretty sure you don't really want that. Instead use the
`index.md` mechanism from above.

### More about content

Contenticious needs some meta informations about your content files, but it
works very hard to guess if you don't provide it. Meta information is
provided in the first few lines of your markdown documents and looks like this

    title: The Comprehensive Perl Archive Network
    navi_name: The CPAN

    It's huge, but your mom could eat it
    ====================================

    **CPAN, the Comprehensive Perl Archive Network**, is an archive of over
    100,000 modules of software written in Perl,
    as well as documentation for it. ...

The `title` will show up in the `title` HTML element of the pages, which will
be rendered in the window title bar in most browsers. If no `title` line is
provided, contenticious will try to extract the first `H1` headline of the
document's body, which is the mom-line in this case. If there's no `H1`
headline, contenticious will use the path part (extracted from file name).

The second meta information is `navi_name` which will be used to generate
the site navigation. If no `navi_name` is provided, contenticious will use
the pathpart (extracted from file name).

Sometimes you'll need static content like images, sound files or PDF documents.
No problem, just place them in the `public` directory and they will be served
by contenticious under their own name.

Customize
---------

To change contenticious' presentation and behaviour, please look at the
configuration file `config` first. It looks like this:

    {
        pages_dir   => app->home->rel_dir('pages'),
        dump_dir    => app->home->rel_dir('dump'),
        name        => 'Shagadelic',
        copyright   => 'Zaphod Beeblebrox',
        cached      => 0,
    }

As you can see, it is a Perl data structure and you can access the `app`
shortcut for advanced hacking. I think, the most names are rather
self-documenting, except `cached`. When set to a true value, contenticious will
hold the document structure in memory to serve it faster. It's deactivated
by default for development. Otherwise you would have to restart the server
every time you want to view your documents' last version.

To change the design of contenticious' pages, edit the `styles.css` file in
the `public` directory. Since the default HTML is very clean you should be
able to change a lot with css changes.

If that's still not enough, use the following command to extract all templates
from contenticious' main script:

    perl contenticious.pl inflate

Then you can change contenticious' HTML with Mojolicious' flexible [ep template
syntax][mote].

[mote]: http://mojolicio.us/perldoc/Mojo/Template

Deploying
---------

You can find a lot of information about the deployment of Mojolicious apps in
its [wiki][mwiki]. In most cases you want to set the `chached` option to a true
value in contenticious' config file to increase performance.

It's also possible to generate static HTML and CSS files with contenticious:

    $ perl contenticious.pl dump

It will dump everything to the directory `dump` so you can upload it to your
favourite web server without any perl, Mojolicious or contenticious magic.

[mwiki]: https://github.com/kraih/mojo/wiki

Repository with issue tracker
-----------------------------

[Contenticious' source code repository][repo] is on github. There you can also
find a simple [issue tracker][issues]. Feel free to use it! :-)

[repo]: https://github.com/memowe/contenticious
[issues]: https://github.com/memowe/contenticious/issues

Author and license
-------------------

Copyright (c) Mirko Westermeier, <mail@memowe.de>

Credits:

- Maxim Vuets, <maxim.vuets@gmail.com>

Thank you for your contributions!

Published under the MIT license. See MIT-LICENSE.

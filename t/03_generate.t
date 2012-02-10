#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 14;
use File::Path 'remove_tree';
use FindBin '$Bin';
use lib "$Bin/../lib";
use Contenticious::Generator;

# slurp helper
sub slurp {
    my $fn = shift;
    open my $fh, '<:encoding(UTF-8)', $fn or die "couldn't open $fn: $!";
    return do { local $/; <$fh> };
}

# delete test files and test non-existence
sub delete_test_files {
    foreach my $file (qw(config webapp.pl pages public)) {
        remove_tree("$Bin/$file");
        ok(! -e "$Bin/$file", "$file doesn't exist");
    }
}

# nothing there
delete_test_files();

# generate in t
chdir $Bin;
my $generator = Contenticious::Generator->new(quiet => 1);
$generator->init;

# config file
is(slurp('config'), <<'EOD', 'right config file content');
{
    pages_dir   => app->home->rel_dir('pages'),
    dump_dir    => app->home->rel_dir('dump'),
    name        => 'Shagadelic',
    copyright   => 'Zaphod Beeblebrox',
    cached      => 0,
    perldoc     => 1,
}
EOD

# web app
is(slurp('webapp.pl'), <<'EOD', 'right webapp.pl file content');
#!/usr/bin/env perl
use Mojo::Base -strict;

# use local lib (if Contenticious isn't installed)
use FindBin '$Bin'; use lib "$Bin/lib", "$Bin/../lib";
use Contenticious;
use Contenticious::Commands;
use Mojolicious::Commands;

# use Contenticious
$ENV{MOJO_HOME} = $Bin;
my $app = Contenticious->new;

# Contenticious dump command
if (defined $ARGV[0] and $ARGV[0] eq 'dump') {
    Contenticious::Commands->new(app => $app)->dump;
}

# use Contenticious as mojo app
else {
    $ENV{MOJO_APP} = $app;
    Mojolicious::Commands->start;
}
EOD

# welcome page
is(slurp('pages/index.md'), <<'EOD', 'right pages/index.md file content');
Title: Welcome to contenticious - a simple file based "CMS"!

Welcome to contenticious
========================

An insanely simple file system based "CMS"

**TODO** perldoc: [Contenticious](perldoc/Contenticious)

Resources
---------

* Please start with the [**contenticious documentation**][docs].

* [**contenticious on github**][ghub] - check out the repository!

* Learn more about [Mojolicious][mojo], the excellent Perl web framework
  that made all this stuff nice and easy.

I can't wait!
-------------

Come on, you didn't read the [docs][docs]? :-D OK. Than just go to `pages` and
play around. But in case of questions, come back and read the [docs][docs]!

[docs]: about/README.html
[ghub]: http://github.com/memowe/contenticious
[mojo]: http://mojolicio.us
EOD

# readme page
is(slurp('pages/005_about/1_README.md'), <<'EOD', 'right README page');
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
EOD

# license page
is(slurp('pages/005_about/2_License.md'), <<'EOD', 'right license page');
Copyright (c) Mirko Westermeier, <mail@memowe.de>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOD

# stylesheet
is(slurp('public/styles.css'), <<'EOD', 'right stylesheet file content');
html, body {
    margin          : 0;
    padding         : 0;
    color           : black;
    background-color: #eee;
    font-family     : 'Helvetica', sans-serif;
}

* { line-height: 150% }

p { margin: .66em 0; padding: 0 }

strong { font-weight: bold }

em { font-style: italic }

#top {
    background-color: #222;
    color           : #ddd;
    margin          : 0;
    padding         : 1em 5ex;
    border-bottom   : medium solid #999;
}

#top #inner {
    width           : 100ex;
    margin          : 0 auto;
    padding         : 0;
}

#top #name a {
    font-size       : 1.8em;
    color           : white;
    text-decoration : none;
}

#top #navi, #top #subnavi, #top #subsubnavi {
    margin          : .5em 0 0;
    padding         : 0;
}

#top #navi { font-size: 1.2em }
#top #subnavi { font-weight: bold }

#top #navi li, #top #subnavi li, #top #subsubnavi li {
    display         : inline;
    margin          : 0;
    padding         : .2em 1ex;
    border-radius   : .5em;
}

#top #navi li:first-child, #top #subnavi li:first-child,
#top #subsubnavi li:first-child { margin-left: -1ex }

#top #navi li.active, #top #subnavi li.active, #top #subsubnavi li.active {
    background-color: #444;
}

#top #navi a, #top #subnavi a, #top #subsubnavi a {
    text-decoration : none;
    color           : inherit;
}

#top #navi a:hover, #top #navi a:active,
#top #subnavi a:hover, #top #subnavi a:active,
#top #subsubnavi a:hover, #top #subsubnavi a:active { color: white }

#content {
    width           : 90ex;
    margin          : 0 auto;
    padding         : 2em 7ex 3em;
    color           : #333;
    background-color: #f8f8f8;
    border          : solid #ddd;
    border-width    : 0 thin thin;
}

#content h1, #content h2, #content h3 {
    font-weight     : bold;
    margin          : 2em 0 1em;
    padding         : 0;
}

#content h1 { font-size: 2em; font-weight: normal; margin-top: .5em }

#content h2 { font-size: 1.5em }

#content h3 { font-size: 1.2em }

#content a {
    text-decoration : underline;
    color           : #039;
}

#content a:visited { color: #333 }

pre {
    margin          : 1em 0;
    padding         : .5em;
    border          : thin solid #ddd;
}

pre, code {
    font-family     : monospace;
    color           : #333;
    background-color: white;
}

#footer {
    margin          : 2em;
    padding         : 0 7ex;
    color           : #777;
    font-size       : .8em;
    text-align      : center;
    text-shadow     : 1px 1px 0 white;
}

#built_with {
    font-size       : .9em;
    color           : #999;
}

#built_with a {
    text-decoration : none;
    color           : #888;
}

#built_with a:hover, #built_with a:active { text-decoration: underline }
EOD

# we're done
delete_test_files();

__END__

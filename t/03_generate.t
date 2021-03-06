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
Contenticious::Generator->new->generate;

# config file
is(slurp('config'), <<'EOD', 'right config file content');
{
    pages_dir   => app->home->rel_file('pages'),
    dump_dir    => app->home->rel_file('dump'),
    name        => 'This is Contenticious.',
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
BEGIN {
    use File::Basename 'dirname';
    my $dir = dirname(__FILE__);
    unshift @INC, "$dir/lib", "$dir/../lib";
}

use Contenticious;
use Contenticious::Commands;
use Mojolicious::Commands;

# use Contenticious
$ENV{MOJO_HOME} = dirname(__FILE__);

# Contenticious dump command
if (defined $ARGV[0] and $ARGV[0] eq 'dump') {
    Contenticious::Commands->new(app => Contenticious->new)->dump;
}

# use Contenticious as mojo app
else {
    Mojolicious::Commands->start_app('Contenticious');
}
EOD

# welcome page
is(slurp('pages/index.md'), <<'EOD', 'right pages/index.md file content');
Title: Welcome to Contenticious - build web sites from markdown files

Welcome!
========

**Hi there, Contenticious is working**. This is an example page.
You can find it in your `pages` directory.
It is rendered live from [Markdown][md] to this
nice HTML page together with a simple navigation.

[md]: http://daringfireball.net/projects/markdown/

Possible next steps
-------------------

1. Edit `pages/index.md` to change this file!
1. Read the [introduction perldoc](perldoc/Contenticious).
1. [Customize this!](perldoc/Contenticious#Customize)
1. Read API docs ([perldoc sitemap](Perldoc.html)).
1. Find out [more about Contenticious](About.html).
EOD

# perldoc page
is(slurp('pages/01_Perldoc.md'), <<'EOD', 'right perldoc page');
title: Contenticious Perldoc Sitemap
navi_name: Perldoc

Contenticious documentation perldocs
====================================

* [Contenticious][app] - a user-friendly introduction. **Start here**!

The following documents are API docs:

* [Contenticious::Content][content] - access content
* [Contenticious::Content::Node][node] - content node base class
    * [Contenticious::Content::Node::File][file] - represents a file
    * [Contenticious::Content::Node::Directory][dir] - represents a directory
* [Contenticious::Commands][commands] - commands like `dump`
* [Contenticious::Generator][generator] - generates boilerplate

After installing Contenticious you can access these documents via the
`perldoc` command:

    $ perldoc Contenticious::Content::Node

[app]:          perldoc/Contenticious
[content]:      perldoc/Contenticious/Content
[node]:         perldoc/Contenticious/Content/Node
[file]:         perldoc/Contenticious/Content/Node/File
[dir]:          perldoc/Contenticious/Content/Node/Directory
[commands]:     perldoc/Contenticious/Commands
[generator]:    perldoc/Contenticious/Generator
EOD

# about page
is(slurp('pages/02_About.md'), <<'EOD', 'right about page');
title: About Contenticious
navi_name: About

About Contenticious
===================

Contenticious is a small and clean [Mojolicious][mojo] web app with additional
tools to provide a smooth Markdown publishing workflow for you.
It's developed as open source with one of the most free [licenses][license]
(MIT License) to make it really easy for you to get your stuff done.

* [**Follow Contenticious' development on github][repo]**
    There you'll find a bug tracker, a wiki and all sources.

Help testing and improving Contenticious!

[mojo]:     http://mojolicio.us/
[license]:  #license
[repo]:     http://github.com/memowe/contenticious

<h2 id="license">License</h2>

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
    background-color: #f4f4f4;
    font-family     : 'Helvetica', sans-serif;
}

* { line-height: 150% }

p { margin: .66em 0; padding: 0 }

#top {
    background-color: #111;
    color           : #ccc;
    margin          : 0;
    padding         : 1.5em;
    box-shadow      : 0 -5px 5px 5px #999;
}

#top #inner {
    width           : 90ex;
    margin          : 0 auto;
    padding         : 0 7ex;
}

#top #name a {
    font-size       : 1.8em;
    color           : white;
    text-decoration : none;
}

#top #navi {
    display         : block;
    margin          : 0;
    padding         : 0;
    font-size       : 1.3em;
}

#top #navi li {
    display         : inline;
    margin          : 0;
    padding         : 0 2ex 0 0;
}

#top #navi a {
    color           : #ddd;
    text-decoration : none;
}

#top #navi .active a {
    padding-bottom  : .2em;
    border-bottom   : .2em solid #555;
    color           : white;
}

#top #navi a:hover, #top #navi a:active {
    padding-bottom  : .2em;
    border-bottom   : .2em solid #555;
}

#main {
    width           : 90ex;
    margin          : 0 auto;
    padding         : 0 7ex 3em;
    color           : #333;
    background-color: white;
    box-shadow      : 0 0 3px #ccc;
}

#main .navi {
    display         : block;
    margin          : 0 -7ex;
    padding         : .8em 7ex .6em;
    border-bottom   : .1em solid #ddd;
}

#main .navi li {
    display         : inline;
    margin          : 0;
    padding         : 0 2ex 0 0;
}

#main #subnavi                  li { font-size: 1em }
#main #subsubnavi               li { font-size: .9em }
#main #subsubsubnavi            li { font-size: .8em }
#main #subsubsubsubnavi         li { font-size: .7em }
#main #subsubsubsubsubnavi      li { font-size: .7em }
#main #subsubsubsubsubsubnavi   li { font-size: .7em }
#main #subsubsubsubsubsubsubnavi { /* wtf */ }

#main .navi a {
    color           : #555;
    text-decoration : none;
    font-weight     : bold;
}

#main .navi .active a {
    color           : black;
    padding-bottom  : .1em;
    border-bottom   : .3em solid #eee;
}

#main .navi a:hover, #main .navi a:active {
    padding-bottom  : .1em;
    border-bottom   : .3em solid #eee;
}

#content h1, #content h2, #content h3 {
    font-weight     : bold;
    margin          : 2em 0 1em;
    padding         : 0;
}

#content {
    padding-top     : 2em;
}

#content h1 { font-size: 2em; font-weight: normal; margin-top: .5em }

#content h2 { font-size: 1.5em }

#content h3 { font-size: 1.2em }

#content a {
    text-decoration : underline;
    color           : #039;
}

#content a:visited { color: #026 }

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
    color           : #bbb;
}

#built_with a {
    text-decoration : none;
    color           : #999;
}

#built_with a:hover, #built_with a:active { text-decoration: underline }
EOD

# we're done
delete_test_files();

__END__

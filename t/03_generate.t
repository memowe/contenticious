#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 11;
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
    foreach my $file (qw(config webapp.pl pages)) {
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

# we're done
delete_test_files();

__END__
